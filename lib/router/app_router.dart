import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/product_list_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../screens/showcase_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/products',
  routes: [
    GoRoute(
      path: '/products',
      builder: (context, state) => const ResponsiveCatalogScreen(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ProductDetailScreen(productId: int.parse(id));
          },
        ),
      ],
    ),
    GoRoute(
      path: '/showcase',
      builder: (context, state) => const ComponentShowcaseScreen(),
    ),
  ],
);

class ResponsiveCatalogScreen extends StatefulWidget {
  const ResponsiveCatalogScreen({super.key});

  @override
  State<ResponsiveCatalogScreen> createState() => _ResponsiveCatalogScreenState();
}

class _ResponsiveCatalogScreenState extends State<ResponsiveCatalogScreen> {
  int? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return Scaffold(
            appBar: AppBar(title: const Text('Catalog'),),
            body: Row(
              children: [
                SizedBox(
                  width: 350,
                  child: ProductListScreen(
                    onProductTap: (id) => setState(() => _selectedProductId = id),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _selectedProductId == null
                      ? const Center(child: Text('Select a product to view details'))
                      : ProductDetailScreen(productId: _selectedProductId!),
                ),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('Catalog'),  leading:
            IconButton(
              icon: const Icon(Icons.palette_outlined, color: Colors.green,),
              tooltip: 'Design System Showcase',
              onPressed: () {
                context.push('/showcase');
              },
            ),),
            body: ProductListScreen(
              onProductTap: (id) => context.go('/products/$id'),
            ),
          );
        }
      },
    );
  }
}