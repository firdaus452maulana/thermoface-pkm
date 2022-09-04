import 'package:face_recognition/init.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition/devicestorage.dart';

class Password extends StatefulWidget {
  final DeviceStorage storage;
  Password({Key key, @required this.storage}) : super(key: key);
  @override
  InitState createState() => InitState();
}

class InitState extends State<Password> {
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String _user = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          title: Text("Password"),
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
                  controller: userController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'User',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    _user = value;
                    print(_user);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    _password = value;
                    print(_password);
                  },
                ),
              ),
              Container(
                  margin: EdgeInsets.all(5),
                  child: FlatButton(
                      child: Text('    login     '),
                      color: Color.fromARGB(255, 2, 156, 225),
                      textColor: Colors.white,
                      onPressed: () {
                        //_inputString();
                        if ((_user.compareTo("asdfgh") == 0) &&
                            (_password.compareTo("123456") == 0)) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Init(storage: DeviceStorage());
                          }));
                        } else {
                          Navigator.pushNamed(context, '/');
                        }
                      })),
            ])));
  }
}
