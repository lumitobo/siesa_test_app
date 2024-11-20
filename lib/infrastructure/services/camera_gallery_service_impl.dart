import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../domain/services/camera_gallery_service.dart';

class CameraGalleryServiceImpl extends CameraGalleryService {

  final ImagePicker _picker = ImagePicker();

  @override
  Future<XFile?> selectPhoto() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      return pickedFile;
    }
    else{
      return null;
    }
  }



}
