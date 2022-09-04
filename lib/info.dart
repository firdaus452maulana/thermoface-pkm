import 'package:flutter/material.dart';
import 'package:face_recognition/devicestorage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DeviceInfo extends StatefulWidget {
  final DeviceStorage storage;
  DeviceInfo({Key key, @required this.storage}) : super(key: key);
  @override
  InitState createState() => InitState();
}

class InitState extends State<DeviceInfo> {
  String _str =
      '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf/access_send,status=unregister,nama=Pengunjung,telepon=123456789012,versi=V.1.0,info=ini info}';
  String _deviceID = "FCM001";
  String _platformImei = "359306101792750";
  String _code = "unknow";
  String _url = "";
  String _status = "unregister";
  String _nama = "pengunjung";
  String _telepon = "123456789012";
  String _versi = "V.1.0";
  String _info = "ini info";

  var parsedJson;
  String err = "";
  String _res = "";

  @override
  void initState() {
    int index1, index2, i;
    super.initState();

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
      });
    });
  }

  Future<void> sendData(String deviceid, String versi) async {
    String res;
    String url = "http://27.111.44.44/ws/api_tf/getversion/$deviceid/$versi";
    print(url);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        res = response.body;
        _res = res;
        print(_res);
        _info = _res;
      });
    } else {
      throw Exception('Failed to send data.');
    }
  }

  Future<File> _inputString() {
    setState(() {
      _str =
          "{deviceID=$_deviceID,imei=$_platformImei,code=$_code,url=$_url,status=$_status,nama=$_nama,telepon=$_telepon,versi=$_versi,info=$_info}";
    });
    return widget.storage.write(_str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Device Info"),
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
                          'info : ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _info,
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
                      child: Text('     Check Version      '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        _inputString();
                        sendData(_deviceID, _versi);
                      })),
            ])));
  }
}
