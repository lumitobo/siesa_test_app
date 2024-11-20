
import 'package:image_picker/image_picker.dart';

abstract class CameraGalleryService {

  Future<XFile?> selectPhoto();

}
