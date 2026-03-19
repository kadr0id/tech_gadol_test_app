import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc/product_bloc.dart';
import '../widgets/widgets.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final Function(int) onProductTap;

  const ProductListScreen({super.key, required this.onProductTap});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductBloc>().add(FetchProducts());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              context.read<ProductBloc>().add(SearchProducts(value));
            },
          ),
        ),
        BlocBuilder<ProductBloc, ProductState>(
          buildWhen: (previous, current) => current is ProductLoaded,
          builder: (context, state) {
            if (state is ProductLoaded && state.categories.isNotEmpty) {
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: state.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isAllSelected = state.category.isEmpty;
                      return _buildCategoryChip(context, 'All', isSelected: isAllSelected);
                    }
                    final category = state.categories[index - 1];
                    return _buildCategoryChip(context, category, isSelected: state.category == category);
                  },
                ),
              );
            }
            return const SizedBox(height: 50);
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductInitial || state is ProductLoading) {
                return ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, index) => const ProductCardShimmer(),
                );
              }
              else if (state is ProductError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ProductBloc>().add(FetchProducts()),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                );
              }
              else if (state is ProductEmpty) {
                return const Center(child: Text('No products found.', style: TextStyle(fontSize: 16, color: Colors.grey)));
              }
              else if (state is ProductLoaded) {
                final products = state.products;
                return Column(
                  children: [
                    if (state.isCached)
                      Container(
                        width: double.infinity,
                        color: Colors.orange.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade900),
                            const SizedBox(width: 8),
                            Text(
                              'Offline Mode: Viewing cached data',
                              style: TextStyle(color: Colors.orange.shade900, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: state.hasReachedMax ? products.length : products.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= products.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () => widget.onProductTap(product.id),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, {bool isSelected = false}) {
    final displayLabel = label == 'All' ? 'All' : label.replaceAll('-', ' ');
    final capitalizedLabel = displayLabel.isNotEmpty
        ? displayLabel[0].toUpperCase() + displayLabel.substring(1)
        : displayLabel;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(capitalizedLabel),
        selected: isSelected,
        onSelected: (bool selected) {
          if (label == 'All') {
            context.read<ProductBloc>().add(FetchProducts());
          } else {
            context.read<ProductBloc>().add(FilterByCategory(label));
          }
        },
      ),
    );
  }
}


class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.withValues(alpha: 0.2);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        color: Colors.white,
        colorOpacity: 0.3,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: double.infinity, height: 16, color: baseColor),
                    const SizedBox(height: 8),
                    Container(width: 120, height: 12, color: baseColor),
                    const SizedBox(height: 16),
                    Container(width: 80, height: 18, color: baseColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}