import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import 'products_repository_provider.dart';


final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {

  final productsRepository = ref.watch( productsRepositoryProvider );
  return ProductsNotifier(
    productsRepository: productsRepository
  );
  
});



class ProductsNotifier extends StateNotifier<ProductsState> {
  
  final ProductsRepository productsRepository;

  ProductsNotifier({
    required this.productsRepository
  }): super( ProductsState() ) {
    loadNextPage();
  }

  void buscarProducto(String busqueda) {
    List<Product> lista = state.products.where((producto) => producto.title.contains(busqueda)).toList();
    if(lista.length == state.products.length){
      state = state.copyWith(productsFiltred: [], search: '');
    }
    else{
      state = state.copyWith(productsFiltred: lista, search: busqueda.trim());
    }
  }

  Future<bool> createOrUpdateProduct( Map<String,dynamic> productLike ) async {

    try {
      final product = await productsRepository.createUpdateProduct(productLike);
      final isProductInList = state.products.any((element) => element.id == product.id );

      if ( !isProductInList ) {
        state = state.copyWith(
          products: [...state.products, product]
        );
        return true;
      }

      state = state.copyWith(
        products: state.products.map(
          (element) => ( element.id == product.id ) ? product : element,
        ).toList()
      );
      return true;

    } catch (e) {
      return false;
    }


  }

  Future<bool> eliminateProduct( int productID ) async {

    try {
      final productDeleted = await productsRepository.eliminateProduct(productID);

      if (productDeleted) {
        final updatedProducts = state.products.where((element) => element.id != productID).toList();
        state = state.copyWith(products: updatedProducts);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

  }


  Future loadNextPage() async {

    if ( state.isLoading || state.isLastPage ) return;

    state = state.copyWith( isLoading: true );


    final products = await productsRepository.getProductsByPage(limit: state.limit, offset: state.offset );

    if ( products.isEmpty ) {
      state = state.copyWith(
        isLoading: false,
        isLastPage: true
      );
      return;
    }

    state = state.copyWith(
      isLastPage: false,
      isLoading: false,
      offset: state.offset + 10,
      products: [...state.products, ...products ]
    );


  }

}



class ProductsState {

  final bool isLastPage;
  final int limit;
  final int offset;
  final bool isLoading;
  final List<Product> products;
  final List<Product> productsFiltred;
  final String search;

  ProductsState({
    this.isLastPage = false, 
    this.limit = 10, 
    this.offset = 0, 
    this.isLoading = false, 
    this.products = const[],
    this.productsFiltred = const[],
    this.search = '',

  });

  ProductsState copyWith({
    bool? isLastPage,
    int? limit,
    int? offset,
    bool? isLoading,
    List<Product>? products,
    List<Product>? productsFiltred,
    String? search,
  }) => ProductsState(
    isLastPage: isLastPage ?? this.isLastPage,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
    isLoading: isLoading ?? this.isLoading,
    products: products ?? this.products,
    productsFiltred: productsFiltred ?? this.productsFiltred,
    search: search ?? this.search,

  );

}
