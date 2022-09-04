import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:face_recognition/datastorage.dart';
import 'package:face_recognition/memberstorage.dart';
import 'package:face_recognition/devicestorage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:face_recognition/contact1.dart';
import 'package:face_recognition/dbhelper1.dart';
import 'package:sqflite/sqflite.dart';

import 'package:face_recognition/contact.dart';
import 'package:face_recognition/dbhelper.dart';

class KirimData extends StatefulWidget {
  @override
  InitState createState() => InitState();
}

class InitState extends State<KirimData> {
  TextEditingController deviceidController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  String _url = "http://27.111.44.44/ws/api_tf";
  String err = "";
  String _res = "";
  DataStorage datastorage = new DataStorage();
  MemberStorage memberstorage = new MemberStorage();
  int index1, index2, i;

  DeviceStorage devicestorage = new DeviceStorage();
  Directory _tempDir;
  int jumSend = 0;
  String res = "";

  String deviceInfo;

  String _datetime;
  String _deviceID = "FCM002";
  String _temp = "30.5";
  String _stTemp = "NORMAL";
  String _stMask = "MASK";
  String _nama = "Riyanto";
  String _namefile = "coba.png";
  String _namepath = "d:/data/";

  String _updateData = "";
  String _fiturData = "";
  String _fiturSrc = "";

  List<Contact1> contactList1;
  DbHelper1 dbHelper1 = DbHelper1();
  int count1 = 0;
  int numb1 = 0;
  int count = 0;
  int numb = 0;
  int start = 0;
  String _str;

  List<Contact> contactList;
  DbHelper dbHelper = DbHelper();

