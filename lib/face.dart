import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:face_recognition/scan_qrcode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
//import 'detector_painters.dart';
import 'utils.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';
import 'package:face_recognition/contact.dart';
import 'package:face_recognition/contact1.dart';
import 'package:face_recognition/setting.dart';
import 'package:face_recognition/main.dart';
import 'package:face_recognition/dbhelper.dart';
import 'package:face_recognition/dbhelper1.dart';
import 'package:face_recognition/devicestorage.dart';
import 'package:face_recognition/datastorage.dart';
import 'package:face_recognition/memberstorage.dart';
import 'package:face_recognition/setconstorage.dart';
//import 'package:face_recognition/scan_qrcode.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tflite/tflite.dart';
import 'package:face_recognition/setcon.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

enum TtsState { playing, stopped }

class FaceRec extends StatefulWidget {

  var state = FaceRecState();

  @override
  //FaceRecState createState() => FaceRecState();
  FaceRecState createState() {
    return this.state = new FaceRecState();
  }
}

class FaceRecState extends State<FaceRec> {
  // static FaceRecState instance = new FaceRecState();
  File jsonFile;
  // ignore: unused_field
  dynamic _scanResults;
  CameraController _camera;
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;
  dynamic data = {};
  double threshold = 0.9;
  Directory tempDir;
  List e1;
  // ignore: unused_field
  bool _faceFound = false;
  //double x, y, w, h;
  bool showStatusBar = false;
  bool showRegister = false;
  int xwarna = 0;
  String xsuhu = "35.25", xsuhu1 = "0";
  String stTemp = "NORMAL";
  int co = 0, st = 0;
  DbHelper dbHelper = DbHelper();
  DbHelper1 dbHelper1 = DbHelper1();
  int count = 0;
  int count1 = 0;
  List<Contact> contactList;
  List<Contact1> contactList1;
  int imageWidth;
  int imageHeight;
  // ignore: unused_field
  //bool _loading = false;
  // ignore: unused_field
  List _recognitions;
  String recog;
  String stMask;
  String path;
  String _tgl;
  String _jam;
  int mul = 0;
  //String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  //SettingStorage _settingStorage;
  var parsedJson;
  Setcon setcon;
  String setSuhu;
  String setMask;
  String setSound;

  FlutterTts flutterTts;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.8;
  String text = "mohon gunakan masker anda";
  TtsState ttsState = TtsState.stopped;

  String _url = "http://27.111.44.44/ws/api_tf/access_send";
  String res = "";
  String err = "";
  String dt;
  String deviceID = "FCM001";
  double temp;
  String _path;
  String _res = "PENGUNJUNG";
  double x, y, w, h;
  String _status = "unregister";
  //String _guest;
  DeviceStorage devicestorage = new DeviceStorage();
  DataStorage datastorage = new DataStorage();
  MemberStorage memberstorage = new MemberStorage();
  SetconStorage setconstorage = new SetconStorage();

  //final TextEditingController _name = new TextEditingController();

  String _datetime;
  String _deviceID = "FCM002";
  String _temp = "30.5";
  String _stTemp = "NORMAL";
  String _stMask = "MASK";
  String _nama = "Riyanto";
  String _namefile = "coba.png";
  String _namepath = "d:/data/";
  //String _str = "";
  bool isSwitchedMask = false;
  TextEditingController namaController = TextEditingController();
  int jumSend = 0;
  String _str;
  //String _pilih = "_NOMASK";
  //String _mask = "0";
  /*BluetoothConnection connection;
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  BluetoothDevice _device;*/

  Future<File> _backupdata(
      String datetime,
      String deviceID,
      String temp,
      String stTemp,
      String stMask,
      String name,
      String namefile,
      String namepath) {
    String str;
    setState(() {
      str =
          "{datetime=$datetime,deviceID=$deviceID,temp=$temp,stTemp=$stTemp,stMask=$stMask,name=$name,namefile=$namefile,namepath=$namepath}";
    });
    return datastorage.write(str);
  }

  /*Future<File> _backupmember(String datetime, String deviceID, String name,
      String namefile, String namepath) {
    String str;
    setState(() {
      str =
          "{datetime=$datetime,deviceID=$deviceID,name=$name,namefile=$namefile,namepath=$namepath}";
    });
    return memberstorage.write(str);
  }*/

  /*Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
      print(devices);
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }
  }*/

