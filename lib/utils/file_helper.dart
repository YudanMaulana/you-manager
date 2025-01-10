import 'dart:io';

class FileHelper {
  static bool isDirectory(FileSystemEntity entity) {
    return entity is Directory;
  }

  static String getFileName(FileSystemEntity entity) {
    return entity.path.split('/').last;
  }
}
