import 'package:dio/dio.dart';

import '../../config/constants/environment.dart';
import '../../domain/datasources/products_datasource.dart';
import '../../domain/entities/product.dart';
import '../errors/product_errors.dart';
import '../mappers/product_mapper.dart';


class ProductsDatasourceImpl extends ProductsDatasource {

  late final Dio dio;

  ProductsDatasourceImpl() : dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiURL,
    )
  );


  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) async {
    
    try {
      
      final int? productId = productLike['id'];
      final String method = (productId == null) ? 'POST' : 'PUT';
      final String url = (productId == null) ? '/products' : '/products/$productId';

      productLike.remove('id');

      final response = await dio.request(
        url,
        data: productLike,
        options: Options(
          method: method
        )
      );

      final product = ProductMapper.jsonToEntity(response.data);
      return product;

    } catch (e) {
      throw ProductNotFound("Error en la solicitud: $e");
    }


  }

  @override
  Future<Product> getProductById(int id) async {
    
    try {
      
      final response = await dio.get('/products/$id');
      final product = ProductMapper.jsonToEntity(response.data);
      return product;

    } on DioException catch (e) {
      if ( e.response!.statusCode == 404 ) throw ProductNotFound(e.response!.statusMessage!);
      throw Exception();

    }catch (e) {
      throw Exception();
    }

  }

  @override
  Future<List<Product>> getProductsByPage({int limit = 5, int offset = 0}) async {
    final response = await dio.get<List>('/products?limit=$limit&offset=$offset');
    final List<Product> products = [];
    for (final product in response.data ?? [] ) {
      products.add(  ProductMapper.jsonToEntity(product)  );
    }

    return products;
  }

  @override
  Future<bool> eliminateProduct(int productID) async{

    try {

      final response = await dio.delete('/products/$productID');
      if(response.statusCode == 200 ){
        return true;
      }
      return false;

    } on DioException catch (e) {
      return false;

    }catch (e) {
      return false;
    }
  }

}