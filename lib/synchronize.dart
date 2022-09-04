import 'dart:async';
import 'dart:convert';
import 'dart:io';

//import 'package:face_recognition/addpeople.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition/devicestorage.dart';
import 'package:http/http.dart' as http;
import 'package:face_recognition/contact1.dart';
import 'package:face_recognition/dbhelper1.dart';
import 'package:sqflite/sqflite.dart';
import 'package:face_recognition/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
//import 'utils.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class Synchronize extends StatefulWidget {
  final DeviceStorage storage;
  Synchronize({Key key, @required this.storage}) : super(key: key);
  @override
  SynchronizeState createState() => SynchronizeState();
}

class SynchronizeState extends State<Synchronize> {
  String _str =
      '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf/access_send,status=unregister,nama=Pengunjung,telepon=123456789012,versi=V.1.0,info=ini info}';
  String _deviceID = "FCM001";
  //String _platformImei = "359306101792750";
  String _code = "unknow";
  String url = "http://27.111.44.44/ws/api_tf/get_member_data/";
  String _status = "unregister";
  String _nama = "pengunjung";
  String telepon = "123456789012";
  String _versi = "V.1.0";
  String info = "ini info";

  var parsedJson;
  String err = "";
  String _res = "";
  String dataMember = "";
  DbHelper1 dbHelper1 = DbHelper1();
  int count1 = 0;
  int numb = 0;
  int start = 0;
  List<Contact1> contactList1;

  Directory tempDir;
  String _embPath;
  File jsonFile;
  List e1;
  dynamic data = {};
  double threshold = 0.9;
  var interpreter;
  //AddPeople add;
  imglib.Image croppedImage, croppedImage1;
  double x, y, w, h;
  imglib.Image convertedImage;

  Future loadModel() async {
    try {
      final gpuDelegateV2 = tfl.GpuDelegateV2(
          options: tfl.GpuDelegateOptionsV2(
        false,
        tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
        tfl.TfLiteGpuInferencePriority.minLatency,
        tfl.TfLiteGpuInferencePriority.auto,
        tfl.TfLiteGpuInferencePriority.auto,
      ));

      var interpreterOptions = tfl.InterpreterOptions()
        ..addDelegate(gpuDelegateV2);
      interpreter = await tfl.Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
    } on Exception {
      print('Failed to load model.');
    }
  }

  @override
  void initState() async {
    int index1, index2, i;
    super.initState();
    await loadModel();

    tempDir = await getExternalStorageDirectory();
    _embPath = tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);

