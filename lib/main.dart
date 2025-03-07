import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:qrshare/upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDWhxlbu2iCHZnyhdB1omCJsOtm-j88IBQ",
      authDomain: "qrshare-bd117.firebaseapp.com",
      projectId: "qrshare-bd117",
      storageBucket: "qrshare-bd117.firebasestorage.app",
      messagingSenderId: "332693437858",
      appId: "1:332693437858:web:b7e06360761442c050c6fb",
      measurementId: "G-GBHYVWGZ22",
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
