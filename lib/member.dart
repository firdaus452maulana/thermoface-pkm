import 'dart:io';
import 'package:face_recognition/contact1.dart';
import 'package:face_recognition/dbhelper1.dart';
import 'package:face_recognition/editform.dart';
import 'package:face_recognition/deleteform.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:face_recognition/devicestorage.dart';
import 'package:face_recognition/datastorage.dart';
import 'package:face_recognition/memberstorage.dart';

class Member extends StatefulWidget {
  @override
  MemberState createState() => MemberState();
}

class MemberState extends State<Member> {
  DbHelper1 dbHelper1 = DbHelper1();
  int count1 = 0;
  int numb = 0;
  int start = 0;
  List<Contact1> contactList1;
  File jsonFile;
  Directory _tempDir;
  dynamic data = {};
  String _res;
  String dt;
  String _namefile = "coba.png";
  //String _path;
  String _str;
  DeviceStorage devicestorage = new DeviceStorage();
  String deviceID = "FCM001";
  String _url = "http://27.111.44.44/ws/api_tf";

  DataStorage datastorage = new DataStorage();
  MemberStorage memberstorage = new MemberStorage();

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
  }

  @override
  Widget build(BuildContext context) {
    if (contactList1 == null) {
      contactList1 = List<Contact1>();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 156, 225),
        title: Text('Member'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              clearAll();
            },
            child: Text("Clear All"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
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
      body: createListView(),
    );
  }

  Future<void> editMember(String datetime, String deviceID, String name,
      String namefile, String namepath, String url, String update) async {
    String url1, res;
    url1 = "$url/member_send_fitur";
    var request = http.MultipartRequest('POST', Uri.parse(url1));
    request.fields.addAll({
      'datetime': datetime,
      'deviceID': deviceID,
      'name': name,
      'namefile': namefile,
      'update_data': update
    });
    request.files.add(await http.MultipartFile.fromPath('picture', namepath));
    var response = await request.send();
    final res1 = await http.Response.fromStream(response);
    setState(() {
      res = res1.body;
      _res = res;
      print(_res);
    });
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

  void deleteData(String name1, String path1) async {
    int i, index1, index2;
    String newString;
    String tgl = ambilTanggal();
    String jam = ambilJam();
    dt = tgl + " " + jam;

    _tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);
    if (jsonFile.existsSync()) {
      String original = await jsonFile.readAsString();
      index1 = original.indexOf(name1);
      for (i = index1; i < original.length; i++) if (original[i] == ']') break;
      index2 = i;
      if (original[index1 - 2] == '{') {
        String str = original.substring(index1 - 2, index2 + 1);
        newString = original.replaceAll(str, "");
        newString = "{" + newString.substring(1, newString.length);
      } else {
        String str = original.substring(index1 - 2, index2 + 1);
        newString = original.replaceAll(str, "");
      }
    }
    jsonFile.writeAsString(newString);
    index1 = path1.indexOf(deviceID);
    _namefile = path1.substring(index1, path1.length);
    editMember(dt, deviceID, name1, _namefile, path1, _url, "delete");
  }

  Future<Contact1> navigateToEntryForm(
      BuildContext context, Contact1 contact1) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return EditForm(contact1);
    }));
    return result;
  }

  Future<Contact1> navigateToDeleteForm(
      BuildContext context, Contact1 contact1) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return DeleteForm(contact1);
    }));
    return result;
  }

  ListView createListView() {
    //var contact = navigateToEntryForm(context, null);
    // ignore: deprecated_member_use
    updateListView1();
    // ignore: deprecated_member_use
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count1,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              backgroundImage: FileImage(File(
                  contactList1[contactList1.length - index - 1 - start]
                      .imgPath1)),
            ),
            title: Text(
              this.contactList1[contactList1.length - index - 1 - start].name1 +
                  "  " +
                  this
                      .contactList1[contactList1.length - index - 1 - start]
                      .memberID1,
              //style: TextStyle(fontWeight: FontWeight.bold),
              style: textStyle,
            ),
            subtitle: Text(this
                    .contactList1[contactList1.length - index - 1 - start]
                    .dates1 +
                "  " +
                this
                    .contactList1[contactList1.length - index - 1 - start]
                    .hours1),
            trailing: GestureDetector(
              child: Icon(Icons.delete_forever),
              onTap: () async {
                var contact = await navigateToDeleteForm(context,
                    this.contactList1[contactList1.length - index - 1 - start]);
                if (contact != null) deleteContact(contact);
              },
            ),
            onTap: () async {
              var contact = await navigateToEntryForm(context,
                  this.contactList1[contactList1.length - index - 1 - start]);
              if (contact != null) editContact(contact);
            },
          ),
        );
      },
    );
  }

  void addContact(Contact1 object) async {
    int result = await dbHelper1.insert(object);
    if (result > 0) {
      updateListView1();
    }
  }

  void editContact(Contact1 object) async {
    int result = await dbHelper1.update(object);
    if (result > 0) {
      updateListView1();
    }
  }

  void deleteContact(Contact1 object) async {
    int result = await dbHelper1.delete(object.id1);
    if (result > 0) {
      updateListView1();
    }
  }

  void clearAll() async {
    for (int x = 0; x < contactList1.length; x++) {
      deleteContact(contactList1[x]);
      await File(contactList1[x].imgPath1).delete();
    }
    _tempDir = await getExternalStorageDirectory();
    String _embPath = _tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);
    await jsonFile.writeAsString("");

    /*for (int x = 0; x < contactList1.length; x++) {
      deleteContact(contactList1[x]);
      await File(contactList1[x].imgPath1).delete();
    }
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
    jsonFile = new File(_embPath);
    await jsonFile.writeAsString("");*/
  }

  void updateListView1() {
    final Future<Database> dbFuture = dbHelper1.initDb();
    dbFuture.then((database) {
      Future<List<Contact1>> contactListFuture = dbHelper1.getContactList();
      contactListFuture.then((contactList1) {
        setState(() {
          this.contactList1 = contactList1;
          if (numb == 0) {
            start = 0;
            this.count1 = contactList1.length;
          }
        });
      });
    });
  }
}
