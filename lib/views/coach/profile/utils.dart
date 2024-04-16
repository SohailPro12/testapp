import "package:flutter/foundation.dart";
import "package:image_picker/image_picker.dart";

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? _file = await imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  // ignore: avoid_print
  print("No image was selected");
}

Future<Uint8List?> pickVideo(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  final XFile? file = await imagePicker.pickVideo(source: source);
  if (file != null) {
    return await file.readAsBytes();
  }
  return null;
}