    widget.storage.read().then((String value) {
      try {
        _str = value;
      } on Exception catch (e) {
        print(e);
        _str =
            '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf/access_send,status=unregister,nama=Pengunjung,telepon=123456789012,versi=V.1.0,info=ini info}';
      }
      setState(() {
        _str = value;
        index1 = _str.indexOf("deviceID");
        for (i = index1 + 9; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _deviceID = _str.substring(index1 + 9, index2);
        index1 = _str.indexOf("code");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _code = _str.substring(index1 + 5, index2);
        index1 = _str.indexOf("url");
        for (i = index1 + 4; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        url = _str.substring(index1 + 4, index2);
        index1 = _str.indexOf("status");
        for (i = index1 + 7; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _status = _str.substring(index1 + 7, index2);
        index1 = _str.indexOf("nama");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _nama = _str.substring(index1 + 5, index2);
        index1 = _str.indexOf("telepon");
        for (i = index1 + 8; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        telepon = _str.substring(index1 + 8, index2);
        index1 = _str.indexOf("versi");
        for (i = index1 + 6; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _versi = _str.substring(index1 + 6, index2);
        index1 = _str.indexOf("info");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == '}') break;
        index2 = i;
        info = _str.substring(index1 + 5, index2);
      });
    });
  }

  Future<void> getMember(
      String datetime, String mode, String deviceID, String devicecode) async {
    String url1, res;
    tempDir = await getExternalStorageDirectory();
    _embPath = tempDir.path + '/getmember.txt';
    File memberFile = new File(_embPath);
    url1 = "http://27.111.44.44/ws/api_tf/get_member_data/";
    var response = await http.post(url1, body: {
      'datetime': datetime,
      'mode': mode,
      'deviceID': deviceID,
      'devicecode': devicecode
    });
    if (response.statusCode == 200) {
      setState(() {
        res = response.body;
        dataMember = res;
        int index1, index2, i;
        index1 = res.indexOf("data_total");
        for (i = index1 + 14; i < res.length; i++) if (res[i] == ',') break;
        index2 = i - 1;
        String dataTotal = res.substring(index1 + 14, index2);
        _res = dataTotal;
        //_res = res;
        print(_res);
        memberFile.writeAsString(res);
      });
    } else {
      throw Exception('Failed to send data.');
    }
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

  void hapusFile() async {
    tempDir = await getExternalStorageDirectory();
    _embPath = tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);
    jsonFile.delete();
    /*Directory directory = await getExternalStorageDirectory();
    String path = directory.path + 'member.db';
    File deleteDB = new File(path);
    deleteDB.delete();*/
  }

  /*String _recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List(1 * 192).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1).toUpperCase();
  }

  String compare(List currEmb) {
    if (data.length == 0) return "No Face saved";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    print(minDist.toString() + " " + predRes);
    return predRes;
  }*/

  void _handle(
      String imageurl, String nama, String fitur, String memberID) async {
    String tgl = imageurl.substring(52, 62);
    String jam = imageurl.substring(62, 70);
    String deviceID = imageurl.substring(45, 51);

    String path = MyApp.imgDir;
    String namafile = "$deviceID-$tgl$jam.png";
    path = path + "/" + namafile;
    _embPath = path;
    File file = File(path);
    var response = await http.get(imageurl);
    await file.writeAsBytes(response.bodyBytes);

    Contact1 contact1 =
        Contact1(tgl, jam, nama, "NORMAL", "NO MASK", path, memberID);
    addContact1(contact1);

    /*tempDir = await getExternalStorageDirectory();
    _embPath = tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);
    String newString;
    if (jsonFile.existsSync()) {
      String original = await jsonFile.readAsString();
      String strn = original.substring(0, original.length - 1);
      newString = strn + ',"$nama":$fitur}';
      jsonFile.writeAsString(newString);
    } else {
      newString = '{"$nama":$fitur}';
      jsonFile.writeAsString(newString);
    }*/
  }

  void addContact1(Contact1 object) async {
    int result = await dbHelper1.insert(object);
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
          if (numb == 0) {
            start = 0;
            this.count1 = contactList1.length;
          }
        });
      });
    });
  }

  void deleteContact(Contact1 object) async {
    int result = await dbHelper1.delete(object.id1);
    if (result > 0) {
      updateListView1();
    }
  }

  void deleteAll() async {
    for (int x = 0; x < contactList1.length; x++) {
      deleteContact(contactList1[x]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Synchronize"),
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
                          'Nama/Organisasi : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _nama,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Device ID : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _deviceID,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Status : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _status,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Code : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _code,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]),
              ), ////////////
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'App Version : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _versi,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]),
              ),
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
              /*Container(
                  margin: EdgeInsets.all(5),
                  child: RaisedButton(
                      child: Text('     Delete All     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        deleteAll();                                
                        hapusFile();
                      })),*/
              Container(
                  margin: EdgeInsets.all(5),
                  child: RaisedButton(
                      child: Text('     Get Member     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        String tgl = ambilTanggal();
                        String jam = ambilJam();
                        String datetime = tgl + " " + jam;
                        getMember(datetime, "member", _deviceID, _code);
                      })),
              Container(
                  margin: EdgeInsets.all(5),
                  child: RaisedButton(
                      child: Text('     Synchronize    '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        updateListView1();
                        String str1 = dataMember;
                        var tagsJson = jsonDecode(str1);
                        String dataTotal = tagsJson['data_total'];
                        int jumlah = int.parse(dataTotal);
                        String imageurl, nama, fitur, memberID;
                        int kk;
                        String newString = '{';
                        for (kk = 0; kk < jumlah; kk++) {
                          nama = tagsJson['data_member'][kk]['name'];
                          imageurl = tagsJson['data_member'][kk]['imageurl'];
                          fitur = tagsJson['data_member'][kk]['fitur_data'];
                          memberID = tagsJson['data_member'][kk]['memberid'];
                          _handle(imageurl, nama, fitur, memberID);
                          newString = newString + '"$nama":$fitur,';
                        }
                        String strn =
                            newString.substring(0, newString.length - 1);
                        strn = strn + '}';
                        jsonFile.writeAsString(strn);

                        /*String str1 = dataMember;
                        int pj = str1.length;
                        int index1, index2, i, j;
                        index1 = str1.indexOf("data_total");
                        for (i = index1 + 14; i < pj; i++)
                          if (str1[i] == ',') break;
                        index2 = i - 1;
                        String dataTotal = str1.substring(index1 + 14, index2);
                        int jumlah = int.parse(dataTotal);
                        int start1 = index2;
                        String str = str1.substring(start1, str1.length);
                        pj = str.length;
                        String imageurl, nama, fitur;
                        //jumlah = 3;
                        for (j = 0; j < jumlah; j++) {
                          index1 = str.indexOf("name");
                          for (i = index1 + 8; i < pj; i++)
                            if (str[i] == ',') break;
                          index2 = i - 1;
                          nama = str.substring(index1 + 8, index2);
                          index1 = str.indexOf("imageurl");
                          for (i = index1 + 12; i < pj; i++)
                            if (str[i] == ',') break;
                          index2 = i - 1;
                          imageurl = str.substring(index1 + 12, index2);
                          index1 = str.indexOf("fitur_data");
                          for (i = index1 + 14; i < pj; i++)
                            if (str[i] == ']') break;
                          index2 = i + 1;
                          fitur = str.substring(index1 + 14, index2);
                          _handle(imageurl, nama, fitur);
                          start1 = index2;
                          String str2 = str.substring(start1, pj);
                          str = str2;
                          pj = str.length;
                        }*/
                        setState(() {
                          _res = "OK";
                        });
                      })),
            ])));
  }
}
