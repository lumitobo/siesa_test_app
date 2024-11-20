import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siesa_app/infrastructure/inputs/description.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constants/environment.dart';
import '../../../domain/entities/product.dart';
import '../../../infrastructure/inputs/price.dart';
import '../../../infrastructure/inputs/title.dart';
import '../products_provider.dart';




final productFormProvider = StateNotifierProvider.autoDispose.family<ProductFormNotifier, ProductFormState, Product>(
  (ref, product) {

    final createUpdateCallback = ref.watch( productsProvider.notifier ).createOrUpdateProduct;

    return ProductFormNotifier(
      product: product,
      onSubmitCallback: createUpdateCallback,
    );
  }
);




class ProductFormNotifier extends StateNotifier<ProductFormState> {

  final Future<bool> Function( Map<String,dynamic> productLike )? onSubmitCallback;

  ProductFormNotifier({
    this.onSubmitCallback,
    required Product product,
  }): super(
    ProductFormState(
      id: product.id,
      category: product.category,
      title: Title.dirty(product.title),
      price: Price.dirty(product.price),
      description: Description.dirty(product.description),
      images: product.images,
    )
  );

  Future<void> uploadImage(XFile imageFile) async {
    try {
      state = state.copyWith(isLoading: true);
      final response = await Supabase.instance.client.storage.from('siesa_test_app').upload('images/${imageFile.name}', File(imageFile.path));

      updateProductImage("${Environment.supabaseURL}/storage/v1/object/public/$response");
    } catch (e) {
      if (e is StorageException && e.statusCode == "409" && e.message == "The resource already exists") {
        updateProductImage("${Environment.supabaseURL}/storage/v1/object/public/siesa_test_app/images/${imageFile.name}");
      }
      else{
        state = state.copyWith(isLoading: false);
        rethrow;
      }

    }
  }

  Future<bool> onFormSubmit() async {
    _touchedEverything();
    if ( !state.isFormValid ) return false;

    if ( onSubmitCallback == null ) return false;

    final productLike = {
      'id' : state.id == 0 ? null : state.id,
      'title': state.title.value,
      'price': state.price.value,
      'categoryId': state.category,
      'description': state.description.value,
      'images': state.images
    };

    try {
      // return await onSubmitCallback!( productLike );

      bool? productoCreado = await onSubmitCallback!( productLike );
      if(productoCreado == false){
        state = state.copyWith(isLoading: false, errorMessage: "Ha ocurrido un error al crear el producto.");
      }
      return productoCreado;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());

      return false;
    }

  }

  void _touchedEverything() {
    final hasImages = state.images.isNotEmpty;

    final isFormValid = Formz.validate([
      Title.dirty(state.title.value),
      Price.dirty(state.price.value),
      Description.dirty(state.description.value),
    ]) && hasImages;

    final errorMessage = hasImages ? '' : 'Debe agregar al menos una imagen';

    state = state.copyWith(
      isFormPosted: true,
      errorMessage: errorMessage,
      isFormValid: isFormValid,
    );
  }

  void onTitleChanged( String value ) {
    state = state.copyWith(
      title: Title.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(value),
        Price.dirty(state.price.value),
        Description.dirty(state.description.value),
      ])
    );
  }

  void onPriceChanged( double value ) {
    state = state.copyWith(
      price: Price.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Price.dirty(value),
        Description.dirty(state.description.value),
      ])
    );
  }

  void onDescriptionChanged( String value ) {
    state = state.copyWith(
      description: Description.dirty(value),
      isFormValid: Formz.validate([
        Title.dirty(state.title.value),
        Price.dirty(state.price.value),
        Description.dirty(value),
      ])
    );

  }

  void onCategory( String category ) {
    state = state.copyWith(
      category: int.parse(category)
    );
  }

  void updateProductImage( String path ) {
    state = state.copyWith(
      images: [...state.images, path ],
      isLoading: false

    );
  }



}


class ProductFormState {

  final bool isFormValid;
  final int? id;
  final Title title;
  final Price price;
  final int category;
  final Description description;
  final List<String> images;
  final bool isFormPosted;
  final bool isLoading;
  final String errorMessage;


  ProductFormState({
    this.isFormValid = false,
    this.id,
    this.title = const Title.dirty(''),
    this.price = const Price.dirty(1.0),
    this.category = 1,
    this.description = const Description.dirty(''),
    this.images = const[],
    this.isFormPosted = false,
    this.isLoading = false,
    this.errorMessage = '',
  });

  ProductFormState copyWith({
    bool? isFormValid,
    int? id,
    Title? title,
    Price? price,
    int? category,
    Description? description,
    List<String>? images,
    bool? isFormPosted,
    bool? isLoading,
    String? errorMessage,
  }) => ProductFormState(
    isFormValid: isFormValid ?? this.isFormValid,
    id: id ?? this.id,
    title: title ?? this.title,
    price: price ?? this.price,
    category: category ?? this.category,
    description: description ?? this.description,
    images: images ?? this.images,
    isFormPosted: isFormPosted ?? this.isFormPosted,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );


}