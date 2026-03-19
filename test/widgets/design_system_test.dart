import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:tech_gadol_test_app/data/models/product.dart';
import 'package:tech_gadol_test_app/widgets/product_card.dart';
import 'package:tech_gadol_test_app/widgets/product_card_shimmer.dart';


void main() {
  final tProduct = Product(
    id: 1,
    title: 'Test Widget Phone',
    description: 'Desc',
    price: 299.99,
    discountPercentage: 0,
    rating: 4.0,
    stock: 5,
    brand: 'TestBrand',
    category: 'smartphones',
    thumbnail: 'http://example.com/image.jpg',
    images: [],
  );

  group('Design System Widget Tests', () {
    testWidgets('ProductCard displays correct information and registers taps', (WidgetTester tester) async {
      bool wasTapped = false;

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(
                product: tProduct,
                onTap: () {
                  wasTapped = true;
                },
              ),
            ),
          ),
        );
      });

      expect(find.text('Test Widget Phone'), findsOneWidget);
      expect(find.text('TestBrand'), findsOneWidget);
      expect(find.text('\$299.99'), findsOneWidget);
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();
      expect(wasTapped, true);
    });

    testWidgets('ProductCardShimmer renders without throwing errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductCardShimmer(),
          ),
        ),
      );

      expect(find.byType(ProductCardShimmer), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}