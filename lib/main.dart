import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(FileManagerApp());
}

class FileManagerApp extends StatelessWidget {
  const FileManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Manager',
      home: HomeScreen(),
    );
  }
}
