import 'dart:convert';
import 'package:face_recognition/kirim.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition/setcon.dart';
import 'package:face_recognition/main.dart';
import 'package:face_recognition/suhu.dart';
import 'package:face_recognition/password.dart';
import 'package:face_recognition/register.dart';
import 'package:face_recognition/info.dart';
import 'package:face_recognition/synchronize.dart';
import 'package:face_recognition/devicestorage.dart';
import 'package:face_recognition/setconstorage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Set extends StatefulWidget {
  @override
  _State createState() => new _State();
}

class _State extends State<Set> {
  Setcon setcon;
  SettingStorage _settingStorage;
  var parsedJson;
  Directory _tempDir;
  DeviceStorage devicestorage = new DeviceStorage();
  String _str;

  @override
  void initState() {
    super.initState();
    _settingStorage = SettingStorage();
    _settingStorage.readSetting().then((value) {
      try {
        parsedJson = json.decode(value);
      } on Exception catch (e) {
        print(e);
        parsedJson =
            jsonDecode('{"suhu":"37.5","orang":"50","mask":"0","sound":"0"}');
      }
      setcon = Setcon(1, parsedJson['suhu'], parsedJson['orang'],
          parsedJson['mask'], parsedJson['sound']);
      print("set.dart: " + setcon.jsonString);
      setState(() {
        //
      });
    });
    devicestorage.read().then((String value) {
      try {
        _str = value;
      } on Exception catch (e) {
        print(e);
        _str =
            '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf,status=unregister,nama=Pengunjung,telepon=123456789012,versi=V.1.0,info=ini info}';
      }
      print(_str);
    });
  }

  void deleteAll() async {
    _tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/emb.json';
    await File(_embPath).delete();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Setting"),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Icon(
                    Icons.home,
                    size: 26.0,
                  ),
                )),
          ],
        ),
        body: Center(
            child: Column(children: <Widget>[
          Container(
            margin: EdgeInsets.all(20),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              child: Text('     Suhu      '),
              color: Color.fromARGB(255, 2, 156, 225),
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Suhu(storage: SetconStorage());
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              child: Text('       Init       '),
              color: Color.fromARGB(255, 2, 156, 225),
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Password(storage: DeviceStorage());
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              child: Text('  Register   '),
              color: Color.fromARGB(255, 2, 156, 225),
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Register(storage: DeviceStorage());
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              child: Text(' Send Data '),
              color: Color.fromARGB(255, 2, 156, 225),
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return KirimData();
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              child: Text('Device Info'),
              color: Color.fromARGB(255, 2, 156, 225),
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return DeviceInfo(storage: DeviceStorage());
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              child: Text('Synchronize'),
              color: Color.fromARGB(255, 2, 156, 225),
              textColor: Colors.white,
              onPressed: () {
                deleteAll();
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Synchronize(storage: DeviceStorage());
                }));
              },
            ),
          ),
          /*Container(
            margin: EdgeInsets.all(5),
            child: FlatButton(
              child: Text('Clear Cache'),
              color: Color.fromARGB(255, 2, 156, 225),
              textColor: Colors.white,
              onPressed: () {
                //DefaultCacheManager().emptyCache();
                _deleteCacheDir();
              },
            ),
          ),*/
        ])));
  }
}
