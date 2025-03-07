import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/services.dart'; // Import for clipboard

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String? _qrData;
  ScreenshotController screenshotController = ScreenshotController();

  // Method to pick a file and upload to Firebase
  Future<void> _pickAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('uploads/${file.name}');

      UploadTask uploadTask;

      if (file.bytes != null) {
        // For web, use bytes
        uploadTask = ref.putData(file.bytes!);
      } else if (file.path != null) {
        // For mobile, use file path
        File localFile = File(file.path!);
        uploadTask = ref.putFile(localFile);
      } else {
        print("Error: file.bytes and file.path are both null!");
        return;
      }

      await uploadTask.whenComplete(() async {
        String downloadUrl = await ref.getDownloadURL();
        print("Download URL: $downloadUrl");

        setState(() {
          _qrData = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File uploaded successfully!'))
        );
      });
    }
  }

  // Method to copy the QR code URL to clipboard
  Future<void> _copyQRToClipboard() async {
    if (_qrData != null) {
      await Clipboard.setData(ClipboardData(text: _qrData!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code copied to clipboard!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No QR code available to copy!')),
      );
    }
  }

  // Method to save the QR code to the gallery
  Future<void> _saveQRToGallery() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = File('${directory.path}/qr_code.png');

      // Capture QR code as an image
      await screenshotController.captureAndSave(
        directory.path,
        fileName: 'qr_code.png',
      );

      // Save to gallery
      await GallerySaver.saveImage(imagePath.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code saved to gallery!')),
      );
    } catch (e) {
      print('Error saving QR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save QR Code!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('QR Share')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickAndUploadFile,
              child: Text('Upload File'),
            ),
            SizedBox(height: 20),
            _qrData != null
                ? Column(
                    children: [
                      Text('Scan this QR to download:'),
                      GestureDetector(
                        onLongPress: _copyQRToClipboard, // Copy QR to clipboard on long press
                        child: Screenshot(
                          controller: screenshotController,
                          child: QrImageView(
                            data: _qrData!,
                            size: 200,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _saveQRToGallery,
                        child: Text('Save QR Code'),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
