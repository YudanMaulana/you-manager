import 'dart:io';
import 'package:flutter/material.dart';
import 'package:you_manager/utils/functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Directory _nonRootDir;
  late Directory _rootDir;
  List<FileSystemEntity> _nonRootFiles = [];
  List<FileSystemEntity> _rootFiles = [];
  bool _hasRootAccess = false;
  String _activePanel = 'nonRoot'; // Default panel aktif adalah non-root

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _nonRootDir = Directory('/storage/emulated/0');
    _rootDir = Directory('/');
    _nonRootFiles = await initDirectory(_nonRootDir, context);
    _hasRootAccess = await requestRootAccess(context);
    if (_hasRootAccess) {
      _rootFiles = await initDirectory(_rootDir, context);
    }
    setState(() {});
  }

  void _updateNonRootFiles(Directory dir) async {
    _nonRootFiles = await initDirectory(dir, context);
    setState(() {
      _nonRootDir = dir;
    });
  }

  void _updateRootFiles(Directory dir) async {
    _rootFiles = await initDirectory(dir, context);
    setState(() {
      _rootDir = dir;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_activePanel == 'nonRoot') {
          // Navigasi untuk panel non-root
          if (_nonRootDir.path != '/storage/emulated/0') {
            _updateNonRootFiles(_nonRootDir.parent);
            return false;
          }
        } else if (_activePanel == 'root') {
          // Navigasi untuk panel root
          if (_rootDir.path != '/') {
            _updateRootFiles(_rootDir.parent);
            return false;
          }
        }
        return true; // Keluar aplikasi jika tidak ada navigasi lebih lanjut
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text('You Manager', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
        ),
        body: Row(
          children: [
            // Panel Kiri: Non-root
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activePanel = 'nonRoot';
                  });
                },
                child: Container(
                  color: _activePanel == 'nonRoot'
                      ? Colors.grey[850]
                      : Colors.grey[900],
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Non-root Directory',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      Expanded(
                        child: _nonRootFiles.isEmpty
                            ? Center(
                                child: Text(
                                  'Tidak ada file atau direktori ditemukan',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _nonRootFiles.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _activePanel = 'nonRoot';
                                      });
                                      if (_nonRootFiles[index] is Directory) {
                                        _updateNonRootFiles(
                                            _nonRootFiles[index] as Directory);
                                      }
                                    },
                                    child: buildFileTile(
                                      _nonRootFiles[index],
                                      (dir) => _updateNonRootFiles(dir),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            VerticalDivider(color: Colors.grey[700], width: 1),

            // Panel Kanan: Root
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activePanel = 'root';
                  });
                },
                child: Container(
                  color: _activePanel == 'root'
                      ? Colors.grey[850]
                      : Colors.grey[900],
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          _hasRootAccess
                              ? 'Root Directory'
                              : 'Root Access Denied',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      Expanded(
                        child: !_hasRootAccess
                            ? Center(
                                child: Text(
                                  'Akses root ditolak',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : (_rootFiles.isEmpty
                                ? Center(
                                    child: Text(
                                      'Tidak ada file atau direktori ditemukan',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _rootFiles.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _activePanel = 'root';
                                          });
                                          if (_rootFiles[index] is Directory) {
                                            _updateRootFiles(
                                                _rootFiles[index] as Directory);
                                          }
                                        },
                                        child: buildFileTile(
                                          _rootFiles[index],
                                          (dir) => _updateRootFiles(dir),
                                        ),
                                      );
                                    },
                                  )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
