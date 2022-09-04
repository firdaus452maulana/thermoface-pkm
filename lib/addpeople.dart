import 'dart:convert';
import 'dart:io';
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
import 'package:face_recognition/contact1.dart';
import 'package:face_recognition/dbhelper1.dart';
import 'package:sqflite/sqflite.dart';
import 'package:face_recognition/main.dart';
import 'package:face_recognition/devicestorage.dart';
import 'package:http/http.dart' as http;
import 'package:face_recognition/memberstorage.dart';

class AddPeople extends StatefulWidget {
  @override
  AddPeopleState createState() => AddPeopleState();
}

class AddPeopleState extends State<AddPeople> {
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
  bool _faceFound = false;
  final TextEditingController _name = new TextEditingController();
  final TextEditingController _memberid = new TextEditingController();
  imglib.Image croppedImage, croppedImage1;
  String name, mask;
  DbHelper1 dbHelper1 = DbHelper1();
  List<Contact1> contactList1;
  int count1 = 0;
  String _str;
  DeviceStorage devicestorage = new DeviceStorage();
  String deviceID = "FCM001";
  String res = "PENGUNJUNG";
  String _url = "http://27.111.44.44/ws/api_tf";
  MemberStorage memberstorage = new MemberStorage();
  String dt;
  String _path;
  String _tgl;
  String _jam;
  String _res = "";

  int index1, index2, i;
  String _datetime = "",
      _deviceID = "FCM002",
      _namepath = "d:/data/",
      _nama = "",
      _namefile = "coba.png",
      _updateData = "",
      _fiturData = "",
      _fiturSrc = "",
      _memberID = "";
  double x, y, w, h;
  imglib.Image convertedImage;

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

