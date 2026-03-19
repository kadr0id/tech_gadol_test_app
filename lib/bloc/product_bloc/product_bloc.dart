import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
part 'events.dart';
part 'states.dart';


EventTransformer<Event> debounce<Event>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;
  final int _limit = 20;

  ProductBloc({required this.repository}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<SearchProducts>(
      _onSearchProducts,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onFetchProducts(FetchProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded &&
        (state as ProductLoaded).hasReachedMax &&
        (state as ProductLoaded).category.isEmpty &&
        (state as ProductLoaded).searchQuery.isEmpty) {
      return;
    }

    try {
      if (state is ProductInitial ||
          state is ProductError ||
          (state is ProductLoaded && ((state as ProductLoaded).category.isNotEmpty || (state as ProductLoaded).searchQuery.isNotEmpty))) {

        List<String> existingCategories = state is ProductLoaded ? (state as ProductLoaded).categories : [];
        emit(ProductLoading());

        try {
          final response = await repository.getProducts(limit: _limit, skip: 0);
          final categories = existingCategories.isEmpty ? await repository.getCategories() : existingCategories;

          if (response.products.isEmpty) {
            emit(ProductEmpty());
          } else {
            emit(ProductLoaded(
              products: response.products,
              categories: categories,
              hasReachedMax: response.products.length >= response.total,
              isCached: false,
            ));
          }
        } catch (networkError) {
          try {
            final cachedResponse = await repository.getProducts(limit: _limit, skip: 0);
            emit(ProductLoaded(
              products: cachedResponse.products,
              categories: existingCategories,
              hasReachedMax: true,
              isCached: true,
            ));
          } catch (cacheError) {
            emit(const ProductError('No internet connection and no cached data available.'));
          }
        }
      }
      else if (state is ProductLoaded) {
        final currentState = state as ProductLoaded;
        if (currentState.isCached) return;

        final response = await repository.getProducts(limit: _limit, skip: currentState.products.length);

        if (response.products.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          final newTotalList = List<Product>.of(currentState.products)..addAll(response.products);
          emit(currentState.copyWith(
            products: newTotalList,
            hasReachedMax: newTotalList.length >= response.total,
          ));
        }
      }
    } catch (e) {
      emit(ProductError('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) async {
    if (event.query.isEmpty) {
      emit(ProductInitial());
      add(FetchProducts());
      return;
    }

    List<String> currentCategories = state is ProductLoaded ? (state as ProductLoaded).categories : [];
    emit(ProductLoading());

    try {
      final response = await repository.searchProducts(event.query);
      if (response.products.isEmpty) {
        emit(ProductEmpty());
      } else {
        emit(ProductLoaded(
          products: response.products,
          categories: currentCategories,
          searchQuery: event.query,
          hasReachedMax: true,
        ));
      }
    } catch (e) {
      emit(const ProductError('Failed to search products. Check your connection.'));
    }
  }

  Future<void> _onFilterByCategory(FilterByCategory event, Emitter<ProductState> emit) async {
    List<String> currentCategories = state is ProductLoaded ? (state as ProductLoaded).categories : [];
    emit(ProductLoading());

    try {
      final response = await repository.getProductsByCategory(event.category);
      if (response.products.isEmpty) {
        emit(ProductEmpty());
      } else {
        emit(ProductLoaded(
          products: response.products,
          categories: currentCategories,
          category: event.category,
          hasReachedMax: true,
        ));
      }
    } catch (e) {
      emit(const ProductError('Failed to filter by category.'));
    }
  }
}