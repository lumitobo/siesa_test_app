import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/products_repository.dart';
import '../../infrastructure/datasources/products_datasource_impl.dart';
import '../../infrastructure/repositories/products_repository_impl.dart';


final productsRepositoryProvider = Provider<ProductsRepository>((ref) {

  
  final productsRepository = ProductsRepositoryImpl(ProductsDatasourceImpl());

  return productsRepository;
});

