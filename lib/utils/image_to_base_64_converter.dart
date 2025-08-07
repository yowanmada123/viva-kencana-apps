import 'dart:convert';
import 'dart:io';

Future<String> imageToBase64(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  return base64Encode(bytes); // Raw base64
}

Future<String> imageToDataUri(File imageFile) async {
  final base64String = await imageToBase64(imageFile);
  final mime = _getMimeType(imageFile); // Helper function
  return "data:$mime;base64,$base64String";
}

String _getMimeType(File file) {
  final extension = file.path.split('.').last.toLowerCase();
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'gif':
      return 'image/gif';
    case 'bmp':
      return 'image/bmp';
    case 'webp':
      return 'image/webp';
    default:
      return 'application/octet-stream'; // fallback
  }
}
