import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';
import '../../infrastructure/datasources/products_datasource_impl.dart';
import '../../infrastructure/repositories/products_repository_impl.dart';


final productProvider = StateNotifierProvider.autoDispose.family<ProductNotifier, ProductState, int>(
  (ref, productId ) {
    
    final productsRepository = ProductsRepositoryImpl(ProductsDatasourceImpl());
  
    return ProductNotifier(
      productsRepository: productsRepository, 
      productId: productId
    );
});



class ProductNotifier extends StateNotifier<ProductState> {

  final ProductsRepository productsRepository;


  ProductNotifier({
    required this.productsRepository,
    required int productId,
  }): super(ProductState(id: productId )) {
    loadProduct();
  }

  Product newEmptyProduct() {
    return Product(
      id: 0,
      title: '', 
      price: 1,
      category: 1,
      description: '',
      images: [],
    );
  }


  Future<void> loadProduct() async {

    try {

      if ( state.id == 0 ) {
        state = state.copyWith(
          isLoading: false,
          product: newEmptyProduct(),
        );  
        return;
      }

      final product = await productsRepository.getProductById(state.id);

      state = state.copyWith(
        isLoading: false,
        product: product
      );

    } catch (e) {
      // 404 product not found
      print(e);
    }

  }

}


class ProductState {

  final int id;
  final Product? product;
  final bool isLoading;
  final bool isSaving;

  ProductState({
    required this.id, 
    this.product, 
    this.isLoading = true, 
    this.isSaving = false,
  });

  ProductState copyWith({
    int? id,
    Product? product,
    bool? isLoading,
    bool? isSaving,
  }) => ProductState(
    id: id ?? this.id,
    product: product ?? this.product,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
  );
  
}

