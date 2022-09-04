import 'package:face_recognition/contact.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class EntryForm extends StatefulWidget {
  final Contact contact;

  EntryForm(this.contact);

  @override
  EntryFormState createState() => EntryFormState(this.contact);
}

class EntryFormState extends State<EntryForm> {
  Contact contact;

  EntryFormState(this.contact);

  /*TextEditingController datesController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  TextEditingController tempController = TextEditingController();
  TextEditingController sttempController = TextEditingController();
  TextEditingController stmaskController = TextEditingController();*/
  String date, hours, temp, sttemp, stmask, imagePath;

  @override
  Widget build(BuildContext context) {
    if (contact != null) {
      /*datesController.text = contact.dates1;
      hoursController.text = contact.hours1;
      tempController.text = contact.temp1;
      sttempController.text = contact.sttemp1;
      stmaskController.text = contact.stmask1;*/
      date = contact.dates1;
      hours = contact.hours1;
      temp = contact.temp1;
      imagePath = contact.imgPath1;
      sttemp = contact.sttemp1;
      stmask = contact.stmask1;
    }

    return Scaffold(
      /*appBar: AppBar(
        title: contact == null ? Text('Tambah Data') : Text('Ubah Data'),
        leading: Icon(Icons.keyboard_arrow_left),
      ),*/
      appBar: new AppBar(
        backgroundColor: Color.fromARGB(255, 2, 156, 225),
        title: Text("Editor"),
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
            Image(
              image: AssetImage("images/atas.png"),
              fit: BoxFit.fill,
              width: 800,
              height: 168,
            ),
            SizedBox(
              height: 50,
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
            /*Container(
                width: 120,
                height: 120,
                color: Colors.green,
                child: Image.file(File(imagePath))),*/
            SizedBox(
              height: 50,
            ),
            Container(
              width: 800,
              height: 160,
              //color: Colors.white,
              margin: const EdgeInsets.all(10.0),
              child: Text(
                'Date: $date\nHours: $hours\nTemperature: $temp\nStatus Temp: $sttemp\nStatus Mask: $stmask',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
      ),*/
      /*
        Padding(
          padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
          child: ListView(
            children: <Widget>[
              // nama
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: TextField(
                  controller: tempController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Suhu',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    //
                  },
                ),
              ),
              // tombol
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    // tombol simpan
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Simpan',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          int tahun = DateTime.now().year;
                          int month = DateTime.now().month;
                          int day = DateTime.now().day;
                          int hh = DateTime.now().hour;
                          int mm = DateTime.now().minute;
                          int ss = DateTime.now().second;
                          String tgl = "$tahun-$month-$day";
                          String jam = "$hh:$mm:$ss";
                          double dbStatus = double.parse(tempController.text);
                          String st = "NORMAL";
                          if (dbStatus >= 37.5)
                            st = "ABNORMAL";
                          else
                            st = "NORMAL";
                          if (contact == null) {
                            // tambah data
                            contact = Contact(
                                tgl, jam, tempController.text, st, "MASK", "");
                          } else {
                            // ubah data
                            contact.dates = tgl;
                            contact.hours = jam;
                            contact.temp = tempController.text;
                            contact.sttemp = "NORM";
                            contact.stmask = "MASK";
                          }
                          
                          // kembali ke layar sebelumnya dengan membawa objek contact
                          Navigator.pop(context, contact);
                        },
                      ),
                    ),
                    Container(
                      width: 5.0,
                    ),
                    // tombol batal
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text(
                          'Batal',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )*/
    );
  }
}
