import 'package:flutter/material.dart';
import 'package:face_recognition/setconstorage.dart';
import 'dart:io';

class Suhu extends StatefulWidget {
  final SetconStorage storage;
  Suhu({Key key, @required this.storage}) : super(key: key);
  @override
  InitState createState() => InitState();
}

class InitState extends State<Suhu> {
  String _str = '{suhu=37.5,orang=50,mask=0,sound=0}';
  bool isSwitchedMask = true;
  bool isSwitchedSound = true;
  String _suhu = "37.5";
  String _mask = "1";
  String _sound = "1";

  @override
  void initState() {
    int index1, index2, i;
    super.initState();
    widget.storage.read().then((String value) {
      try {
        _str = value;
      } on Exception catch (e) {
        print(e);
        _str = '{suhu=37.5,mask=0,sound=0}';
      }
      setState(() {
        index1 = _str.indexOf("suhu");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _suhu = _str.substring(index1 + 5, index2);
        index1 = _str.indexOf("mask");
        for (i = index1 + 5; i < _str.length; i++) if (_str[i] == ',') break;
        index2 = i;
        _mask = _str.substring(index1 + 5, index2);
        index1 = _str.indexOf("sound");
        for (i = index1 + 6; i < _str.length; i++) if (_str[i] == '}') break;
        index2 = i;
        _sound = _str.substring(index1 + 6, index2);
        if (_mask.compareTo("0") == 0)
          isSwitchedMask = false;
        else
          isSwitchedMask = true;
        if (_sound.compareTo("0") == 0)
          isSwitchedSound = false;
        else
          isSwitchedSound = true;
      });
    });
  }

  Future<File> _inputString() {
    setState(() {
      _str = "{suhu=$_suhu,mask=$_mask,sound=$_sound}";
    });
    return widget.storage.write(_str);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Suhu"),
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
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                        Widget>[
                  Expanded(
                    child: Text(
                      'Temperature Alert (C)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  DropdownButton(
                      value: _suhu,
                      items: [
                        DropdownMenuItem(child: Text("37.3"), value: "37.3"),
                        DropdownMenuItem(child: Text("37.4"), value: "37.4"),
                        DropdownMenuItem(child: Text("37.5"), value: "37.5"),
                        DropdownMenuItem(child: Text("37.6"), value: "37.6"),
                        DropdownMenuItem(child: Text("37.7"), value: "37.7"),
                        DropdownMenuItem(child: Text("37.8"), value: "37.8"),
                        DropdownMenuItem(child: Text("37.9"), value: "37.9"),
                        DropdownMenuItem(child: Text("38.0"), value: "38.0")
                      ],
                      onChanged: (value) {
                        setState(() {
                          _suhu = value;
                        });
                      }),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Mask Settings',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: isSwitchedMask,
                        onChanged: (value) {
                          setState(() {
                            isSwitchedMask = value;
                            if (isSwitchedMask == false)
                              _mask = "0";
                            else
                              _mask = "1";
                          });
                        },
                        activeTrackColor: Color.fromARGB(255, 2, 156, 200),
                        activeColor: Color.fromARGB(255, 2, 156, 225),
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
                          'Abnormal Temperature Sound',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Switch(
                        value: isSwitchedSound,
                        onChanged: (value) {
                          setState(() {
                            isSwitchedSound = value;
                            if (isSwitchedSound == false)
                              _sound = "0";
                            else
                              _sound = "1";
                          });
                        },
                        activeTrackColor: Color.fromARGB(255, 2, 156, 200),
                        activeColor: Color.fromARGB(255, 2, 156, 225),
                      ),
                    ]),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    // tombol simpan
                    Expanded(
                      child: RaisedButton(
                        //color: Theme.of(context).primaryColorDark,
                        color: Color.fromARGB(255, 2, 156, 225),
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Simpan',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          _inputString();
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                    ),
                    Container(
                      width: 5.0,
                    ),
                    // tombol batal
                    Expanded(
                      child: RaisedButton(
                        //color: Theme.of(context).primaryColorDark,
                        color: Color.fromARGB(255, 2, 156, 225),
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Batal',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          //Navigator.pop(context);
                          Navigator.pushNamed(context, '/');
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
