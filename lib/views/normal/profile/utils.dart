import "package:image_picker/image_picker.dart";

pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  // ignore: no_leading_underscores_for_local_identifiers
  XFile? _file = await imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  // ignore: avoid_print
  print("No image was selected");
}
