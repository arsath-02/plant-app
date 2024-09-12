import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> pickImage(
    Function(String base64Image, String filename) onSelected) async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();
  await input.onChange.first;

  if (input.files!.isEmpty) return;

  final reader = html.FileReader();
  reader.readAsDataUrl(input.files!.first);
  await reader.onLoad.first;

  final bytes = reader.result as String;
  onSelected(bytes.split(',').last, input.files!.first.name);
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
