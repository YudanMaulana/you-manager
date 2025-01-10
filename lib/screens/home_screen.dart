import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Directory _currentDir;
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final hasPermission = await requestStoragePermission();
    if (hasPermission) {
      await _initDirectory();
    }
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      return true;
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permission denied. Please enable storage permission."),
        ),
      );
      return false;
    }
  }

  Future<void> _initDirectory() async {
    try {
      final Directory dir = Directory('/storage/emulated/0');
      setState(() {
        _currentDir = dir;
        _files = dir.listSync();
      });
      debugPrint("Directory: ${dir.path}");
    } catch (e) {
      debugPrint("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accessing directory: $e")),
      );
    }
  }

  void _navigateToDir(Directory dir) {
    setState(() {
      _currentDir = dir;
      _files = dir.listSync();
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentDir.parent.path != _currentDir.path) {
      _navigateToDir(_currentDir.parent);
      return false; // Jangan keluar aplikasi
    } else {
      return true; // Keluar aplikasi jika sudah di root
    }
  }

  Widget _buildFileTile(FileSystemEntity entity) {
    final isDir = entity is Directory;
    return ListTile(
      leading: Icon(
        isDir ? Icons.folder : Icons.insert_drive_file,
        color: Colors.white,
      ),
      title: Text(
        entity.path.split('/').last,
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        if (isDir) {
          _navigateToDir(entity);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 1,
          title: Text('You Manager', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
        ),
        body: Container(
          color: Colors.grey[900],
          child: _files.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada file atau direktori ditemukan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    return _buildFileTile(_files[index]);
                  },
                ),
        ),
      ),
    );
  }
}
