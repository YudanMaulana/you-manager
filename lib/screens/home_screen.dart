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
  List<FileSystemEntity> _nonRootFiles = [];
  bool _hasRootAccess = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _nonRootDir = Directory('/storage/emulated/0');
    _nonRootFiles = await initDirectory(_nonRootDir, context);

    final needRootAccess = await showRootAccessDialog(context);
    if (needRootAccess) {
      _hasRootAccess = await requestRootAccess(context);
      if (!_hasRootAccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Akses root ditolak.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Akses root diberikan.")),
        );
      }
    }

    setState(() {});
  }

  void _updateNonRootFiles(Directory dir) async {
    _nonRootFiles = await initDirectory(dir, context);
    setState(() {
      _nonRootDir = dir;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_nonRootDir.path != '/storage/emulated/0') {
          _updateNonRootFiles(_nonRootDir.parent);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          title: Text('You Manager', style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 21, 21, 30),
        ),
        body: Container(
          color: Color.fromARGB(255, 21, 21, 30),
          child: Column(
            children: [
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
    );
  }
}
