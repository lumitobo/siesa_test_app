
import '../../domain/entities/product.dart';

class ProductMapper {


  static jsonToEntity( Map<String, dynamic> json ) => Product(
    id: json['id'],
    category: json['category']["id"],
    title: json['title'],
    price: double.parse( json['price'].toString() ),
    description: json['description'],
    images: _cleanImages(json['images']),

  );

  static List<String> _cleanImages(List<dynamic> images) {
    return images.map<String>((image) {
      String cleanedImage = image.toString().replaceAll(RegExp(r'[\[\]\"]'), '');
      return cleanedImage;
    }).toList();
  }

}
