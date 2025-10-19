// uploadscreen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadScreen extends StatefulWidget {
  final String token;
  UploadScreen({required this.token});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  String _result = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _result = '';
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    setState(() => _isUploading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.161.224.1:5079/api/Prediction/upload'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', _selectedFile!.path));
      request.headers['Authorization'] = 'Bearer ${widget.token}';

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        setState(() {
          _result =
          'Type: ${data['result']}\nConfidence: ${(data['confidence']).toStringAsFixed(2)}%';
        });
      } else if (response.statusCode == 401) {
        setState(() => _result = 'Unauthorized! Please login again.');
      } else {
        setState(() => _result = 'Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _result = 'Upload error: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Upload Lung Scan'),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.deepPurple[300],
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _showPickerOptions,
                  icon: Icon(Icons.add_a_photo),
                  label: Text('Select Image'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 20),
                _selectedFile != null
                    ? Image.file(_selectedFile!, width: 250, height: 250, fit: BoxFit.cover)
                    : Text('No file selected', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 20),
                _isUploading
                    ? CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton(
                  onPressed: _uploadFile,
                  child: Text('Upload Scan'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                ),
                const SizedBox(height: 20),
                if (_result.isNotEmpty)
                  Card(
                    color: Colors.white70,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _result,
                        style: TextStyle(color: Colors.deepPurple[900], fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
