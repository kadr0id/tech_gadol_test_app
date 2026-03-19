import 'package:flutter_test/flutter_test.dart';
import 'package:tech_gadol_test_app/data/models/product.dart';

void main() {
  group('Product Model Tests', () {
    test('should parse valid JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Phone',
        'description': 'A great phone',
        'price': 999.99,
        'discountPercentage': 10.0,
        'rating': 4.5,
        'stock': 50,
        'brand': 'TechBrand',
        'category': 'smartphones',
        'thumbnail': 'thumb.jpg',
        'images': ['img1.jpg', 'img2.jpg']
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Phone');
      expect(product.price, 999.99);
      expect(product.displayPrice, '\$999.99');
      expect(product.images.length, 2);
    });

    test('should handle missing fields with fallback default values', () {
      final json = <String, dynamic>{};
      final product = Product.fromJson(json);

      expect(product.id, 0);
      expect(product.title, 'Unknown Product');
      expect(product.brand, 'Unknown brand');
      expect(product.category, 'Uncategorized');
      expect(product.images, isEmpty);
    });

    test('should handle negative price by setting it to -1.0', () {
      final json = {
        'id': 2,
        'price': -50.0,
      };

      final product = Product.fromJson(json);

      expect(product.price, -1.0);
      expect(product.displayPrice, 'Price unavailable');
    });
  });
}