import 'dart:io';

import 'package:face_recognition/contact.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  static DbHelper _dbHelper;
  static Database _database;

  DbHelper._createObject();

  factory DbHelper() {
    if (_dbHelper == null) {
      _dbHelper = DbHelper._createObject();
    }
    return _dbHelper;
  }

  Future<Database> initDb() async {
    Directory directory = await getExternalStorageDirectory();
    String path = directory.path + 'face.db';
    var todoDatabase = openDatabase(path, version: 2, onCreate: _createDb);
    return todoDatabase;
  }

  void _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contact (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dates TEXT,
        hours TEXT,
        temp TEXT,
        sttemp TEXT,
        stmask TEXT,
        imgpath TEXT
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

  Future<int> insert(Contact object) async {
    Database db = await this.database;
    int count = await db.insert('contact', object.toMap());
    return count;
  }

  Future<int> update(Contact object) async {
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

  Future<List<Contact>> getContactList() async {
    var contactMapList = await select();
    int count = contactMapList.length;
    // ignore: deprecated_member_use
    List<Contact> contactList = List<Contact>();
    for (int i = 0; i < count; i++) {
      contactList.add(Contact.fromMap(contactMapList[i]));
    }
    return contactList;
  }
}
