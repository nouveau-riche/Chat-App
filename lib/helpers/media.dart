import 'dart:io';
import 'package:image_picker/image_picker.dart';

Future<File> ChosseImage() {
  return ImagePicker.pickImage(source: ImageSource.gallery);
}