  /*Future _testBluetooth() async {
    double st = 0;
    SettingState.instance.sendOnMessageToBluetooth();
    xsuhu1 = SettingState.instance.bacaSuhu(SettingState.instance.jsonMessage);
    st = double.parse(xsuhu1);
    if (st == 0) Navigator.pushNamed(context, '/setting');
  }*/

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stopCamera();
    // stopCamera1();
  }

  @override
  void initState() {
    int index1, index2, i;
    String _str;
    super.initState();
    initTts();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    loadModel1();
    //_testBluetooth();
    _initializeCamera();
    loadSuhu();
    showRegister = true;

    devicestorage.read().then((String value) {
      try {
        _str = value;
      } on Exception catch (e) {
        print(e);
        _str =
            '{deviceID=FCM001,imei=359306101792750,code=123456,url=http://27.111.44.44/ws/api_tf,status=unregister,nama=PENGUNJUNG,telepon=123456789012,versi=V.1.0,info=ini info}';
      }
      setState(() {
        _str = value;
        index1 = _str.indexOf("deviceID");
        for (i = index1 + 9; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        deviceID = _str.substring(index1 + 9, index2);
        index1 = _str.indexOf("url");
        for (i = index1 + 4; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _url = _str.substring(index1 + 4, index2);
        index1 = _str.indexOf("status");
        for (i = index1 + 7; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _status = _str.substring(index1 + 7, index2);
        if (_status.compareTo("register") == 0) {
          showRegister = true;
        } else {
          showRegister = false;
        }
      });
    });
    //initPlatformState();
  } //

  initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("id-ID");
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);
    var result = await flutterTts.speak(text);
    if (result == 1) setState(() => ttsState = TtsState.playing);
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
    });
  }

  void bacaMember(String str) {
    int index1, index2, i;
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
    index1 = str.indexOf("namepath");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == '}') break;
    index2 = i;
    _namepath = str.substring(index1 + 9, index2);
    print(_datetime);
    print(_deviceID);
    print(_nama);
    print(_namefile);
    print(_namepath);
  }

  /*Future<void> initPlatformState() async {
    String platformImei;
    String idunique;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformImei =
          await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      List<String> multiImei = await ImeiPlugin.getImeiMulti();
      print(multiImei);
      idunique = await ImeiPlugin.getId();
    } on PlatformException {
      platformImei = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformImei = platformImei;
      uniqueId = idunique;
    });
  }*/

  Future<String> processImage(File image) async {
    String str;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      str = _recognitions[0]["label"].toString();
    });
    return str;
  }

  predictImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    FileImage(image).resolve(ImageConfiguration()).addListener(
          (ImageStreamListener(
            (ImageInfo info, bool _) {
              setState(
                () {
                  imageWidth = info.image.width;
                  imageHeight = info.image.height;
                },
              );
            },
          )),
        );

    setState(() {
      //_loading = false;
      _recognitions = recognitions;
    });
  }

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

  Future loadModel1() async {
    await Tflite.loadModel(
      model: "assets/ml_trained_model/model_unquant.tflite",
      labels: "assets/ml_trained_model/labels.txt",
    );
  }

  Future<File> _inputString() {
    setState(() {
      _str = "{suhu=$setSuhu,mask=$setMask,sound=$setSound}";
    });
    return setconstorage.write(_str);
  }

  Future loadSuhu() async {
    int index1, index2, i;
    setconstorage.read().then((String value) {
      try {
        _str = value;
      } on Exception catch (e) {
        print(e);
        _str = '{suhu=37.5,mask=1,sound=1}';
        setconstorage.write(_str);
      }
      setState(() {
        _str = value;
        index1 = _str.indexOf("suhu");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        setSuhu = _str.substring(index1 + 5, index2);
        index1 = _str.indexOf("mask");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        setMask = _str.substring(index1 + 5, index2);
        index1 = _str.indexOf("sound");
        for (i = index1 + 6; i < _str.length; i++) if (_str[i] == '}') break;
        index2 = i;
        setSound = _str.substring(index1 + 6, index2);
      });
      _inputString();
    });
    /*_settingStorage = SettingStorage();
    _settingStorage.readSetting().then((value) {
      try {
        parsedJson = json.decode(value);
      } on Exception catch (e) {
        print(e);
      }
    });*/
  }

  //grove
  double kalibrasi(double insuhu) {
    double outsuhu;
    if ((insuhu >= 24.00) && (insuhu <= 24.50)) outsuhu = 36.00;
    if ((insuhu > 24.50) && (insuhu <= 26.25)) outsuhu = 36.05;
    if ((insuhu > 26.25) && (insuhu <= 27.00)) outsuhu = 36.10;
    if ((insuhu > 27.00) && (insuhu <= 27.75)) outsuhu = 36.15;
    if ((insuhu > 27.75) && (insuhu <= 28.75)) outsuhu = 36.20;
    if ((insuhu > 28.75) && (insuhu <= 39.25)) outsuhu = 36.25;
    if ((insuhu > 29.25) && (insuhu <= 29.75)) outsuhu = 36.30;
    if ((insuhu > 29.75) && (insuhu <= 30.25)) outsuhu = 36.35;
    if ((insuhu > 30.25) && (insuhu <= 30.75)) outsuhu = 36.40;
    if ((insuhu > 30.75) && (insuhu <= 31.25)) outsuhu = 36.45;
    if ((insuhu > 31.25) && (insuhu <= 31.75)) outsuhu = 36.50;
    if ((insuhu > 31.75) && (insuhu <= 32.25)) outsuhu = 36.55;
    if ((insuhu > 32.25) && (insuhu <= 32.75)) outsuhu = 36.60;
    if ((insuhu > 32.75) && (insuhu <= 33.25)) outsuhu = 36.65;
    if ((insuhu > 33.25) && (insuhu <= 33.75)) outsuhu = 36.70;
    if ((insuhu > 33.75) && (insuhu <= 34.50)) outsuhu = 36.75;
    if ((insuhu > 34.50) && (insuhu <= 35.25)) outsuhu = 36.80;
    if ((insuhu > 35.25) && (insuhu <= 36.00)) outsuhu = 36.85;
    if ((insuhu > 36.00) && (insuhu <= 36.75)) outsuhu = 36.90;
    if ((insuhu > 36.75) && (insuhu <= 37.50)) outsuhu = 36.95;
    if ((insuhu > 37.50) && (insuhu <= 38.25)) outsuhu = 37.00;
    if ((insuhu > 38.25) && (insuhu <= 39.00)) outsuhu = 37.05;
    if ((insuhu > 39.00) && (insuhu <= 39.75)) outsuhu = 37.10;
    if ((insuhu > 39.75) && (insuhu <= 40.50)) outsuhu = 37.15;
    if ((insuhu > 40.50) && (insuhu <= 41.25)) outsuhu = 37.20;
    if ((insuhu > 41.25) && (insuhu <= 42.00)) outsuhu = 37.25;
    if ((insuhu > 42.00) || (insuhu < 24.00)) outsuhu = insuhu;
    return outsuhu;
  }
  /*double kalibrasi(double insuhu) {
    double outsuhu;
    if ((insuhu >= 27.00) && (insuhu <= 27.50)) outsuhu = 35.80;
    if ((insuhu > 27.50) && (insuhu <= 28.25)) outsuhu = 35.90;
    if ((insuhu > 28.25) && (insuhu <= 29.00)) outsuhu = 36.00;
    if ((insuhu > 29.00) && (insuhu <= 29.75)) outsuhu = 36.10;
    if ((insuhu > 29.75) && (insuhu <= 30.25)) outsuhu = 36.20;
    if ((insuhu > 30.25) && (insuhu <= 30.75)) outsuhu = 36.30;
    if ((insuhu > 30.75) && (insuhu <= 31.25)) outsuhu = 36.40;
    if ((insuhu > 31.25) && (insuhu <= 31.75)) outsuhu = 36.50;
    if ((insuhu > 31.75) && (insuhu <= 32.50)) outsuhu = 36.60;
    if ((insuhu > 32.50) && (insuhu <= 33.25)) outsuhu = 36.70;
    if ((insuhu > 33.25) && (insuhu <= 34.00)) outsuhu = 36.80;
    if ((insuhu > 34.00) && (insuhu <= 34.75)) outsuhu = 36.90;
    if ((insuhu > 34.75) && (insuhu <= 35.50)) outsuhu = 37.00;
    if ((insuhu > 35.50) && (insuhu <= 36.25)) outsuhu = 37.10;
    if ((insuhu > 36.25) && (insuhu <= 37.25)) outsuhu = 37.20;
    if ((insuhu > 37.25) && (insuhu <= 38.25)) outsuhu = 37.30;
    if ((insuhu > 38.25) && (insuhu <= 39.25)) outsuhu = 37.40;
    if ((insuhu > 39.25) && (insuhu <= 40.00)) outsuhu = 37.50;
    if (insuhu >= 40.00) outsuhu = insuhu;
    return outsuhu;
  }*/
  /*double kalibrasi(double insuhu) {
    double outsuhu;
    if ((insuhu >= 27.00) && (insuhu <= 27.50)) outsuhu = 35.80;
    if ((insuhu > 27.50) && (insuhu <= 28.25)) outsuhu = 35.90;
    if ((insuhu > 28.25) && (insuhu <= 29.00)) outsuhu = 36.00;
    if ((insuhu > 29.00) && (insuhu <= 29.75)) outsuhu = 36.10;
    if ((insuhu > 29.75) && (insuhu <= 30.25)) outsuhu = 36.20;
    if ((insuhu > 30.25) && (insuhu <= 30.75)) outsuhu = 36.30;
    if ((insuhu > 30.75) && (insuhu <= 31.25)) outsuhu = 36.40;
    if ((insuhu > 31.25) && (insuhu <= 31.75)) outsuhu = 36.50;
    if ((insuhu > 31.75) && (insuhu <= 32.25)) outsuhu = 36.60;
    if ((insuhu > 32.25) && (insuhu <= 32.75)) outsuhu = 36.70;
    if ((insuhu > 32.75) && (insuhu <= 33.25)) outsuhu = 36.80;
    if ((insuhu > 33.25) && (insuhu <= 33.75)) outsuhu = 36.90;
    if ((insuhu > 33.75) && (insuhu <= 34.00)) outsuhu = 37.00;
    if ((insuhu > 34.00) && (insuhu <= 34.25)) outsuhu = 37.10;
    if ((insuhu > 34.25) && (insuhu <= 34.50)) outsuhu = 37.20;
    if ((insuhu > 34.50) && (insuhu <= 34.75)) outsuhu = 37.30;
    if ((insuhu > 34.75) && (insuhu <= 35.00)) outsuhu = 37.40;
    if ((insuhu > 35.00) && (insuhu <= 35.25)) outsuhu = 37.50;
    if ((insuhu > 35.25) && (insuhu <= 35.50)) outsuhu = 37.60;
    if ((insuhu > 35.50) && (insuhu <= 35.75)) outsuhu = 37.70;
    if ((insuhu > 35.75) && (insuhu <= 36.00)) outsuhu = 37.80;
    if ((insuhu > 36.00) && (insuhu <= 36.25)) outsuhu = 37.90;
    if ((insuhu > 36.25) && (insuhu <= 36.50)) outsuhu = 38.00;
    if ((insuhu > 36.50) && (insuhu <= 36.75)) outsuhu = 38.10;
    if ((insuhu > 36.75) && (insuhu <= 37.00)) outsuhu = 38.20;
    if ((insuhu > 37.00) && (insuhu <= 37.25)) outsuhu = 38.30;
    if ((insuhu > 37.25) && (insuhu <= 37.50)) outsuhu = 38.40;
    if ((insuhu > 37.50) && (insuhu <= 37.75)) outsuhu = 38.50;
    if ((insuhu > 37.75) && (insuhu <= 38.00)) outsuhu = 38.60;
    if (insuhu >= 38.00) outsuhu = insuhu;
    return outsuhu;
  }*/

  //non grove
  double kalibrasi1(double insuhu) {
    double outsuhu;
    if ((insuhu >= 23.50) && (insuhu <= 24.00)) outsuhu = 36.00;
    if ((insuhu > 24.00) && (insuhu <= 24.75)) outsuhu = 36.05;
    if ((insuhu > 24.75) && (insuhu <= 25.50)) outsuhu = 36.10;
    if ((insuhu > 25.50) && (insuhu <= 26.25)) outsuhu = 36.15;
    if ((insuhu > 26.25) && (insuhu <= 27.25)) outsuhu = 36.20;
    if ((insuhu > 27.25) && (insuhu <= 27.75)) outsuhu = 36.25;
    if ((insuhu > 27.75) && (insuhu <= 28.25)) outsuhu = 36.30;
    if ((insuhu > 28.25) && (insuhu <= 28.75)) outsuhu = 36.35;
    if ((insuhu > 28.75) && (insuhu <= 29.25)) outsuhu = 36.40;
    if ((insuhu > 29.25) && (insuhu <= 29.75)) outsuhu = 36.45;
    if ((insuhu > 29.75) && (insuhu <= 30.25)) outsuhu = 36.50;
    if ((insuhu > 30.25) && (insuhu <= 30.75)) outsuhu = 36.55;
    if ((insuhu > 30.75) && (insuhu <= 31.25)) outsuhu = 36.60;
    if ((insuhu > 31.25) && (insuhu <= 31.75)) outsuhu = 36.65;
    if ((insuhu > 31.75) && (insuhu <= 32.25)) outsuhu = 36.70;
    if ((insuhu > 32.25) && (insuhu <= 33.00)) outsuhu = 36.75;
    if ((insuhu > 33.00) && (insuhu <= 33.75)) outsuhu = 36.80;
    if ((insuhu > 33.75) && (insuhu <= 34.50)) outsuhu = 36.85;
    if ((insuhu > 34.50) && (insuhu <= 35.25)) outsuhu = 36.90;
    if ((insuhu > 35.25) && (insuhu <= 36.00)) outsuhu = 36.95;
    if ((insuhu > 36.00) && (insuhu <= 36.75)) outsuhu = 37.00;
    if ((insuhu > 36.75) && (insuhu <= 37.50)) outsuhu = 37.05;
    if ((insuhu > 37.50) && (insuhu <= 38.50)) outsuhu = 37.10;
    if ((insuhu > 38.50) && (insuhu <= 39.50)) outsuhu = 37.15;
    if ((insuhu > 39.50) && (insuhu <= 40.50)) outsuhu = 37.20;
    if ((insuhu > 40.50) && (insuhu <= 42.00)) outsuhu = 37.25;
    if ((insuhu > 42.00) || (insuhu < 23.50)) outsuhu = insuhu;
    return outsuhu;
  }
  /*double kalibrasi1(double insuhu) {
    double outsuhu;
    if ((insuhu >= 25.50) && (insuhu <= 26.00)) outsuhu = 35.80;
    if ((insuhu > 26.00) && (insuhu <= 26.75)) outsuhu = 35.90;
    if ((insuhu > 26.75) && (insuhu <= 27.50)) outsuhu = 36.00;
    if ((insuhu > 27.50) && (insuhu <= 28.25)) outsuhu = 36.10;
    if ((insuhu > 28.25) && (insuhu <= 28.75)) outsuhu = 36.20;
    if ((insuhu > 28.75) && (insuhu <= 29.25)) outsuhu = 36.30;
    if ((insuhu > 29.25) && (insuhu <= 29.75)) outsuhu = 36.40;
    if ((insuhu > 29.75) && (insuhu <= 30.25)) outsuhu = 36.50;
    if ((insuhu > 30.25) && (insuhu <= 31.00)) outsuhu = 36.60;
    if ((insuhu > 31.00) && (insuhu <= 31.75)) outsuhu = 36.70;
    if ((insuhu > 31.75) && (insuhu <= 32.50)) outsuhu = 36.80;
    if ((insuhu > 32.50) && (insuhu <= 33.25)) outsuhu = 36.90;
    if ((insuhu > 33.25) && (insuhu <= 34.00)) outsuhu = 37.00;
    if ((insuhu > 34.00) && (insuhu <= 34.75)) outsuhu = 37.10;
    if ((insuhu > 34.75) && (insuhu <= 35.75)) outsuhu = 37.20;
    if ((insuhu > 35.75) && (insuhu <= 36.75)) outsuhu = 37.30;
    if ((insuhu > 36.75) && (insuhu <= 38.00)) outsuhu = 37.40;
    if ((insuhu > 38.00) && (insuhu <= 39.25)) outsuhu = 37.50;
    if ((insuhu > 39.25) && (insuhu <= 40.00)) outsuhu = 37.60;
    if (insuhu >= 40.00) outsuhu = insuhu;
    return outsuhu;
  }*/

  //cikarang
  double kalibrasi2(double insuhu) {
    double outsuhu;
    if ((insuhu >= 28.00) && (insuhu <= 29.25)) outsuhu = 35.40;
    if ((insuhu > 29.25) && (insuhu <= 30.00)) outsuhu = 35.50;
    if ((insuhu > 30.00) && (insuhu <= 30.75)) outsuhu = 35.60;
    if ((insuhu > 30.75) && (insuhu <= 31.50)) outsuhu = 35.70;
    if ((insuhu > 31.50) && (insuhu <= 32.25)) outsuhu = 35.80;
    if ((insuhu > 32.25) && (insuhu <= 33.00)) outsuhu = 35.90;
    if ((insuhu > 33.00) && (insuhu <= 33.75)) outsuhu = 36.00;
    if ((insuhu > 33.75) && (insuhu <= 34.50)) outsuhu = 36.10;
    if ((insuhu > 34.50) && (insuhu <= 35.25)) outsuhu = 36.20;
    if ((insuhu > 35.25) && (insuhu <= 36.00)) outsuhu = 36.30;
    if ((insuhu > 36.00) && (insuhu <= 36.75)) outsuhu = 36.40;
    if ((insuhu > 36.75) && (insuhu <= 37.50)) outsuhu = 36.50;
    if ((insuhu > 37.50) && (insuhu <= 38.25)) outsuhu = 36.60;
    if ((insuhu > 38.25) && (insuhu <= 39.00)) outsuhu = 36.70;
    if ((insuhu > 39.00) && (insuhu <= 39.75)) outsuhu = 36.80;
    if ((insuhu > 39.75) && (insuhu <= 41.25)) outsuhu = 36.90;
    if ((insuhu > 41.25) && (insuhu <= 42.00)) outsuhu = 37.00;
    //if (insuhu >= 42.00) outsuhu = insuhu;
    if ((insuhu > 42.00) || (insuhu < 28.00)) outsuhu = insuhu;
    return outsuhu;
  }

  /*void setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      recog = recognitions.toString();
    });
  }*/
  String cekMasker(CameraImage image) {
    Tflite.runModelOnFrame(
      bytesList: image.planes.map(
        (plane) {
          return plane.bytes;
        },
      ).toList(),
      imageHeight: image.height,
      imageWidth: image.width,
      numResults: 2,
    ).then(
      (recognitions) {
        recog = recognitions[0]["label"].toString();
      },
    );
    return recog;
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

  Future<imglib.Image> load(String name) async {
    tempDir = await getExternalStorageDirectory();
    String _embPath = tempDir.path + '/$name';
    ByteData imageBytes = await rootBundle.load(_embPath);
    List<int> values = imageBytes.buffer.asUint8List();
    imglib.Image img = imglib.decodeImage(values);
    return img;
  }

  void _initializeCamera() async {
    //int index1, index2, i;
    await loadModel();
    CameraDescription description = await getCamera(_direction);

    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera =
        CameraController(description, ResolutionPreset.low, enableAudio: false);
    await _camera.initialize();
    await Future.delayed(Duration(milliseconds: 500));
    //tempDir = await getApplicationDocumentsDirectory();
    tempDir = await getExternalStorageDirectory();
    String _embPath = tempDir.path + '/emb.json';
    jsonFile = new File(_embPath);
    if (jsonFile.existsSync()) {
      String original = await jsonFile.readAsString();
      if (original.compareTo("") == 0) {
        data = {};
        jsonFile.writeAsStringSync(json.encode(data));
      }
      data = json.decode(jsonFile.readAsStringSync());
    }
    //data = json.decode(jsonFile.readAsStringSync());
    _camera.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        //String out = cekMasker(image);
        log("Lagi deteksi");
        String res;
        dynamic finalResult = Multimap<String, Face>();
        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) async {
            if (result.length == 0) {
              _faceFound = false;
            }
            else {
              _faceFound = true;
            }
            Face _face;
            imglib.Image convertedImage =
                _convertCameraImage(image, _direction);
            int jum = 0;
            for (_face in result) {
              mul = 0;
              if (jum == 1)
                break;
              else
                jum++;
              //double x, y, w, h;
              x = (_face.boundingBox.left - 10);
              y = (_face.boundingBox.top - 10);
              w = (_face.boundingBox.width + 20);
              h = (_face.boundingBox.height + 20);

              imglib.Image croppedImage = imglib.copyCrop(
                  convertedImage, x.round(), y.round(), w.round(), h.round());
              //croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              //res = _recog(croppedImage);

              /*if ((w >= 60) &&
                  (w <= 90) &&
                  (x >= 60) &&
                  (x <= 110) &&
                  (y >= 100) &&
                  (y <= 160)) {*/
              /*if ((w >= 60) &&
                  (w <= 150) &&
                  (x >= 40) &&
                  (x <= 110) &&
                  (y >= 80) &&
                  (y <= 160)) {*/
              /*if ((w >= 100) &&
                  (w <= 150) &&
                  (x >= 40) &&
                  (x <= 110) &&
                  (y >= 80) &&
                  (y <= 160)) {
                if (st == 1) {*/

              if ((w >= 80) &&
                  (w <= 170) &&
                  (x >= 20) &&
                  (x <= 130) &&
                  (y >= 60) &&
                  (y <= 180)) {
                if (st == 1) {
                  SettingState.instance.sendOnMessageToBluetooth();
                  xsuhu1 = SettingState.instance
                      .bacaSuhu(SettingState.instance.jsonMessage);
                  double dbStatus1 = double.parse(xsuhu1);
                  temp = kalibrasi2(dbStatus1);
                  xsuhu = temp.toStringAsFixed(2);
                  int th = DateTime.now().year;
                  //int mt = DateTime.now().month;
                  //String str1 = "359306101792750"; Riyanto Sigit
                  //String str1 = "359306101508420"; //TAB1
                  //String str1 = "359306105515041"; //TAB2
                  //if (str1.compareTo(_platformImei) != 0) {
                  //if ((mt >= 8) || (th > 2021)) {
                  // if (th > 2022) {
                  //   xsuhu = "Hubungi:Lunari";
                  //   stTemp = "081295982363";
                  // } else {
                  stTemp = "NORMAL";
                  /*setSuhu = parsedJson['suhu'];
                  setMask = parsedJson['mask'];
                  setSound = parsedJson['sound'];*/
                  double setSH = double.parse(setSuhu);
                  double setSM = double.parse(setMask);
                  double setSS = double.parse(setSound);
                  if (temp >= setSH) {
                    stTemp = "DI ATAS NORMAL";
                    xwarna = 1;
                  } else {
                    stTemp = "NORMAL";
                    xwarna = 0;
                  }
                  co++;
                  if (co >= 7) {
                    //FaceRecState.instance.stopCamera();
                    //ScanQrCode();
                    croppedImage =
                        imglib.copyResizeCropSquare(croppedImage, 112);
                    res = _recog(croppedImage);
                    if (res == null) res = "PENGUNJUNG";
                    _res = res;
                    finalResult.add(_res, _face);
                    st = 0;
                    String tgl = ambilTanggal();
                    String jam = ambilJam();
                    dt = tgl + " " + jam;
                    String path = MyApp.imgDir;
                    String namafile = '$deviceID-$tgl$jam.png';
                    path = path + "/" + namafile;
                    _path = path;
                    _namefile = namafile;
                    _tgl = tgl;
                    _jam = jam;

                    imglib.Image croppedImage1 = imglib.copyCrop(
                        convertedImage,
                        x.round() - 25,
                        y.round() - 25,
                        w.round() + 50,
                        h.round() + 50);
                    /*x.round() + 35,
                        y.round() + 25,
                        w.round() - 70,
                        h.round() - 50);*/
                    croppedImage1 =
                        imglib.copyResizeCropSquare(croppedImage1, 128);
                    var pngFile = imglib.encodePng(croppedImage1);
                    new File(path).writeAsBytesSync(pngFile);

                    String path1 = MyApp.imgDir;
                    String namafile1 = 'temp.png';
                    path1 = path1 + "/" + namafile1;
                    imglib.Image croppedImage2 = imglib.copyCrop(
                        convertedImage,
                        /*x.round(),
                        y.round(),
                        w.round(),
                        h.round());*/
                        x.round() - 25,
                        y.round() - 25,
                        w.round() + 50,
                        h.round() + 50);
                    /*x.round() + 35,
                        y.round() + 25,
                        w.round() - 70,
                        h.round() - 50);*/
                    //croppedImage2 =
                    //    imglib.copyResizeCropSquare(croppedImage2, 32);

                    var pngFile1 = imglib.encodePng(croppedImage2);
                    new File(path1).writeAsBytesSync(pngFile1);
                    String nilai = await processImage(new File(path1));
                    int number = int.parse(nilai);
                    if (number == 0)
                      stMask = "MASK";
                    else
                      stMask = "NO MASK";
                    if (setSM == 1) {
                      if ((number != 0) && (setSS == 1)) {
                        xwarna = 2;
                        if (_res.compareTo('PENGUNJUNG') == 0)
                          text = "mohon menggunakan masker anda";
                        else
                          text = "$_res mohon menggunakan masker anda";
                        _speak();
                      } else {
                        if ((xwarna == 1) && (setSS == 1)) {
                          String str = xsuhu.replaceAll(".", ",");
                          if (_res.compareTo('PENGUNJUNG') == 0)
                            text = "maaf suhu tubuh anda diatas normal " +
                                str +
                                " derajat celsius";
                          else
                            text =
                                "$_res maaf suhu tubuh anda diatas normal " +
                                    str +
                                    " derajat celsius";
                          _speak();
                        }
                        if ((xwarna == 0) && (setSS == 1)) {
                          String str = xsuhu.replaceAll(".", ",");
                          if (_res.compareTo('PENGUNJUNG') == 0)
                            text = "suhu tubuh anda normal " +
                                str +
                                " derajat celsius";
                          else
                            text = "$_res suhu tubuh anda normal " +
                                str +
                                " derajat celsius";
                          // stopCamera1();
                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => ScanQrCode()));
                          _speak();
                        }
                      }
                    } else {
                      if ((xwarna == 1) && (setSS == 1)) {
                        String str = xsuhu.replaceAll(".", ",");
                        if (_res.compareTo('PENGUNJUNG') == 0)
                          text = "maaf suhu tubuh anda diatas normal " +
                              str +
                              " derajat celsius";
                        else
                          text = "$_res maaf suhu tubuh anda diatas normal " +
                              str +
                              " derajat celsius";
                        _speak();
                      }
                      if ((xwarna == 0) && (setSS == 1)) {
                        String str = xsuhu.replaceAll(".", ",");
                        if (_res.compareTo('PENGUNJUNG') == 0)
                          text = "suhu tubuh anda normal " +
                              str +
                              " derajat celsius";
                        else
                          text = "$_res suhu tubuh anda normal " +
                              str +
                              " derajat celsius";
                        _speak();
                      }
                    }
                    Contact contact =
                        Contact(_tgl, _jam, xsuhu, stTemp, stMask, path);
                    addContact(contact);
                    _backupdata(dt, deviceID, xsuhu, stTemp, stMask, _res,
                        _namefile, _path);

                    /*datastorage.read().then((String value) {
                      try {
                        _str = value;
                      } on Exception catch (e) {
                        print(e);
                        _str =
                            "{datetime=2021-04-07 20:11:35,deviceID=FCM001,temp=36.0,stTemp=NORMAL,stMask=NO MASK,name=PENGUNJUNG,namefile=FCM001-20210407201135.png,namepath=/storage/emulated/0/Android/data/com.rajatkalsotra.face_recognition/files/FCM001-20210407201135.png}\r\n";
                      }
                      /*_str =
                              "{datetime=2021-04-09 19:38:58,deviceID=FCM001,temp=36.1,stTemp=NORMAL,stMask=NO MASK,name=PENGUNJUNG,namefile=FCM001-20210409193858.png,namepath=/storage/emulated/0/Android/data/com.rajatkalsotra.face_recognition/files/FCM001-20210409193858.png}{datetime=2021-04-09 19:39:04,deviceID=FCM001,temp=36.2,stTemp=NORMAL,stMask=NO MASK,name=PENGUNJUNG,namefile=FCM001-20210409193904.png,namepath=/storage/emulated/0/Android/data/com.rajatkalsotra.face_recognition/files/FCM001-20210409193904.png}{datetime=2021-04-09 19:39:11,deviceID=FCM001,temp=36.1,stTemp=NORMAL,stMask=NO MASK,name=PENGUNJUNG,namefile=FCM001-20210409193911.png,namepath=/storage/emulated/0/Android/data/com.rajatkalsotra.face_recognition/files/FCM001-20210409193911.png}{datetime=2021-04-09 19:39:17,deviceID=FCM001,temp=36.1,stTemp=NORMAL,stMask=MASK,name=PENGUNJUNG,namefile=FCM001-20210409193917.png,namepath=/storage/emulated/0/Android/data/com.rajatkalsotra.face_recognition/files/FCM001-20210409193917.png}{datetime=2021-04-09 19:39:25,deviceID=FCM001,temp=36.1,stTemp=NORMAL,stMask=NO MASK,name=PENGUNJUNG,namefile=FCM001-20210409193925.png,namepath=/storage/emulated/0/Android/data/com.rajatkalsotra.face_recognition/files/FCM001-20210409193925.png}";*/
                      var arr1 = new List(500);
                      var arr2 = new List(500);
                      int co1 = 0;
                      int co2 = 0;
                      for (i = 0; i < _str.length; i++) {
                        if (_str[i] == '{') {
                          index1 = i;
                          arr1[co1] = index1;
                          co1++;
                          //print(index1);
                        }
                        if (_str[i] == '}') {
                          index2 = i;
                          arr2[co2] = index2;
                          co2++;
                          //print(index2);
                        }
                      }
                      //print(co2);
                      String str1;
                      jumSend = 0;
                      for (int j = 0; j < co2; j++) {
                        str1 = _str.substring(arr1[j], arr2[j]);
                        bacaData(str1);
                        sendDataAll(_datetime, _deviceID, _temp, _stTemp,
                            _stMask, _nama, _namefile, _namepath, _url);
                      }
                      //if (jumSend == co2) datastorage.clean();
                    });*/
                    _backupdata(dt, deviceID, xsuhu, stTemp, stMask, _res,
                        _namefile, _path);
                    String str1 =
                        "{datetime=$dt,deviceID=$deviceID,temp=$xsuhu,stTemp=$stTemp,stMask=$stMask,name=$_res,namefile=$_namefile,namepath=$_path}";
                    bacaData(str1);
                    sendDataAll(_datetime, _deviceID, _temp, _stTemp, _stMask,
                        _nama, _namefile, _namepath, _url);
                    setState(() {
                      showStatusBar = false;
                    });
                  }
                  setState(() {
                    _scanResults = finalResult;
                  });
                  // }
                }
                mul = 1;
                if (co >= 7) {
                  setState(() {
                    showStatusBar = true;
                  });
                }
              } else {
                if ((result.length > 1) && (mul == 1) && (co >= 7)) {
                  setState(() {
                    showStatusBar = true;
                  });
                } else {
                  st = 1;
                  co = 0;
                  mul = 0;
                  setState(() {
                    showStatusBar = false;
                  });
                }
              }
              if (_faceFound == false) {
                st = 1;
                co = 0;
                mul = 0;
                setState(() {
                  showStatusBar = false;
                });
              }
              //croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              // int startTime = new DateTime.now().millisecondsSinceEpoch;

              //res = _recog(croppedImage);
              //if (res == null) res = "Pengunjung";
              // int endTime = new DateTime.now().millisecondsSinceEpoch;
              // print("Inference took ${endTime - startTime}ms");
              finalResult.add(res, _face);
            }
            setState(() {
              _scanResults = finalResult;
              //_res = res;
            });

            _isDetecting = false;
          },
        ).catchError(
          (_) {
            _isDetecting = false;
          },
        );
      }
    });
  }

  HandleDetection _getDetectionMethod() {
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    return faceDetector.processImage;
  }

  /*Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }*/

  /*void _runTimer() async {
    Timer(Duration(seconds: 1), () {
      if (st == 2) {
        SettingState.instance.sendOnMessageToBluetooth();
        xsuhu1 =
            SettingState.instance.bacaSuhu(SettingState.instance.jsonMessage);
        SettingState.instance.sendOnMessageToBluetooth();
        xsuhu1 =
            SettingState.instance.bacaSuhu(SettingState.instance.jsonMessage);
        SettingState.instance.sendOnMessageToBluetooth();
        xsuhu1 =
            SettingState.instance.bacaSuhu(SettingState.instance.jsonMessage);
        double dbStatus1 = double.parse(xsuhu1);
        double dbStatus = kalibrasi(dbStatus1);
        xsuhu = dbStatus.toString();
        int tahun = DateTime.now().year;
        if (tahun > 2020)
          xsuhu = "Hubungi:Lunari";
        else {
          stn = "NORMAL";
          if (dbStatus >= 37.50) {
            stn = "ABNORMAL";
            xwarna = 1;
          } else {
            stn = "NORMAL";
            xwarna = 0;
          }
          co++;
          if (co >= 10) {
            st = 0;
            co = 0;
            if (xwarna == 1) {
              advancedPlayer = new AudioPlayer();
              audioCache = new AudioCache(fixedPlayer: advancedPlayer);
              audioCache.play('abnormal.mp3');
            }
          }
        }
      }
      _runTimer();
    });
  }*/

  Color getColor(int selector) {
    if (selector == 0) {
      //return Color.fromARGB(255, 66, 176, 191);
      return Color.fromARGB(255, 2, 156, 225);
    } else {
      return Color.fromARGB(255, 239, 75, 76);
    }
  }

  /*AssetImage getImage(int selector) {
    if (selector == 0) {
      return AssetImage("images/atasbiru.png");
    } else {
      return AssetImage("images/atasmerah.png");
    }
  }*/

  Text getText1(int selector) {
    Text t;
    switch (selector) {
      case (0):
        t = Text(
          "SELAMAT DATANG",
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 32,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        );
        break;
      case (1):
        t = Text(
          "MAAF ANDA TIDAK",
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 32,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        );
        break;
      case (2):
        t = Text(
          "MOHON MENGGUNAKAN",
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 32,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        );
        break;
    }
    return t;
  }

  Text getText2(int selector) {
    Text t;
    switch (selector) {
      case (0):
        t = Text(
          "SILAHKAN MASUK",
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 30,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        );
        break;
      case (1):
        t = Text(
          "DIPERKENANKAN MASUK",
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 30,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        );
        break;
      case (2):
        t = Text(
          "MASKER ANDA",
          style: TextStyle(
            decoration: TextDecoration.none,
            fontSize: 30,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        );
        break;
    }
    return t;
  }

  Widget _buildImage() {
    if (_camera == null || !_camera.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    //_runTimer();
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                //_buildResults(),
                Align(
                  alignment: Alignment.center,
                  child: Image(
                    image: AssetImage("images/blue_rect.png"),
                    fit: BoxFit.fill,
                    width: 320,
                    height: 320,
                  ),
                ),
                !showStatusBar
                    ? Align()
                    : Align(
                        child: ListView(children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(20),
                            margin: new EdgeInsets.only(
                              right: 0.0,
                              left: 0.0,
                              top: 0.0,
                            ),
                            width: 800.0,
                            height: 120.0,
                            alignment: Alignment.center,
                            //color: Color.fromARGB(255, 52, 188, 157),
                            color: getColor(xwarna),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                getText1(xwarna),
                                getText2(xwarna),
                              ],
                            ),
                          ),
                          Center(
                            child: Container(
                                padding: EdgeInsets.all(10),
                                margin: new EdgeInsets.only(
                                  right: 40.0,
                                  left: 40.0,
                                  top: 550.0,
                                ),
                                width: 800.0,
                                height: 100.0,
                                alignment: Alignment.center,
                                //color: Color.fromARGB(255, 52, 188, 157),
                                color: getColor(xwarna),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Text(
                                        "$xsuhu C",
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          fontSize: 60,
                                          fontFamily: "Montserrat",
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            "Suhu Tubuh Anda",
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              fontSize: 15,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            "$stTemp",
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              fontSize: 25,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          /*Text(
                                            "x=$x y=$y w=$w",
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              fontSize: 10,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),*/
                                        ],
                                      ),
                                    ])),
                          ),
                          showRegister
                              ? Container(
                                  margin: new EdgeInsets.only(
                                    right: 40.0,
                                    left: 40.0,
                                    top: 10.0,
                                  ),
                                  width: 800.0,
                                  height: 80.0,
                                  alignment: Alignment.center,
                                  color: Color.fromARGB(255, 2, 156, 225),
                                  child: Text(
                                    //"Tamu/Pengunjung",
                                    "$_res",
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 30,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container(
                                  margin: new EdgeInsets.only(
                                    right: 40.0,
                                    left: 40.0,
                                    top: 10.0,
                                  ),
                                  width: 800.0,
                                  height: 80.0,
                                  alignment: Alignment.center,
                                  color: Color.fromARGB(255, 2, 156, 225),
                                  child: Text(
                                    //"Tamu/Pengunjung",
                                    "UNREGISTER",
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 30,
                                      fontFamily: "Montserrat",
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        ]),
                      ),
              ],
            ),
    );
  }

  void stopCamera() async {
    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
      Navigator.pushNamed(context, '/');
    });
  }

  void stopCamera1() async {
    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });
  }

  /*void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildImage(),
      /*floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          backgroundColor: (_faceFound) ? Colors.blue : Colors.blueGrey,
          child: Icon(Icons.add),
          onPressed: () {
            if (_faceFound)
              //showDialog(context: context, builder: (_) => MyDialogDemo());
              _addLabel();
          },
          heroTag: null,
        ),
        SizedBox(
          height: 10,
        ),
      ]),*/
    );
  }

  /*imglib.Image _convertImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }*/

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }

  String _recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List(1 * 192).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1).toUpperCase();
  }

  String compare(List currEmb) {
    if (data.length == 0) return "PENGUNJUNG";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "PENGUNJUNG";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    print(minDist.toString() + " " + predRes);
    return predRes;
  }

  /*void _resetFile() {
    data = {};
    jsonFile.deleteSync();
  }

  void _viewLabels() {
    setState(() {
      _camera = null;
    });
    String name;
    var alert = new AlertDialog(
      title: new Text("Saved Faces"),
      content: new ListView.builder(
          padding: new EdgeInsets.all(2),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            name = data.keys.elementAt(index);
            return new Column(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    name,
                    style: new TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.all(2),
                ),
                new Divider(),
              ],
            );
          }),
      actions: <Widget>[
        new FlatButton(
          child: Text("OK"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }*/
  /*void _addLabel() {
    namaController.text = "";
    var alert = new AlertDialog(
      title: new Text("Add Face"),
      content: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: namaController,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Nama',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    _nama = value;
                  },
                ),
                RaisedButton(
                    child: Text("No Mask"),
                    color: Color.fromARGB(255, 2, 156, 225),
                    textColor: Colors.white,
                    onPressed: () {
                      String str = _nama.toUpperCase();
                      str = str + "_NOMASK";
                      _handle(str);
                      Navigator.pop(context);
                    }),
                Container(
                  width: 5.0,
                ),
                RaisedButton(
                    child: Text("Mask"),
                    color: Color.fromARGB(255, 2, 156, 225),
                    textColor: Colors.white,
                    onPressed: () {
                      String str = _nama.toUpperCase();
                      str = str + "_MASK";
                      _handle(str);
                      Navigator.pop(context);
                    }),
              ],
            ),
          ),
        ],
      ),
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }*/

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

  /*void _handle(String text) {
    Contact1 contact1 = Contact1(_tgl, _jam, text, _stTemp, _stMask, _path);
    addContact1(contact1);
    data[text] = e1;
    jsonFile.writeAsStringSync(json.encode(data));
    _backupmember(dt, deviceID, text, _namefile, _path);
    _initializeCamera();
  }*/

  void addContact(Contact object) async {
    int result = await dbHelper.insert(object);
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
          this.count = contactList.length;
        });
      });
    });
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
          this.count1 = contactList1.length;
        });
      });
    });
  }
}
