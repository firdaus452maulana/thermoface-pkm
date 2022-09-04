import 'dart:io';
import 'package:face_recognition/contact.dart';
import 'package:face_recognition/dbhelper.dart';
import 'package:face_recognition/entryform.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class Record extends StatefulWidget {
  @override
  RecordState createState() => RecordState();
}

class RecordState extends State<Record> {
  DbHelper dbHelper = DbHelper();
  int count = 0;
  int numb = 0;
  int start = 0;
  List<Contact> contactList;

  @override
  Widget build(BuildContext context) {
    if (contactList == null) {
      contactList = List<Contact>();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 2, 156, 225),
        title: Text('Record'),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                numb = 1;
              });
            },
            child: Text("Today"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                numb = 2;
              });
            },
            child: Text("Yesterday"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                numb = 3;
              });
            },
            child: Text("7 Days"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              deleteAll();
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
      /*Column(children: <Widget>[
          Image(
            image: AssetImage("images/atas.png"),
            fit: BoxFit.fill,
            width: 800,
            height: 168,
          ),
          createListView(),
        ])*/
      /*floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () {
          Navigator.pushNamed(context, '/');
        },
      ),*/
    );
  }

  Future<Contact> navigateToEntryForm(
      BuildContext context, Contact contact) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return EntryForm(contact);
    }));
    return result;
  }

  ListView createListView() {
    //var contact = navigateToEntryForm(context, null);
    // ignore: deprecated_member_use
    updateListView();
    // ignore: deprecated_member_use
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red,
              backgroundImage: FileImage(File(
                  contactList[contactList.length - index - 1 - start]
                      .imgPath1)),
            ),
            title: Text(
              this.contactList[contactList.length - index - 1 - start].temp1 +
                  "  " +
                  this
                      .contactList[contactList.length - index - 1 - start]
                      .sttemp1 +
                  "  " +
                  this
                      .contactList[contactList.length - index - 1 - start]
                      .stmask1,
              //style: TextStyle(fontWeight: FontWeight.bold),
              style: textStyle,
            ),
            subtitle: Text(this
                    .contactList[contactList.length - index - 1 - start]
                    .dates1 +
                "  " +
                this
                    .contactList[contactList.length - index - 1 - start]
                    .hours1),
            trailing: GestureDetector(
              child: Icon(Icons.delete),
              onTap: () {
                deleteContact(
                    contactList[contactList.length - index - 1 - start]);
              },
            ),
            onTap: () async {
              var contact = await navigateToEntryForm(context,
                  this.contactList[contactList.length - index - 1 - start]);
              if (contact != null) editContact(contact);
            },
          ),
        );
      },
    );
  }

  void addContact(Contact object) async {
    int result = await dbHelper.insert(object);
    if (result > 0) {
      updateListView();
    }
  }

  void editContact(Contact object) async {
    int result = await dbHelper.update(object);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteContact(Contact object) async {
    int result = await dbHelper.delete(object.id1);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteAll() async {
    for (int x = 0; x < contactList.length; x++) {
      deleteContact(contactList[x]);
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Contact>> contactListFuture = dbHelper.getContactList();
      contactListFuture.then((contactList) {
        setState(() {
          this.contactList = contactList;
          if (numb == 0) {
            start = 0;
            this.count = contactList.length;
          }
          if (numb == 1) {
            start = 0;
            this.count = today();
          }
          if (numb == 2) {
            start = today();
            this.count = yesterday();
          }
          if (numb == 3) {
            start = 0;
            this.count = weekday();
          }
        });
      });
    });
  }

  int today() {
    int tahun = DateTime.now().year;
    int month = DateTime.now().month;
    int day = DateTime.now().day;
    String smonth = month.toString().padLeft(2, '0');
    String sday = day.toString().padLeft(2, '0');
    String tgl = "$tahun-$smonth-$sday";
    int jum = 0;
    for (int i = 0; i < contactList.length; i++) {
      if (contactList[i].dates1.compareTo(tgl) == 0) jum++;
    }
    return jum;
  }

  int yesterday() {
    DateTime now = DateTime.now();
    DateTime yd = now.subtract(Duration(days: 1));
    int tahun = yd.year;
    int month = yd.month;
    int day = yd.day;
    String smonth = month.toString().padLeft(2, '0');
    String sday = day.toString().padLeft(2, '0');
    String tgl = "$tahun-$smonth-$sday";
    int jum = 0;
    for (int i = 0; i < contactList.length; i++) {
      if (contactList[i].dates1.compareTo(tgl) == 0) jum++;
    }
    return jum;
  }

  int weekday() {
    int jum = today();
    DateTime now = DateTime.now();
    for (int j = 1; j <= 7; j++) {
      DateTime yd = now.subtract(Duration(days: j));
      int tahun = yd.year;
      int month = yd.month;
      int day = yd.day;
      String smonth = month.toString().padLeft(2, '0');
      String sday = day.toString().padLeft(2, '0');
      String tgl = "$tahun-$smonth-$sday";
      for (int i = 0; i < contactList.length; i++) {
        if (contactList[i].dates1.compareTo(tgl) == 0) jum++;
      }
    }
    return jum;
  }
}
