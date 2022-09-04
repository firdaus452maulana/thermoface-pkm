import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MemberStorage {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/member.txt');
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
    return file.writeAsString("$str\r\n", mode: FileMode.append);
  }

  Future clean() async {
    final file = await _localFile;
    return file.writeAsString('');
  }
}
