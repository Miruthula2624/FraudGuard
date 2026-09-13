import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final ImagePicker _picker;

  ImagePickerHelper({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Pick an image from gallery
  Future<File?> pickFromGallery({int imageQuality = 85}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Capture a new photo from camera
  Future<File?> captureFromCamera({int imageQuality = 85}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
