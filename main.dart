import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(SkinCancerDetectorApp());
}

class SkinCancerDetectorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skin Cancer Detection',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SkinCancerHomePage(),
    );
  }
}

class SkinCancerHomePage extends StatefulWidget {
  @override
  _SkinCancerHomePageState createState() => _SkinCancerHomePageState();
}

class _SkinCancerHomePageState extends State<SkinCancerHomePage> {
  File? _image;
  String? _result;
  String? _heatmapUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _image = File(picked.path));
      await _uploadImage(File(picked.path));
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final uri = Uri.parse('http://<YOUR_FLASK_BACKEND_IP>:5000/predict');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    final data = jsonDecode(responseBody);
    setState(() {
      _result = data['prediction'];
      _heatmapUrl = data['heatmap_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Skin Cancer Detector')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Upload Image'),
          ),
          SizedBox(height: 20),
          if (_image != null) Image.file(_image!, height: 200),
          SizedBox(height: 20),
          if (_result != null) Text('Diagnosis: $_result', style: TextStyle(fontSize: 18)),
          if (_heatmapUrl != null)
            Column(children: [
              SizedBox(height: 10),
              Text('Grad-CAM Heatmap'),
              Image.network(_heatmapUrl!, height: 200),
            ]),
        ]),
      ),
    );
  }
}
