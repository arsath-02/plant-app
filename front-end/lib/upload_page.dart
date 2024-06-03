import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html; // Import html library for file picker
import 'dart:convert';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? _imageUrl;

  Future<void> getImage() async {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    await input.onChange.first;

    if (input.files!.isEmpty) return;
    final reader = html.FileReader();
    reader.readAsDataUrl(input.files!.first);
    await reader.onLoad.first;

    final bytes = reader.result as String;
    await uploadImage(input.files!.first, bytes.split(",").last);
  }

  Future<void> uploadImage(html.File imageFile, String base64Image) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://127.0.0.1:5000/predict')); // Ensure the URL is correct
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      base64.decode(base64Image),
      filename: imageFile.name,
    ));

    var res = await request.send();

    if (res.statusCode == 200) {
      var responseData = await res.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      setState(() {
        _imageUrl = jsonResponse['img_path'];
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(
                result: jsonResponse['prediction'], imageUrl: _imageUrl!)),
      );
    } else {
      var responseData = await res.stream.bytesToString();
      print('Error response: $responseData');
      throw Exception('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Center(
        child: _imageUrl == null
            ? Text('No image selected.')
            : Image.network(_imageUrl!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _imageUrl == null
                    ? null
                    : () async {
                        final input = html.FileUploadInputElement()
                          ..accept = 'image/*';
                        input.click();
                        await input.onChange.first;

                        if (input.files!.isEmpty) return;
                        final reader = html.FileReader();
                        reader.readAsDataUrl(input.files!.first);
                        await reader.onLoad.first;

                        final bytes = reader.result as String;
                        await uploadImage(
                            input.files!.first, bytes.split(",").last);
                      },
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String result;
  final String imageUrl;

  ResultPage({required this.result, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Result'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(result),
            SizedBox(height: 20),
            Image.network(imageUrl),
          ],
        ),
      ),
    );
  }
}
