import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product.dart';
import '../bloc/theme_cubit/theme_cubit.dart';
import '../widgets/product_card.dart';
import '../widgets/product_card_shimmer.dart';


class ComponentShowcaseScreen extends StatelessWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Components Showcase'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle(context, 'Typography'),
          Text('Headline Small', style: Theme.of(context).textTheme.headlineSmall),
          Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
          Text('Body Medium', style: Theme.of(context).textTheme.bodyMedium),
          Text('Body Small (Grey)', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const Divider(height: 32),

          _buildSectionTitle(context, 'Buttons'),
          ElevatedButton(onPressed: () {}, child: const Text('Elevated Button')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () {}, child: const Text('Outlined Button')),
          const SizedBox(height: 8),
          TextButton(onPressed: () {}, child: const Text('Text Button')),
          const Divider(height: 32),

          _buildSectionTitle(context, 'Category Chips'),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text('Selected'), selected: true, onSelected: (_) {}),
              ChoiceChip(label: const Text('Unselected'), selected: false, onSelected: (_) {}),
            ],
          ),
          const Divider(height: 32),

          _buildSectionTitle(context, 'Loading States'),
          const ProductCardShimmer(),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const Divider(height: 32),

          _buildSectionTitle(context, 'Product Card (Normal)'),
          ProductCard(
            product: _getDummyProduct(),
            onTap: () {},
          ),
          const Divider(height: 32),

          _buildSectionTitle(context, 'Product Card (Out of Stock / Error Data)'),
          ProductCard(
            product: _getDummyProduct(price: -1.0), // Негативна ціна для перевірки валідації
            onTap: () {},
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Product _getDummyProduct({double price = 999.99}) {
    return Product(
      id: 0,
      title: 'Showcase Premium Phone',
      description: 'Dummy description for showcase',
      price: price,
      discountPercentage: 12.5,
      rating: 4.8,
      stock: 50,
      brand: 'TechBrand',
      category: 'smartphones',
      thumbnail: 'https://via.placeholder.com/150',
      images: [],
    );
  }
}