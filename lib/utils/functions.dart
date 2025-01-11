import 'dart:io';
import 'package:flutter/material.dart';

Future<List<FileSystemEntity>> initDirectory(
    Directory dir, BuildContext context) async {
  try {
    return dir.listSync();
  } catch (e) {
    debugPrint("Error accessing directory ${dir.path}: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error accessing directory: ${dir.path}")),
    );
    return [];
  }
}

Future<bool> requestRootAccess(BuildContext context) async {
  try {
    // Contoh sederhana untuk meminta akses root (gunakan implementasi su asli jika diperlukan)
    final result = await Process.run('su', []);
    return result.exitCode == 0;
  } catch (e) {
    debugPrint("Root access failed: $e");
    return false;
  }
}

Widget buildFileTile(FileSystemEntity entity, Function(Directory) onTapDir) {
  final isDirectory = entity is Directory;
  return ListTile(
    leading: Icon(isDirectory ? Icons.folder : Icons.insert_drive_file,
        color: isDirectory ? Colors.yellow : Colors.white),
    title: Text(
      entity.path.split('/').last,
      style: TextStyle(color: Colors.white),
    ),
    onTap: isDirectory ? () => onTapDir(entity) : null,
  );
}
