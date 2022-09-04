//import 'dart:convert';
//import 'dart:html';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:face_recognition/devicestorage.dart';
//import 'package:imei_plugin/imei_plugin.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:platform_device_id/platform_device_id.dart';

class Init extends StatefulWidget {
  final DeviceStorage storage;
  Init({Key key, @required this.storage}) : super(key: key);
  @override
  InitState createState() => InitState();
}

class InitState extends State<Init> {
  String _str =
      '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf,status=unregister,nama=Pengunjung,telepon=123456789012,versi=V.1.0,info=ini info}';
  String _deviceID = "FCM001";
  String _platformImei = "359306101792750";
  String _code = "123456";
  String _url = "http://27.111.44.44/ws/api_tf";
  String _status = "unregister";
  String _nama = "pengunjung";
  String _telepon = "123456789012";
  String _versi = "V.1.0";
  String _info = "ini info";

  TextEditingController deviceController = TextEditingController();
  TextEditingController petugasController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  var parsedJson;
  String _res = "";
  String err = "";
  String _petugas = "";

  @override
  void initState() {
    int index1, index2, i;
    super.initState();
    initPlatformState();
    widget.storage.read().then((String value) {
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
        _deviceID = _str.substring(index1 + 9, index2);
        index1 = _str.indexOf("code");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _code = _str.substring(index1 + 5, index2);
        index1 = _str.indexOf("url");
        for (i = index1 + 4; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _url = _str.substring(index1 + 4, index2);
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
        _telepon = _str.substring(index1 + 8, index2);
        index1 = _str.indexOf("versi");
        for (i = index1 + 6; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _versi = _str.substring(index1 + 6, index2);
        index1 = _str.indexOf("info");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == '}') break;
        index2 = i;
        _info = _str.substring(index1 + 5, index2);
        deviceController.text = _deviceID;
        petugasController.text = "";
        urlController.text = _url;
      });
    });
  }

  Future<void> initPlatformState() async {
    String platformImei;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformImei = await PlatformDeviceId.getDeviceId;

      /*await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      List<String> multiImei = await ImeiPlugin.getImeiMulti();
      print(multiImei);*/
    } on PlatformException {
      platformImei = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformImei = platformImei;
      print(_platformImei);
    });
  }

  Future<File> _inputString() {
    setState(() {
      _str =
          "{deviceID=$_deviceID,imei=$_platformImei,code=$_code,url=$_url,status=$_status,nama=$_nama,telepon=$_telepon,versi=$_versi,info=$_info}";
    });
    return widget.storage.write(_str);
  }

  Future<void> sendData(
      String deviceid, String imei, String petugas, String url) async {
    String res;
    String url2 = url.replaceAll("://", "---");
    String url3 = url2.replaceAll("/", "--");
    String url1 = "$url/devicereg/$deviceid/$imei/$petugas/$url3";
    print(url1);
    var response = await http.get(url1);
    if (response.statusCode == 200) {
      setState(() {
        res = response.body;
        _res = res;
        int index = res.indexOf("-");
        res = res.substring(0, index - 1);
        print(_res);
      });
    } else {
      throw Exception('Failed to send data.');
    }
  }

  /*String code, res;
    //String dataku = "{'deviceid': FCM001, 'imei': 359306101792750'}";
    int index1, index2, i;
    var response =
        await http.post(_url, body: {'deviceid': deviceid, 'imei': imei, 'imei': imei});
    if (response.statusCode == 200) {
      setState(() {
        res = response.body;
        _res = res;
        print(_res);
        index1 = res.indexOf("error");
        index2 = res.indexOf(",");
        err = res.substring(index1 + 7, index2);
        if (err.compareTo("00") == 0) {
          index1 = res.indexOf("code");
          for (i = index1 + 7; i < res.length; i++) if (res[i] == '}') break;
          index2 = i;
          code = res.substring(index1 + 7, index2 - 1);
        } else {
          code = "Tidak Register";
        }
        _code = code;
        //_res = res;
        _inputString();
      });
    } else {
      throw Exception('Failed to send data.');
    }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Init"),
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
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: deviceController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Device ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    _deviceID = value;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: petugasController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Petugas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    _petugas = value;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: urlController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    _url = value;
                  },
                ),
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
                  margin: EdgeInsets.all(5),
                  child: RaisedButton(
                      child: Text('    Initial     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        _inputString();
                        sendData(_deviceID, _platformImei, _petugas, _url);
                        //Navigator.pushNamed(context, '/');
                      })),
            ])));
  }
}
