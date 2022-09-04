import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SetconStorage {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/setcon.txt');
  }

  Future<String> read() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<File> write(String str) async {
    final file = await _localFile;
    return file.writeAsString(str);
  }
}
