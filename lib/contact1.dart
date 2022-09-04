class Contact1 {
  int _id;
  String _dates;
  String _hours;
  String _name;
  String _sttemp;
  String _stmask;
  String _imgPath;
  String _memberID;

  // konstruktor versi 1
  Contact1(this._dates, this._hours, this._name, this._sttemp, this._stmask,
      this._imgPath, this._memberID);

  // konstruktor versi 2: konversi dari Map ke Contact
  Contact1.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._dates = map['dates'];
    this._hours = map['hours'];
    this._name = map['name'];
    this._sttemp = map['sttemp'];
    this._stmask = map['stmask'];
    this._imgPath = map['imgpath'];
    this._memberID = map['memberID'];
  }

  // getter
  int get id1 => _id;
  String get dates1 => _dates;
  String get hours1 => _hours;
  String get name1 => _name;
  String get sttemp1 => _sttemp;
  String get stmask1 => _stmask;
  String get imgPath1 => _imgPath;
  String get memberID1 => _memberID;

  // setter
  set dates(String value) {
    _dates = value;
  }

  set hours(String value) {
    _hours = value;
  }

  set name(String value) {
    _name = value;
  }

  set sttemp(String value) {
    _sttemp = value;
  }

  set stmask(String value) {
    _stmask = value;
  }

  set imgPath(String value) {
    _imgPath = value;
  }

  set memberID(String value) {
    _memberID = value;
  }

  // konversi dari Contact ke Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = this._id;
    map['dates'] = dates1;
    map['hours'] = hours1;
    map['name'] = name1;
    map['sttemp'] = sttemp1;
    map['stmask'] = stmask1;
    map['imgpath'] = imgPath1;
    map['memberID'] = memberID1;
    return map;
  }
}
