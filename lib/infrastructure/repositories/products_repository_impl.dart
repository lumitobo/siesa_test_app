
import '../../domain/datasources/products_datasource.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/products_repository.dart';



class ProductsRepositoryImpl extends ProductsRepository {

  final ProductsDatasource datasource;

  ProductsRepositoryImpl(this.datasource);


  @override
  Future<Product> createUpdateProduct(Map<String, dynamic> productLike) {
    return datasource.createUpdateProduct(productLike);
  }

  @override
  Future<Product> getProductById(int id) {
    return datasource.getProductById(id);
  }

  @override
  Future<bool> eliminateProduct(int id) {
    return datasource.eliminateProduct(id);
  }


  @override
  Future<List<Product>> getProductsByPage({int limit = 10, int offset = 0}) {
    return datasource.getProductsByPage( limit: limit, offset: offset );
  }


}