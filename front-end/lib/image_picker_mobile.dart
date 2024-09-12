import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> pickImage(
    Function(String base64Image, String filename) onSelected) async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return;

  final bytes = File(pickedFile.path).readAsBytesSync();
  final base64Image = base64Encode(bytes);
  onSelected(base64Image, pickedFile.name);
}

Future<Map<String, dynamic>> uploadImage(
    String base64Image, String filename) async {
  var request = http.MultipartRequest(
      'POST', Uri.parse('https://plant-app-c5q6.onrender.com/predict'));
  request.files.add(http.MultipartFile.fromBytes(
    'file',
    base64.decode(base64Image),
    filename: filename,
  ));

  var res = await request.send();
  if (res.statusCode == 200) {
    var responseData = await res.stream.bytesToString();
    var jsonResponse = json.decode(responseData);
    return jsonResponse;
  } else {
    throw Exception('Failed to upload image');
  }
}
