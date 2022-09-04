import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:image/image.dart' as imglib;

class AddPhoto extends StatefulWidget {
  @override
  AddPhotoState createState() => AddPhotoState();
}

class AddPhotoState extends State<AddPhoto> {
  //final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  Future loadFile() async {
    //final ImagePicker _picker = ImagePicker();
    //var image=await _picker.pickImage(source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Add Photo"),
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
              Container(
                  margin: EdgeInsets.all(5),
                  child: RaisedButton(
                      child: Text('     Load File      '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        loadFile();
                      })),
            ])));
  }
}
