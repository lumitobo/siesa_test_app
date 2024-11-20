import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


import '../../domain/entities/product.dart';
import '../../infrastructure/services/camera_gallery_service_impl.dart';
import '../providers/forms/product_form_provider.dart';
import '../providers/product_provider.dart';
import '../providers/products_provider.dart';
import '../shared/widgets/custom_dropdown_form_field.dart';
import '../shared/widgets/custom_filled_button.dart';
import '../shared/widgets/custom_product_field.dart';
import '../shared/widgets/full_screen_loader.dart';



class ProductScreen extends ConsumerWidget {
  final String productId;

  const ProductScreen({super.key, required this.productId});

  void showSnackbar( BuildContext context, String message ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {


    if(productId == 'no-id'){
      return const Center(child: Text("No existe un producto con ese ID"));
    }

    final productState = ref.watch( productProvider(int.parse(productId)) );
    final isLoading = productState.product != null ? ref.watch( productFormProvider(productState.product!)).isLoading : false;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(int.parse(productId) == 0 ? 'Crear Producto' : 'Editar Producto'),
          actions: [

            IconButton(
              icon: const Icon( Icons.add_photo_alternate_rounded ),
              onPressed: () async {
              final photoPath = await CameraGalleryServiceImpl().selectPhoto();
              if ( photoPath == null ) return;

              try {
                ref.read( productFormProvider(productState.product!).notifier ).uploadImage(photoPath);
              } catch (e) {
                showSnackbar(context, 'Ha ocurrido un error al subir la imagen.');
              }

            }),

          ],
        ),
        body: productState.isLoading ? const FullScreenLoader() : _ProductView(product: productState.product! ),
        floatingActionButton: FloatingActionButton.extended(
          label:  isLoading ? const CircularProgressIndicator() : const Text('Guardar'),
          icon:  isLoading ? null : const Icon( Icons.save_as_outlined ),
          onPressed: () {
            if ( productState.product == null  || productState.isLoading) return;
            ref.read(
                productFormProvider(productState.product!).notifier
            ).onFormSubmit()
                .then((value) {
              if ( !value ) {
                String errorMessage = ref.read(productFormProvider(productState.product!)).errorMessage;
                if(errorMessage!= ''){
                  showSnackbar(context, errorMessage);
                }
                return;
              }
              showSnackbar(context, int.parse(productId) == 0 ? 'Producto Creado' : 'Producto Actualizado');
              context.pop();
            });
          },
        ),
      ),
    );
  }
}


class _ProductView extends ConsumerWidget {

  final Product product;

  const _ProductView({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final productForm = ref.watch( productFormProvider(product));
    final textStyles = Theme.of(context).textTheme;

    return ListView(
      children: [

          SizedBox(
            height: 250,
            width: 600,
            child: _ImageGallery(images: productForm.images ),
          ),

          const SizedBox( height: 10),
          Center(
            child: Text(
              productForm.title.value,
              style: textStyles.titleLarge,
              textAlign: TextAlign.center,
            )
          ),
          const SizedBox( height: 10 ),
          _ProductInformation( product: product ),

        ],
    );
  }
}

class _ProductInformation extends ConsumerWidget {
  final Product product;
  const _ProductInformation({required this.product});

  void openDialog(BuildContext parentContext, WidgetRef ref, int productID) {
    showDialog(
      context: parentContext,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text("Se borrará toda la información de este producto.", style: TextStyle(fontSize: 14.0)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.black),),
            ),
            FilledButton(
              style:ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.red)),
              child: const Text('Si, eliminar producto'),
              onPressed: ()  {
                Navigator.of(dialogContext).pop();
                ref.read(productsProvider.notifier).eliminateProduct(productID);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref ) {

    final productForm = ref.watch( productFormProvider(product) );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15 ),
          const Text('Información general', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 15 ),
          CustomDropdownFormField(
            isTopField: true,
            enabled: !(productForm.id != 0 && productForm.id != null), // La api no actualiza la categoria de un producto ya creado
            label: "Categoria",
            value: productForm.category.toString(),
            maxTextLength: 24,
            items: [
              DropdownMenuItem(value: "1", child: Text('Ropa', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)))),
              DropdownMenuItem(value: '2', child: Text('Electrónica', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)))),
              DropdownMenuItem(value: '3', child: Text('Muebles', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)))),
              DropdownMenuItem(value: '4', child: Text('Zapatos', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)))),
              DropdownMenuItem(value: '5', child: Text('Misceláneos', style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.7)))),
            ],
            onChanged: (value) {
              ref.read( productFormProvider(product).notifier).onCategory(value!);
            },
          ),
          const SizedBox(height: 10 ),
          CustomProductField(
            label: 'Nombre',
            initialValue: productForm.title.value,
            onChanged: ref.read( productFormProvider(product).notifier).onTitleChanged,
            errorMessage: productForm.isFormPosted ? productForm.title.errorMessage: null,
          ),
          const SizedBox(height: 10 ),

          CustomProductField(
            label: 'Precio',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            initialValue: productForm.price.value.toString(),
            onChanged: (value) => ref.read( productFormProvider(product).notifier).onPriceChanged( double.tryParse(value) ?? -1 ),
            errorMessage: productForm.isFormPosted ? productForm.price.errorMessage: null,
          ),

          const SizedBox(height: 10 ),

          CustomProductField(
            isBottomField: true,
            maxLines: 6,
            label: 'Descripción',
            keyboardType: TextInputType.multiline,
            initialValue: productForm.description.value.toString(),
            onChanged: ref.read( productFormProvider(product).notifier).onDescriptionChanged,
            errorMessage: productForm.isFormPosted ? productForm.description.errorMessage: null,
          ),

          const SizedBox(height: 10 ),

          if(productForm.id != 0 && productForm.id != null)
          SizedBox(
            width: double.infinity,
            child: CustomFilledButton(
              buttonColor: Colors.red,
              onPressed: () {
                openDialog(context, ref, productForm.id!);
              },
              text: 'Eliminar producto'
            ),
          ),
          const SizedBox(height: 100 ),


        ],
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {

    if ( images.isEmpty ) {
      return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Image.asset('assets/images/no-image.jpg', fit: BoxFit.cover )

    );
    }


    return PageView(
      scrollDirection: Axis.horizontal,
      controller: PageController(
          viewportFraction: 0.7
      ),
      children: images.map((image){

        late ImageProvider imageProvider;
        if ( image.startsWith('http') ) {
          imageProvider = NetworkImage(image);
        } else {
          imageProvider = FileImage( File(image) );
        }

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FadeInImage(
              fit: BoxFit.cover,
              height: 250,
              fadeOutDuration: const Duration(milliseconds: 50),
              fadeInDuration: const Duration(milliseconds: 50),
              image: imageProvider,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/no-image.jpg',
                  fit: BoxFit.cover,
                  height: 250,
                );
              },
              placeholder: const AssetImage('assets/loaders/puntos_loading.gif'),
            ),
          ),
        );


      }).toList(),
    );
  }
}