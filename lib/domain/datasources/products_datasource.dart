import '../entities/product.dart';


abstract class ProductsDatasource {

  Future<List<Product>> getProductsByPage({ int limit = 10, int offset = 0 });
  Future<Product> getProductById(int id);
  
  Future<Product> createUpdateProduct( Map<String,dynamic> productLike );
  Future<bool> eliminateProduct( int productID );


}

