import 'package:face_recognition/contact1.dart';
import 'package:flutter/material.dart';
import 'dart:io';
//import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:face_recognition/devicestorage.dart';

class DeleteForm extends StatefulWidget {
  final Contact1 contact;

  DeleteForm(this.contact);

  @override
  DeleteFormState createState() => DeleteFormState(this.contact);
}

class DeleteFormState extends State<DeleteForm> {
  Contact1 contact;

  DeleteFormState(this.contact);

  /*TextEditingController datesController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  TextEditingController tempController = TextEditingController();
  TextEditingController sttempController = TextEditingController();
  TextEditingController stmaskController = TextEditingController();*/
  String date, hours, name, sttemp, stmask, imagePath;
  TextEditingController nameController = TextEditingController();
  //String _name;
  File jsonFile;
  Directory _tempDir;
  dynamic data = {};
  int index;
  String mask = "";
  String nama;
  String _res = "";
  String dt;
  String _str;
  DeviceStorage devicestorage = new DeviceStorage();
  String deviceID = "FCM001";
  String _url = "http://27.111.44.44/ws/api_tf";
  String _namefile = "coba.png";

  Future<void> delMember(
      String datetime,
      String deviceID,
      String name,
      String namefile,
      String update,
      String namepath,
      String fiturData,
      String fiturSrc,
      String url,
      String memberID) async {
    String url1, res = "";
    url1 = "$url/member_send_fitur";
    var request = http.MultipartRequest('POST', Uri.parse(url1));
    request.fields.addAll({
      'datetime': datetime,
      'deviceID': deviceID,
      'name': name,
      'namefile': namefile,
      'update_data': update,
      'fitur_data': fiturData,
      'fitur_src': fiturSrc,
      'memberID': memberID
    });
    request.files.add(await http.MultipartFile.fromPath('picture', namepath));
    var response = await request.send();
    final res1 = await http.Response.fromStream(response);
    setState(() {
      res = res1.body;
      _res = res;
      print(_res);
    });
    return res;
  }

  String ambilTanggal() {
    int tahun = DateTime.now().year;
    int month = DateTime.now().month;
    int day = DateTime.now().day;
    String smonth = month.toString().padLeft(2, '0');
    String sday = day.toString().padLeft(2, '0');
    String tgl1 = "$tahun-$smonth-$sday";
    return tgl1;
  }

  String ambilJam() {
    int hh = DateTime.now().hour;
    int mm = DateTime.now().minute;
    int ss = DateTime.now().second;
    String shh = hh.toString().padLeft(2, '0');
    String smm = mm.toString().padLeft(2, '0');
    String sss = ss.toString().padLeft(2, '0');
    String jam1 = "$shh:$smm:$sss";
    return jam1;
  }

  void sendMember(String name2, String path1, String memberID1) async {
    int index1;
    String tgl = ambilTanggal();
    String jam = ambilJam();
    dt = tgl + " " + jam;
    index1 = path1.indexOf(deviceID);
    _namefile = path1.substring(index1, path1.length);
    delMember(dt, deviceID, name2, _namefile, "delete", path1, "", "", _url,
        memberID1);
  }

  void _resetFile() {
    data = {};
    jsonFile.deleteSync();
  }

  void deleteMember(String name1, String path1) async {
    int i, index1, index2;
    String newString;

    bool isExist = await File(path1).exists();
    if (isExist) {
      await File(path1).delete();
    }

    _tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);
    if (jsonFile.existsSync()) {
      String original = await jsonFile.readAsString();
      int jum = '['.allMatches(original).length;
      if (jum == 1)
        _resetFile();
      else {
        index1 = original.indexOf(name1);
        for (i = index1; i < original.length; i++)
          if (original[i] == ']') break;
        index2 = i;
        if (original[index1 - 2] == '{') {
          String str = original.substring(index1 - 2, index2 + 1);
          newString = original.replaceAll(str, "");
          newString = "{" + newString.substring(1, newString.length);
        } else {
          String str = original.substring(index1 - 2, index2 + 1);
          newString = original.replaceAll(str, "");
        }
        jsonFile.writeAsString(newString);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    int index1, i, index2;

    devicestorage.read().then((String value) {
      try {
        _str = value;
      } on Exception catch (e) {
        print(e);
        _str =
            '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf,status=unregister,nama=Pengunjung,telepon=123456789012,versi=V.1.0,info=ini info}';
      }
      setState(() {
        _str = value;
        index1 = _str.indexOf("deviceID");
        for (i = index1 + 9; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        deviceID = _str.substring(index1 + 9, index2);
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
      setState(() {
        _str = value;
        index1 = _str.indexOf("url");
        for (i = index1 + 4; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _url = _str.substring(index1 + 4, index2);
      });
    });
    if (contact != null) {
      date = contact.dates1;
      hours = contact.hours1;
      name = contact.name1;
      imagePath = contact.imgPath1;
      sttemp = contact.sttemp1;
      stmask = contact.stmask1;
      nameController.text = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    /*if (contact != null) {
      date = contact.dates1;
      hours = contact.hours1;
      name = contact.name1;
      imagePath = contact.imgPath1;
      sttemp = contact.sttemp1;
      stmask = contact.stmask1;
      nameController.text = name;
    }*/

    return Scaffold(
      /*appBar: AppBar(
        title: contact == null ? Text('Tambah Data') : Text('Ubah Data'),
        leading: Icon(Icons.keyboard_arrow_left),
      ),*/
      appBar: new AppBar(
        backgroundColor: Color.fromARGB(255, 2, 156, 225),
        title: Text("Delete Member"),
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
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Color.fromARGB(255, 2, 156, 225),
                //image: Image.file(File(imagePath)),
              ),
              child: Image.file(File(imagePath)),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Date : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$date',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Hours : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$hours',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Name : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$name',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
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
                        '$_res',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ]),
            ),
            Container(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              margin: EdgeInsets.all(5),
              child: FlatButton(
                  child: Text('    Send  Member   '),
                  color: Color.fromARGB(255, 2, 156, 225),
                  textColor: Colors.white,
                  onPressed: () {
                    String str1 = contact.name1;
                    String str2 = contact.imgPath1;
                    String str3 = contact.memberID1;
                    sendMember(str1, str2, str3);
                  }),
            ),
            Container(
                padding: EdgeInsets.only(top: 5.0, left: 10.0, right: 10.0),
                margin: EdgeInsets.all(5),
                child: FlatButton(
                    child: Text('    Delete Member   '),
                    color: Color.fromARGB(255, 2, 156, 225),
                    textColor: Colors.white,
                    onPressed: () {
                      String str1 = contact.name1;
                      String str2 = contact.imgPath1;
                      deleteMember(str1, str2);
                      contact.name = str1.toUpperCase();
                      Navigator.pop(context, contact);
                    }))
          ],
        ),
      ),
    );
  }
}