  @override
  void initState() {
    int index1, i;
    super.initState();
    devicestorage.read().then((String value) {
      try {
        _str = value;
        deviceInfo = _str;
      } on Exception catch (e) {
        print(e);
        _str =
            '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf,status=unregister,nama=Pengunjung,telepon=123456789012,versi=V.1.0,info=ini info}';
        deviceInfo = _str;
      }
      setState(() {
        _str = value;
        deviceInfo = _str;
        index1 = _str.indexOf("url");
        for (i = index1 + 4; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _url = _str.substring(index1 + 4, index2);
      });
    });
  }

  Future<void> sendDataAll(
      String datetime,
      String deviceID,
      String temp,
      String stTemp,
      String stMask,
      String name,
      String namefile,
      String namepath,
      String url) async {
    String url1;
    err = "FF";
    url1 = "$url/access_send";
    var request = http.MultipartRequest('POST', Uri.parse(url1));
    request.fields.addAll({
      'datetime': datetime,
      'deviceID': deviceID,
      'temp': temp,
      'stTemp': stTemp,
      'stMask': stMask,
      'name': name,
      'namefile': namefile
    });
    request.files.add(await http.MultipartFile.fromPath('picture', namepath));
    var response = await request.send();
    final res1 = await http.Response.fromStream(response);
    setState(() {
      res = res1.body;
      _res = res;
    });
  }

  void bacaData(String str) {
    int index1, index2, i;
    index1 = str.indexOf("datatime");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _datetime = str.substring(index1 + 11, index2);
    index1 = str.indexOf("deviceID");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _deviceID = str.substring(index1 + 9, index2);
    index1 = str.indexOf("temp");
    for (i = index1 + 5; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _temp = str.substring(index1 + 5, index2);
    index1 = str.indexOf("stTemp");
    for (i = index1 + 7; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _stTemp = str.substring(index1 + 7, index2);
    index1 = str.indexOf("stMask");
    for (i = index1 + 7; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _stMask = str.substring(index1 + 7, index2);
    index1 = str.indexOf("name");
    for (i = index1 + 5; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _nama = str.substring(index1 + 5, index2);
    index1 = str.indexOf("namefile");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _namefile = str.substring(index1 + 9, index2);
    index1 = str.indexOf("namepath");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == '}') break;
    index2 = i;
    _namepath = str.substring(index1 + 9, index2);
    print(_datetime);
    print(_deviceID);
    print(_temp);
    print(_stTemp);
    print(_stMask);
    print(_nama);
    print(_namefile);
    print(_namepath);
  }

  Future<void> sendMember(
      String datetime,
      String deviceID,
      String name,
      String namefile,
      String update,
      String namepath,
      String fiturData,
      String fiturSrc,
      String url) async {
    String url1, res;
    url1 = "$url/member_send_fitur";
    var request = http.MultipartRequest('POST', Uri.parse(url1));
    request.fields.addAll({
      'datetime': datetime,
      'deviceID': deviceID,
      'name': name,
      'namefile': namefile,
      'update_data': update,
      'fitur_data': fiturData,
      'fitur_src': fiturSrc
    });
    request.files.add(await http.MultipartFile.fromPath('picture', namepath));
    var response = await request.send();
    final res1 = await http.Response.fromStream(response);
    setState(() {
      res = res1.body;
      _res = res;
    });
  }

  void bacaMember(String str) {
    index1 = str.indexOf("datatime");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _datetime = str.substring(index1 + 11, index2);
    index1 = str.indexOf("deviceID");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _deviceID = str.substring(index1 + 9, index2);
    index1 = str.indexOf("name");
    for (i = index1 + 5; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _nama = str.substring(index1 + 5, index2);
    index1 = str.indexOf("namefile");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _namefile = str.substring(index1 + 9, index2);
    index1 = str.indexOf("update_data");
    for (i = index1 + 12; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _updateData = str.substring(index1 + 12, index2);
    index1 = str.indexOf("picture");
    for (i = index1 + 8; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _namepath = str.substring(index1 + 8, index2);
    index1 = str.indexOf("fitur_data");
    for (i = index1 + 11; i < str.length; i++) if (str[i] == ']') break;
    index2 = i;
    _fiturData = str.substring(index1 + 11, index2 + 1);
    index1 = str.indexOf("fitur_src");
    for (i = index1 + 10; i < str.length; i++) if (str[i] == '}') break;
    index2 = i;
    _fiturSrc = str.substring(index1 + 10, index2);
  }

  void deleteContact1(Contact1 object) async {
    int result = await dbHelper1.delete(object.id1);
    if (result > 0) {
      updateListView1();
    }
  }

  void updateListView1() {
    final Future<Database> dbFuture = dbHelper1.initDb();
    dbFuture.then((database) {
      Future<List<Contact1>> contactListFuture = dbHelper1.getContactList();
      contactListFuture.then((contactList1) {
        setState(() {
          this.contactList1 = contactList1;
          if (numb1 == 0) {
            start = 0;
            this.count1 = contactList1.length;
          }
        });
      });
    });
  }

  void deleteContact(Contact object) async {
    int result = await dbHelper.delete(object.id1);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Contact>> contactListFuture = dbHelper.getContactList();
      contactListFuture.then((contactList) {
        setState(() {
          this.contactList = contactList;
          if (numb == 0) {
            start = 0;
            this.count = contactList.length;
          }
        });
      });
    });
  }

  void delData() async {
    _tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/data.txt';
    File fileData = new File(_embPath);
    await fileData.delete();
    _res = "OK";
  }

  void delMember() async {
    _tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/member.txt';
    File fileMember = new File(_embPath);
    await fileMember.delete();
    _res = "OK";
  }

  void cleanAll() async {
    /*for (int x = 0; x < contactList1.length; x++) {
      deleteContact1(contactList1[x]);
      await File(contactList1[x].imgPath1).delete();
    }

    for (int x = 0; x < contactList.length; x++) {
      deleteContact(contactList[x]);
      await File(contactList[x].imgPath1).delete();
    }*/

    /*_tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/emb.json';
    File jsonFile = new File(_embPath);
    await jsonFile.delete();

    await datastorage.clean();
    await memberstorage.clean();
    _tempDir = await getExternalStorageDirectory();
    if (_tempDir.existsSync()) {
      _tempDir.deleteSync(recursive: true);
      _tempDir.delete(recursive: true);
    }
    devicestorage.write(_str);
    _tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/emb.json';
    File jsonFile = new File(_embPath);

    await jsonFile.writeAsString("");
    devicestorage.write(deviceInfo);
    _res = "OK";*/

    /*await datastorage.clean();
    await memberstorage.clean();
    _tempDir = await getExternalStorageDirectory();
    if (_tempDir.existsSync()) {
      _tempDir.deleteSync(recursive: true);
    }
    _res = "OK";
    devicestorage.write(deviceInfo);*/
  }

  void kirimData() async {
    Directory directory = await getExternalStorageDirectory();
    String _embPath = directory.path + '/data.txt';
    List<String> lines = await new File(_embPath).readAsLines();
    lines.forEach((item) {
      bacaData(item);
      sendDataAll(_datetime, _deviceID, _temp, _stTemp, _stMask, _nama,
          _namefile, _namepath, _url);
    });
  }

  void kirimMember() async {
    Directory directory = await getExternalStorageDirectory();
    String _embPath = directory.path + '/member.txt';
    List<String> lines = await new File(_embPath).readAsLines();
    lines.forEach((item) {
      bacaMember(item);
      sendMember(_datetime, _deviceID, _nama, _namefile, _updateData, _namepath,
          _fiturData, _fiturSrc, _url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Kirim Data"),
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
        body: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
            child: ListView(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Respon : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _res,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]),
              ),
              Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                      child: Text('     Send Data     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        kirimData();
                      })),
              Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                      child: Text('     Delete Data     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          delData();
                        });
                      })),
              Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                      child: Text('     Send Member     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        kirimMember();
                      })),
              Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                      child: Text('     Delete Member     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          delMember();
                        });
                      })),
            ])));
  }
}
