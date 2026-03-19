import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class ProductRepository {
  final Dio _dio;
  final SharedPreferences _prefs;

  // Ключі для локального кешування
  static const String _cacheKey = 'products_cache';
  static const String _timestampKey = 'products_cache_timestamp';

  ProductRepository({Dio? dio, required SharedPreferences prefs})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://dummyjson.com/products',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ),
        _prefs = prefs;

  // ============================================================================
  // 1. Отримати список продуктів (з підтримкою ОФЛАЙН КЕШУ)
  // GET: /products?limit=20&skip=0
  // ============================================================================
  Future<ProductResponse> getProducts({int limit = 20, int skip = 0}) async {
    try {
      // 1. Завжди пробуємо отримати свіжі дані з мережі
      final response = await _dio.get(
        '',
        queryParameters: {'limit': limit, 'skip': skip},
      );

      // Якщо це перша сторінка (skip == 0), оновлюємо локальний кеш
      if (skip == 0) {
        await _prefs.setString(_cacheKey, jsonEncode(response.data));
        await _prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
      }

      return ProductResponse.fromJson(response.data);
    } catch (e) {
      // 2. Якщо мережа недоступна (помилка), пробуємо дістати з кешу
      if (skip == 0) {
        final cachedData = _prefs.getString(_cacheKey);
        if (cachedData != null) {
          final jsonData = jsonDecode(cachedData);
          return ProductResponse.fromJson(jsonData);
        }
      }
      // Якщо кешу немає і мережі немає — кидаємо помилку
      throw Exception('No internet and no cached data available.');
    }
  }

  // ============================================================================
  // 2. Пошук продуктів
  // GET: /products/search?q=phone
  // ============================================================================
  Future<ProductResponse> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {'q': query},
      );
      return ProductResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // ============================================================================
  // 3. Отримати список категорій
  // GET: /products/categories
  // ============================================================================
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      // DummyJSON API нещодавно оновили відповідь для категорій
      // Цей код безпечно дістає 'slug' або 'name' з об'єкта, або ж бере строку (старий формат).
      final List<dynamic> data = response.data;
      return data.map((e) {
        if (e is String) return e;
        if (e is Map<String, dynamic>) return e['slug'] as String? ?? '';
        return '';
      }).where((e) => e.isNotEmpty).toList();

    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // ============================================================================
  // 4. Отримати продукти за конкретною категорією
  // GET: /products/category/{name}
  // ============================================================================
  Future<ProductResponse> getProductsByCategory(String categoryName) async {
    try {
      final response = await _dio.get('/category/$categoryName');
      return ProductResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch products for category $categoryName: $e');
    }
  }

  // ============================================================================
  // 5. Отримати деталі одного продукту за ID
  // GET: /products/{id}
  // ============================================================================
  Future<Product> getProductById(int id) async {
    try {
      final response = await _dio.get('/$id');
      return Product.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch product details: $e');
    }
  }
}