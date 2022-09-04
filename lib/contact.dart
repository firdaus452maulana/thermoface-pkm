class Contact {
  int _id;
  String _dates;
  String _hours;
  String _temp;
  String _sttemp;
  String _stmask;
  String _imgPath;

  // konstruktor versi 1
  Contact(this._dates, this._hours, this._temp, this._sttemp, this._stmask,
      this._imgPath);

  // konstruktor versi 2: konversi dari Map ke Contact
  Contact.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._dates = map['dates'];
    this._hours = map['hours'];
    this._temp = map['temp'];
    this._sttemp = map['sttemp'];
    this._stmask = map['stmask'];
    this._imgPath = map['imgpath'];
  }

  // getter
  int get id1 => _id;
  String get dates1 => _dates;
  String get hours1 => _hours;
  String get temp1 => _temp;
  String get sttemp1 => _sttemp;
  String get stmask1 => _stmask;
  String get imgPath1 => _imgPath;

  // setter
  set dates(String value) {
    _dates = value;
  }

  set hours(String value) {
    _hours = value;
  }

  set temp(String value) {
    _temp = value;
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

  // konversi dari Contact ke Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = this._id;
    map['dates'] = dates1;
    map['hours'] = hours1;
    map['temp'] = temp1;
    map['sttemp'] = sttemp1;
    map['stmask'] = stmask1;
    map['imgpath'] = imgPath1;
    return map;
  }
}
