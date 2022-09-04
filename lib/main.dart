import 'dart:io';

import 'package:face_recognition/addpeople.dart';
import 'package:face_recognition/face.dart';
import 'package:face_recognition/record.dart';
import 'package:face_recognition/member.dart';
import 'package:face_recognition/setting.dart';
import 'package:face_recognition/statistic.dart';
import 'package:face_recognition/set.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() => runApp(MyApp());

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  static String imgDir;
  static BluetoothDevice device;
  static BluetoothConnection connection;
  String s;
  CameraController _camera;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  //DeviceStorage devicestorage = new DeviceStorage();

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    //cameras = await availableCameras();
    //MyApp.imgDir = (await getApplicationDocumentsDirectory()).path;
    MyApp.imgDir = (await getExternalStorageDirectory()).path;
//    SettingStorage.localPath = (await getApplicationDocumentsDirectory()).path;
    SettingStorage.localPath = MyApp.imgDir;
  }

  @override
  Widget build(BuildContext context) {
    init();
    return MaterialApp(
      title: 'Menu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) {
          // FaceRecState.instance.stopCamera();
          //Password(storage: DeviceStorage());
          return Home();
        },
        '/setting': (BuildContext context) {
          // FaceRecState.instance.stopCamera();
          return Setting();
        },
        '/start': (BuildContext context) {
          FlutterBluetoothSerial.instance.state.then((state) {
            _bluetoothState = state;
          });
          if (_bluetoothState.isEnabled) {
            return FaceRec();
          } else {
            // FaceRecState.instance.stopCamera();
            return Setting();
          }
        },
        '/add': (BuildContext context) {
          return AddPeople();
        },
        /*'/photo': (BuildContext context) {
          return AddPhoto();
        },*/
        '/record': (BuildContext context) {
          // FaceRecState.instance.stopCamera();
          return Record();
        },
        '/member': (BuildContext context) {
          // FaceRecState.instance.stopCamera();
          return Member();
        },
        '/statistic': (BuildContext context) {
          // FaceRecState.instance.stopCamera();
          return Statistic();
        },
        '/set': (BuildContext context) {
          // FaceRecState.instance.stopCamera();
          return Set();
        },
      },
    );
  }

  void stopCamera() async {
    await _camera.stopImageStream();
    await _camera.dispose();
  }
}

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      children: <Widget>[
        ListTile(
          title: Text('Home'),
          leading: Icon(Icons.home),
          onTap: () {
            print('Home');
            Navigator.pushNamed(context, '/');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Bluetooth Connection'),
          leading: Icon(Icons.settings),
          onTap: () {
            print('Bluetooth Connection');
            Navigator.pushNamed(context, '/setting');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Start'),
          leading: Icon(Icons.input),
          onTap: () {
            Navigator.pushNamed(context, '/start');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Add Member'),
          leading: Icon(Icons.person_add),
          onTap: () {
            Navigator.pushNamed(context, '/add');
          },
        ),
        Divider(),
        /*ListTile(
          title: Text('Add Photo'),
          leading: Icon(Icons.photo_camera),
          onTap: () {
            Navigator.pushNamed(context, '/photo');
          },
        ),
        Divider(),*/
        ListTile(
          title: Text('Record'),
          leading: Icon(Icons.people),
          onTap: () {
            print('Record');
            Navigator.pushNamed(context, '/record');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Member'),
          leading: Icon(Icons.card_membership),
          onTap: () {
            print('Record');
            Navigator.pushNamed(context, '/member');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Statistic'),
          leading: Icon(Icons.collections),
          onTap: () {
            print('Statistic');
            Navigator.pushNamed(context, '/statistic');
          },
        ),
        Divider(),
        ListTile(
          title: Text('Setting'),
          leading: Icon(Icons.settings),
          onTap: () {
            print('Setting');
            Navigator.pushNamed(context, '/set');
          },
        ),
      ],
    ),
  );
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 156, 225),
        title: Text('Menu'),
      ),
      drawer: buildDrawer(context),
      body: Container(
        alignment: Alignment.center,
        height: double.infinity,
        width: double.infinity,
        child: Image.asset(
          "images/home.jpg",
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      /*Center(
        child: new Image.asset("images/home.png", fit: BoxFit.cover),
      ),*/
    );
  }
}

class SettingStorage {
  static String localPath;

  File get _localFile {
    return File('$localPath/setting.txt');
  }

  Future<String> readSetting() async {
    try {
      final file = _localFile;
      // Read the file
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '{"suhu":"0","jarak":"0","orang":"0"}';
    }
  }

  Future<File> writeSetting(String contents) async {
    final file = _localFile;
    // Write the file
    return file.writeAsString(contents);
  }
}
