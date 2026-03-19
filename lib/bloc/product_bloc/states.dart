part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductEmpty extends ProductState {}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<String> categories;
  final bool hasReachedMax;
  final String searchQuery;
  final String category;
  final bool isCached;

  const ProductLoaded({
    required this.products,
    this.categories = const [],
    this.hasReachedMax = false,
    this.searchQuery = '',
    this.category = '',
    this.isCached = false,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<String>? categories,
    bool? hasReachedMax,
    String? searchQuery,
    String? category,
    bool? isCached,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      category: category ?? this.category,
      isCached: isCached ?? this.isCached,
    );
  }

  @override
  List<Object?> get props => [
    products,
    categories,
    hasReachedMax,
    searchQuery,
    category,
    isCached,
  ];
}