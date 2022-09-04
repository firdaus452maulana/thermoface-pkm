import 'dart:io';

import 'package:face_recognition/contact1.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper1 {
  static DbHelper1 _dbHelper;
  static Database _database;

  DbHelper1._createObject();

  factory DbHelper1() {
    if (_dbHelper == null) {
      _dbHelper = DbHelper1._createObject();
    }
    return _dbHelper;
  }

  Future<Database> initDb() async {
    Directory directory = await getExternalStorageDirectory();
    String path = directory.path + 'member.db';
    var todoDatabase = openDatabase(path, version: 2, onCreate: _createDb);
    return todoDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contact (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dates TEXT,
        hours TEXT,
        name TEXT,
        sttemp TEXT,
        stmask TEXT,
        imgpath TEXT,
        memberID TEXT
      )
    ''');
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initDb();
    }
    return _database;
  }

  Future<List<Map<String, dynamic>>> select() async {
    Database db = await this.database;
    var mapList = await db.query('contact', orderBy: 'dates');
    return mapList;
  }

  Future<int> insert(Contact1 object) async {
    Database db = await this.database;
    int count = await db.insert('contact', object.toMap());
    return count;
  }

  Future<int> update(Contact1 object) async {
    Database db = await this.database;
    int count = await db.update('contact', object.toMap(),
        where: 'id=?', whereArgs: [object.id1]);
    return count;
  }

  Future<int> delete(int id) async {
    Database db = await this.database;
    int count = await db.delete('contact', where: 'id=?', whereArgs: [id]);
    return count;
  }

  Future<String> query(String nik) async {
    int i, index1, index2;
    String str;
    String name;
    Database db = await this.database;
    //List<Map> result = await db.query('contact');
    List<Map> result =
    await db.rawQuery('SELECT * FROM contact WHERE memberID=?', [nik]);
    result.forEach((row) {
      str = row.toString();
      print(str);
      index1 = str.indexOf("name");
      for (i = index1 + 6; i < str.length; i++) if (str[i] == ',') break;
      index2 = i;
      name = str.substring(index1 + 6, index2);
      print(name);
    });
    return name;
  }

  Future<List<Contact1>> getContactList() async {
    var contactMapList = await select();
    int count = contactMapList.length;
    // ignore: deprecated_member_use
    List<Contact1> contactList = List<Contact1>();
    for (int i = 0; i < count; i++) {
      contactList.add(Contact1.fromMap(contactMapList[i]));
    }
    return contactList;
  }
}
