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
    final result = await Process.run('su', []);
    return result.exitCode == 0;
  } catch (e) {
    debugPrint("Root access failed: $e");
    return false;
  }
}

Future<bool> showRootAccessDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Akses Root"),
            content: Text("Apakah Anda memerlukan akses root?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Tidak butuh root
                },
                child: Text("Tidak"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Butuh root
                },
                child: Text("Ya"),
              ),
            ],
          );
        },
      ) ??
      false; // Default jika dialog ditutup tanpa pilihan
}

Widget buildFileTile(FileSystemEntity entity, Function(Directory) onTapDir) {
  final isDirectory = entity is Directory;
  return ListTile(
    leading: Icon(
      isDirectory ? Icons.folder : Icons.insert_drive_file,
      color: isDirectory ? Colors.yellow : Colors.white,
    ),
    title: Text(
      entity.path.split('/').last,
      style: TextStyle(color: Color.fromARGB(255, 192, 201, 254)),
    ),
    onTap: isDirectory ? () => onTapDir(entity) : null,
  );
}