  @override
  void initState() {
    super.initState();

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

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();
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

  /*void _resetFile() {
    data = {};
    jsonFile.deleteSync();
  }*/

  void _initializeCamera() async {
    await loadModel();
    CameraDescription description = await getCamera(_direction);

    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera =
        CameraController(description, ResolutionPreset.low, enableAudio: false);
    await _camera.initialize();
    await Future.delayed(Duration(milliseconds: 500));
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
    _camera.startImageStream((CameraImage image) {
      if (_camera != null) {
        if (_isDetecting) return;
        _isDetecting = true;
        String res;
        dynamic finalResult = Multimap<String, Face>();
        detect(image, _getDetectionMethod(), rotation).then(
          (dynamic result) async {
            if (result.length == 0)
              _faceFound = false;
            else
              _faceFound = true;
            Face _face;
            convertedImage = _convertCameraImage(image, _direction);
            for (_face in result) {
              //double x, y, w, h;
              x = (_face.boundingBox.left - 10);
              y = (_face.boundingBox.top - 10);
              w = (_face.boundingBox.width + 10);
              h = (_face.boundingBox.height + 10);
              /*croppedImage = imglib.copyCrop(
                  convertedImage, x.round(), y.round(), w.round(), h.round());
              croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
              res = _recog(croppedImage);*/
              /*croppedImage1 = imglib.copyCrop(convertedImage, x.round() - 25,
                  y.round() - 25, w.round() + 50, h.round() + 50);
              croppedImage1 = imglib.copyResizeCropSquare(croppedImage1, 128);*/

              finalResult.add(res, _face);
            }
            setState(() {
              _scanResults = finalResult;
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

  Widget _buildImage() {
    if (_camera == null || !_camera.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera),
                Align(
                  alignment: Alignment.center,
                  child: Image(
                    image: AssetImage("images/blue_rect.png"),
                    fit: BoxFit.fill,
                    width: 320,
                    height: 320,
                  ),
                ),
                //_buildResults(),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
        //actions: <Widget>[
        /*FlatButton(
            textColor: Colors.white,
            onPressed: () {
              KirimData();
            },
            child: Text("Send all faces"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),*/
        /*PopupMenuButton<Choice>(
            onSelected: (Choice result) {
              if (result == Choice.delete) _resetFile();
              if (result == Choice.view) _viewLabels();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Choice>>[
              const PopupMenuItem<Choice>(
                child: Text('View Saved Faces'),
                value: Choice.view,
              ),
              const PopupMenuItem<Choice>(
                child: Text('Remove all faces'),
                value: Choice.delete,
              ),
            ],
          ),*/
        //],
      ),
      body: _buildImage(),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          backgroundColor: (_faceFound) ? Colors.blue : Colors.blueGrey,
          child: Icon(Icons.add),
          onPressed: () {
            if (_faceFound) _addLabel();
          },
          heroTag: null,
        ),
        /*SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          backgroundColor: (_faceFound) ? Colors.blue : Colors.blueGrey,
          child: Icon(Icons.send),
          onPressed: () {
            setState(() {
              memberstorage.read().then((String value) {
                try {
                  _str = value;
                } on Exception catch (e) {
                  print(e);
                  _str =
                      "{datetime=2021-04-07 20:11:35,deviceID=FCM001,name=PENGUNJUNG,namefile=FCM001-20210407201135.png,namepath=/storage/emulated/0/Android/data/com.rajatkalsotra.face_recognition/files/FCM001-20210407201135.png}\r\n";
                }
                var arr1 = new List(500);
                var arr2 = new List(500);
                int co1 = 0;
                int co2 = 0;
                for (i = 0; i < _str.length; i++) {
                  if (_str[i] == '{') {
                    index1 = i;
                    arr1[co1] = index1;
                    co1++;
                  }
                  if (_str[i] == '}') {
                    index2 = i;
                    arr2[co2] = index2;
                    co2++;
                  }
                }
                String str1;
                int jumErr = 0;
                for (int j = 0; j < co2; j++) {
                  str1 = _str.substring(arr1[j], arr2[j]);
                  bacaMember(str1);
                  sendMember(_datetime, _deviceID, _nama, _namefile,
                      _updateData, _namepath, _fiturData, _fiturSrc, _url);
                }
                print(jumErr);
                //memberstorage.clean();
              });
            });
          },
          heroTag: null,
        ),
        SizedBox(
          height: 10,
        ),*/
      ]),
    );
  }

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
  }

  /*void _resetFile() {
    data = {};
    jsonFile.deleteSync();
  }*/

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

  /*void _viewLabels() {
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

  void _addLabel() {
    setState(() {
      _camera = null;
    });
    print("Adding new face");
    var alert = new AlertDialog(
      title: new Text("Add Face"),
      content: new Column(
        children: <Widget>[
          new Expanded(
            child: new TextField(
              controller: _name,
              autofocus: true,
              decoration: new InputDecoration(
                  //labelText: "NAMA", icon: new Icon(Icons.face)),
                  border: OutlineInputBorder(),
                  labelText: "NAME"),
            ),
          ),
          new Expanded(
            child: new TextField(
              controller: _memberid,
              autofocus: true,
              decoration: new InputDecoration(
                  border: OutlineInputBorder(), labelText: "Member ID"),
            ),
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            child: Text("Save"),
            onPressed: () {
              _handle(_name.text.toUpperCase(), _memberid.text.toUpperCase());
              _name.clear();
              Navigator.pop(context);
            }),
        new FlatButton(
          child: Text("Cancel"),
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
      String url,
      String memberID) async {
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
    for (i = index1 + 10; i < str.length; i++) if (str[i] == ',') break;
    index2 = i;
    _fiturSrc = str.substring(index1 + 10, index2);
    index1 = str.indexOf("memberID");
    for (i = index1 + 9; i < str.length; i++) if (str[i] == '}') break;
    index2 = i;
    _memberID = str.substring(index1 + 9, index2);
  }

  Future<File> _backupmember(
      String datetime,
      String deviceID,
      String name,
      String namefile,
      String updateData,
      String picture,
      String fiturData,
      String fiturSrc,
      String memberID) {
    String str;
    setState(() {
      str =
          "{datetime=$datetime,deviceID=$deviceID,name=$name,namefile=$namefile,update_data=$updateData,picture=$picture,fitur_data=$fiturData,fitur_src=$fiturSrc,memberID=$memberID}";
    });
    return memberstorage.write(str);
  }

  void _handle(String nama, String memberID) async {
    String tgl = ambilTanggal();
    String jam = ambilJam();
    dt = tgl + " " + jam;
    String path = MyApp.imgDir;
    String namafile = "$deviceID-$tgl$jam.png";
    path = path + "/" + namafile;
    _path = path;
    _namefile = namafile;
    _tgl = tgl;
    _jam = jam;

    croppedImage = imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
    croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
    res = _recog(croppedImage);
    croppedImage1 = imglib.copyCrop(convertedImage, x.round() - 25,
        y.round() - 25, w.round() + 50, h.round() + 50);
    croppedImage1 = imglib.copyResizeCropSquare(croppedImage1, 128);

    var pngFile = imglib.encodePng(croppedImage1);
    new File(_path).writeAsBytesSync(pngFile);

    Contact1 contact1 =
        Contact1(_tgl, _jam, nama, "NORMAL", "NO MASK", _path, memberID);
    addContact1(contact1);
    data[nama] = e1;
    jsonFile.writeAsStringSync(json.encode(data));

    String fiturData = "";
    String original = await jsonFile.readAsString();
    index1 = original.indexOf(nama);
    int pj = nama.length;
    index1 = index1 + pj + 2;
    for (i = index1; i < original.length; i++) if (original[i] == ']') break;
    index2 = i;
    fiturData = original.substring(index1, index2 + 1);
    _backupmember(dt, deviceID, nama, namafile, "send_fitur", path, fiturData,
        deviceID, memberID);
    String str1 =
        "{datetime=$dt,deviceID=$deviceID,name=$nama,namefile=$namafile,update_data=send_fitur,picture=$path,fitur_data=$fiturData,fitur_src=$deviceID,memberID=$memberID}";
    bacaMember(str1);
    sendMember(_datetime, _deviceID, _nama, _namefile, _updateData, _namepath,
        _fiturData, _fiturSrc, _url, _memberID);
    _initializeCamera();
  }
}
