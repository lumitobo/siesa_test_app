import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:siesa_app/presentation/screens/product_screen.dart';

import '../providers/products_provider.dart';
import '../shared/widgets/product_card.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      // drawer: SideMenu( scaffoldKey: scaffoldKey ),
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: const _ProductsView(),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Nuevo producto'),
        icon: const Icon( Icons.add ),
        onPressed: () {
          context.push('/product/0');
        },
      ),
    );
  }
}


class _ProductsView extends ConsumerStatefulWidget {
  const _ProductsView();

  @override
  _ProductsViewState createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState {

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    scrollController.addListener(() {
      if ( (scrollController.position.pixels + 400) >= scrollController.position.maxScrollExtent ) {
        ref.read(productsProvider.notifier).loadNextPage();
      }
    });

  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget buildEmpty() => const Center(child: Text("No hay productos."));

  @override
  Widget build(BuildContext context) {

    final productsState = ref.watch( productsProvider );
    final listado = productsState.productsFiltred.isNotEmpty ? productsState.productsFiltred : productsState.products;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(

        children: [
          // Descarté la busqueda por que el funcionamiento era con los productos que estaban ya precargados
          // Container(
          //   color: Theme.of(context).scaffoldBackgroundColor,
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 8),
          //     child: TextField(
          //       decoration: InputDecoration(
          //         contentPadding: const EdgeInsets.symmetric(vertical: 10),
          //         hintText: 'Buscar un producto',
          //         prefixIcon: const Icon(Icons.search),
          //         border: OutlineInputBorder(
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //       ),
          //       onChanged: ref.read(productsProvider.notifier).buscarProducto,
          //     ),
          //   ),
          // ),
          Expanded(
            child: MasonryGridView.count(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 35,
              itemCount: listado.length,
              itemBuilder: (context, index) {
                final product = listado[index];
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.85,
                          child: ProductScreen(productId: product.id.toString() ,),
                        );
                      },
                      elevation: 5,
                      useSafeArea: true,
                    );
                  },
                  child: ProductCard(product: product)
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

