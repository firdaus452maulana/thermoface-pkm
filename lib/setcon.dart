class Setcon {
  int _id;
  String _temp;
  String _total;
  String _mask;
  String _sound;

  // konstruktor versi 1
  Setcon(this._id, this._temp, this._total, this._mask, this._sound);

  // konstruktor versi 2: konversi dari Map ke Contact
  Setcon.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._temp = map['temp'];
    this._total = map['total'];
    this._mask = map['mask'];
    this._sound = map['sound'];
  }

  // getter
  int get id1 => _id;
  String get temp1 => _temp;
  String get total1 => _total;
  String get mask1 => _mask;
  String get sound1 => _sound;
  String get jsonString {
    return '{"suhu":"$temp1","orang":"$total1","mask":"$mask1","sound":"$sound1"}';
  }

  // setter
  set temp(String value) {
    _temp = value;
  }

  set total(String value) {
    _total = value;
  }

  set mask(String value) {
    _mask = value;
  }

  set sound(String value) {
    _sound = value;
  }

  // konversi dari Contact ke Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id'] = this._id;
    map['temp'] = temp1;
    map['total'] = total1;
    map['mask'] = mask1;
    map['sound'] = sound1;
    return map;
  }
}
