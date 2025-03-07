import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qrshare/upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(

    )
  );
  runApp(QRShareApp());
}

class QRShareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UploadScreen(),
    );
  }
}
