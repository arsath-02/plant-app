import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'image_picker_stub.dart'
    if (dart.library.html) 'image_picker_web.dart'
    if (dart.library.io) 'image_picker_mobile.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String? _imageUrl;

  Future<void> getImage() async {
    await pickImage((base64Image, filename) async {
      final jsonResponse = await uploadImage(base64Image, filename);
      setState(() {
        _imageUrl = jsonResponse['img_path'];
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ResultPage(
                result: jsonResponse['prediction'], imageUrl: _imageUrl!)),
      );
    });
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
                onPressed: getImage,
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