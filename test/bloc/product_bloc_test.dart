import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tech_gadol_test_app/bloc/product_bloc/product_bloc.dart';
import 'package:tech_gadol_test_app/data/models/product.dart';
import 'package:tech_gadol_test_app/data/repositories/product_repository.dart';



class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ProductBloc productBloc;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    productBloc = ProductBloc(repository: mockRepository);
  });

  tearDown(() {
    productBloc.close();
  });

  final tProduct = Product(
    id: 1,
    title: 'Mock Product',
    description: 'Desc',
    price: 100.0,
    discountPercentage: 0,
    rating: 5.0,
    stock: 10,
    brand: 'Brand',
    category: 'Category',
    thumbnail: '',
    images: [],
  );

  final tResponse = ProductResponse(
    products: [tProduct],
    total: 1,
    skip: 0,
    limit: 20,
  );

  group('ProductBloc Tests', () {
    test('initial state should be ProductInitial', () {
      expect(productBloc.state, ProductInitial());
    });

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductLoaded] when FetchProducts is successful',
      build: () {
        when(() => mockRepository.getProducts(limit: any(named: 'limit'), skip: any(named: 'skip')))
            .thenAnswer((_) async => tResponse);
        when(() => mockRepository.getCategories())
            .thenAnswer((_) async => ['Category']);
        return productBloc;
      },
      act: (bloc) => bloc.add(FetchProducts()),
      expect: () => [
        ProductLoading(),
        ProductLoaded(
          products: [tProduct],
          categories: const ['Category'],
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when FetchProducts fails',
      build: () {
        when(() => mockRepository.getProducts(limit: any(named: 'limit'), skip: any(named: 'skip')))
            .thenThrow(Exception('API Error'));
        return productBloc;
      },
      act: (bloc) => bloc.add(FetchProducts()),
      expect: () => [
        ProductLoading(),
        ProductError('Failed to fetch products: Exception: API Error'),
      ],
    );
  });
}