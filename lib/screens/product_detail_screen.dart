import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';
import '../bloc/product_bloc/product_bloc.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  // Допоміжний метод для пошуку продукту в кеші (стейті списку)
  Product? _findProductInState(BuildContext context) {
    final state = context.read<ProductBloc>().state;
    if (state is ProductLoaded) {
      try {
        return state.products.firstWhere((p) => p.id == productId);
      } catch (_) {
        return null; // Продукт не знайдено в списку
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localProduct = _findProductInState(context);

    if (localProduct != null) {
      return _buildDetailView(context, localProduct);
    }
    return FutureBuilder<Product>(
      future: context.read<ProductRepository>().getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
                child: Text('Failed to load product:\n${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(child: Text('Product not found.')),
          );
        }

        final fetchedProduct = snapshot.data!;
        return _buildDetailView(context, fetchedProduct);
      },
    );
  }

  Widget _buildDetailView(BuildContext context, Product product) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.images.isNotEmpty)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: product.images.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: product.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey),
                    );
                  },
                ),
              )
            else
              const SizedBox(
                height: 300,
                child: Center(
                    child: Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey)),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.brand,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(label: Text(product.category)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(product.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.displayPrice,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                          ),
                          if (product.discountPercentage > 0)
                            Text(
                              '-${product.discountPercentage}% discount',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 4),
                          Text(product.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      )
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Description',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.description,
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(product.stock > 0 ? Icons.inventory : Icons.outbox,
                          color: product.stock > 0 ? Colors.green : Colors.red,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                          product.stock > 0
                              ? 'In Stock: ${product.stock}'
                              : 'Out of Stock',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: product.stock > 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Кнопка знизу екрана
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: product.stock > 0
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${product.title} added to cart!')),
                    );
                  }
                : null, // Кнопка неактивна, якщо товару немає на складі
            style: ElevatedButton.styleFrom(minimumSize: const Size.square(50)),
            child: const Text('Add to Cart'),
          ),
        ),
      ),
    );
  }
}
