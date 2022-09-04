import 'package:face_recognition/contact.dart';
import 'package:face_recognition/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class Statistic extends StatefulWidget {
  @override
  _StatisticState createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  Map<String, double> data = new Map();
  bool _loadChart = true;
  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Contact> contactList;
  int jumTotal, jumNormal, jumAbnormal;
  int i;
  int numb = 0;
  int start = 0;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  List<Color> _colors = [
    Color.fromARGB(255, 2, 156, 225),
    //Colors.teal,
    //Colors.blueAccent,
    //Colors.amberAccent,
    //Colors.redAccent
    Color.fromARGB(255, 239, 75, 76),
  ];

  @override
  Widget build(BuildContext context) {
    updateListView();
    if (contactList == null) {
      // ignore: deprecated_member_use
      contactList = List<Contact>();
    }
    String norm;
    String abnorm;
    double dnorm;
    double dabnorm;
    if (jumTotal != 0) {
      norm = "Normal";
      abnorm = "Abnormal";
      dnorm = jumNormal.toDouble();
      dabnorm = jumAbnormal.toDouble();
    } else {
      norm = "Normal";
      abnorm = "Abnormal";
      dnorm = 0;
      dabnorm = 0;
    }
    //double dnorm = 100;
    //double dabnorm = 10;
    data.addAll({norm: dnorm, abnorm: dabnorm});
    //updateListView();
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Color.fromARGB(255, 66, 176, 191),
        backgroundColor: Color.fromARGB(255, 2, 156, 225),
        //r:47 g:156 b:186
        title: Text("Statistic"),
        actions: <Widget>[
          RaisedButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                numb = 1;
              });
            },
            child: Text("Today"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          RaisedButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                numb = 2;
              });
            },
            child: Text("Yesterday"),
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
          RaisedButton(
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                numb = 3;
              });
            },
            child: Text("7 Days"),
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
      body: Center(
        child: Column(
          children: <Widget>[
            Image(
              image: AssetImage("images/atas.png"),
              fit: BoxFit.fill,
              width: 800,
              height: 168,
            ),
            SizedBox(
              height: 30,
            ),
            _loadChart
                ? PieChart(
                    dataMap: data,
                    colorList:
                        _colors, // if not declared, random colors will be chosen
                    animationDuration: Duration(milliseconds: 1500),
                    chartLegendSpacing: 32.0,
                    chartRadius: MediaQuery.of(context).size.width /
                        2.7, //determines the size of the chart
                    showChartValuesInPercentage: true,
                    showChartValues: true,
                    showChartValuesOutside: false,
                    chartValueBackgroundColor: Colors.grey[200],
                    showLegends: true,
                    legendPosition: LegendPosition
                        .bottom, //can be changed to top, left, bottom
                    decimalPlaces: 1,
                    showChartValueLabel: true,
                    initialAngle: 0,
                    chartValueStyle: defaultChartValueStyle.copyWith(
                      color: Colors.blueGrey[900].withOpacity(0.9),
                    ),
                    chartType:
                        ChartType.disc, //can be changed to ChartType.ring
                  )
                : SizedBox(
                    height: 150,
                  ),
            SizedBox(
              height: 50,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Container(
                width: 130,
                height: 75,
                color: Color.fromARGB(255, 16, 132, 121),
                child: Text(
                  'Recognition\ncount\n$jumTotal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 130,
                height: 75,
                color: Color.fromARGB(255, 2, 156, 225),
                child: Text(
                  'Normal\ncount\n$jumNormal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 10,
              ),
              Container(
                width: 130,
                height: 75,
                color: Color.fromARGB(255, 239, 75, 76),
                child: Text(
                  'Abnormal\ncount\n$jumAbnormal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )
            ]),
            SizedBox(
              height: 50,
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
    );
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
          jumTotal = this.count;
          print(jumTotal);
          jumNormal = 0;
          for (i = start; i < this.count; i++) {
            if (this.contactList[i].sttemp1.compareTo("NORMAL") == 0)
              jumNormal++;
          }
          print(jumNormal);
          jumAbnormal = jumTotal - jumNormal;
          print(jumAbnormal);
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
