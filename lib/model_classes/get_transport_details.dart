/// content : [{"id":256,"name":"DEEP PARCEL SERVICE","email":null,"gstNo":null,"state":"Delhi","city":"DELHI","addressLine1":"315 , KUCHA GHASIRAM, CHANDNI CHOWK,DELHI - 110006, DELHI, 110006","addressLine2":null,"status":"ACTIVE","contacts":[{"contactPerson":"Ggggggg","contactNumber":"9643889191","type":null},{"contactPerson":null,"contactNumber":"9350999265","type":null}]},{"id":255,"name":"OM SHANTI TRANSPORT COMPANY","email":null,"gstNo":null,"state":"Delhi","city":"Delhi","addressLine1":"HEAD OFFICE : CB-383/2 INDRA MARKET RING ROAD NARAINA NEW DELHI - 110028","addressLine2":null,"status":"ACTIVE","contacts":[{"contactPerson":"JAMNA LAL","contactNumber":"9213565598","type":null},{"contactPerson":"JAMNA LAL","contactNumber":"8800231148","type":null}]},{"id":254,"name":"ASHOK TRAVELS","email":null,"gstNo":"23AALPD6365Q2Z7","state":"Delhi","city":"Delhi","addressLine1":"SHOP NO - 36 TEES HAZARI COURT OPP. GATE NO - 5 GOKHALE MARKET DELHI - 110054","addressLine2":"GANDHI NAGAR - 1/45 MAIN PUSHTA ROAD NEAR SAI MANDIR DELHI ","status":"ACTIVE","contacts":[{"contactPerson":"ASHOK TRAVELS ","contactNumber":"9319861593","type":null},{"contactPerson":"ASHOK TRAVELS ","contactNumber":"7303904799","type":null},{"contactPerson":"ASHOK TRAVELS ","contactNumber":"01145518999","type":null}]},{"id":253,"name":"SHRINATH CARGO P LTD","email":null,"gstNo":"24AAHCS9767N1ZG","state":"Delhi","city":"Delhi","addressLine1":"26 FATEHPURI OLD PUNJAB STAND DELHI ","addressLine2":"BIKANER KI KACHE KI TPT ","status":"ACTIVE","contacts":[{"contactPerson":"SHRINATH CARGO P LTD ","contactNumber":"9205583803","type":null},{"contactPerson":"SHRINATH CARGO P LTD ","contactNumber":"9871512134","type":null}]},{"id":252,"name":"SHREE SHYAM CARGO PVT LTD","email":null,"gstNo":null,"state":"Delhi","city":null,"addressLine1":" DELHI - 413 HAVELI HAIDAR COLLLE CHANDNI CHOWK DELHI - 06 ","addressLine2":"JAIPUR .: 151 DHOBIO KA MORE ADARSH NAGAR JAIPUR ","status":"ACTIVE","contacts":[{"contactPerson":"SHREE SHYAM CARGO PVT LTD ","contactNumber":"6287901643","type":null},{"contactPerson":"SHREE SHYAM CARGO PVT LTD ","contactNumber":"6287901642","type":null},{"contactPerson":"SHREE SHYAM CARGO PVT LTD ","contactNumber":"6287901640","type":null},{"contactPerson":"SHREE SHYAM CARGO PVT LTD ","contactNumber":"6287901638","type":null}]}]
/// page : 1
/// size : 5
/// totalElements : 252
/// totalPages : 51
/// last : false

class GetTransport {
  GetTransport({
      List<TransportContent>? content,
      num? page, 
      num? size, 
      num? totalElements, 
      num? totalPages, 
      bool? last,}){
    _content = content;
    _page = page;
    _size = size;
    _totalElements = totalElements;
    _totalPages = totalPages;
    _last = last;
}

  GetTransport.fromJson(dynamic json) {
    if (json['content'] != null) {
      _content = [];
      json['content'].forEach((v) {
        _content?.add(TransportContent.fromJson(v));
      });
    }
    _page = json['page'];
    _size = json['size'];
    _totalElements = json['totalElements'];
    _totalPages = json['totalPages'];
    _last = json['last'];
  }
  List<TransportContent>? _content;
  num? _page;
  num? _size;
  num? _totalElements;
  num? _totalPages;
  bool? _last;
GetTransport copyWith({  List<TransportContent>? content,
  num? page,
  num? size,
  num? totalElements,
  num? totalPages,
  bool? last,
}) => GetTransport(  content: content ?? _content,
  page: page ?? _page,
  size: size ?? _size,
  totalElements: totalElements ?? _totalElements,
  totalPages: totalPages ?? _totalPages,
  last: last ?? _last,
);
  List<TransportContent>? get content => _content;
  num? get page => _page;
  num? get size => _size;
  num? get totalElements => _totalElements;
  num? get totalPages => _totalPages;
  bool? get last => _last;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_content != null) {
      map['content'] = _content?.map((v) => v.toJson()).toList();
    }
    map['page'] = _page;
    map['size'] = _size;
    map['totalElements'] = _totalElements;
    map['totalPages'] = _totalPages;
    map['last'] = _last;
    return map;
  }

}

/// id : 256
/// name : "DEEP PARCEL SERVICE"
/// email : null
/// gstNo : null
/// state : "Delhi"
/// city : "DELHI"
/// addressLine1 : "315 , KUCHA GHASIRAM, CHANDNI CHOWK,DELHI - 110006, DELHI, 110006"
/// addressLine2 : null
/// status : "ACTIVE"
/// contacts : [{"contactPerson":"Ggggggg","contactNumber":"9643889191","type":null},{"contactPerson":null,"contactNumber":"9350999265","type":null}]

class TransportContent {
  TransportContent({
      num? id, 
      String? name, 
      dynamic email, 
      dynamic gstNo, 
      String? state, 
      String? city, 
      String? addressLine1, 
      dynamic addressLine2, 
      String? status, 
      List<TransportContacts>? contacts,}){
    _id = id;
    _name = name;
    _email = email;
    _gstNo = gstNo;
    _state = state;
    _city = city;
    _addressLine1 = addressLine1;
    _addressLine2 = addressLine2;
    _status = status;
    _contacts = contacts;
}

  TransportContent.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _email = json['email'];
    _gstNo = json['gstNo'];
    _state = json['state'];
    _city = json['city'];
    _addressLine1 = json['addressLine1'];
    _addressLine2 = json['addressLine2'];
    _status = json['status'];
    if (json['contacts'] != null) {
      _contacts = [];
      json['contacts'].forEach((v) {
        _contacts?.add(TransportContacts.fromJson(v));
      });
    }
  }
  num? _id;
  String? _name;
  dynamic _email;
  dynamic _gstNo;
  String? _state;
  String? _city;
  String? _addressLine1;
  dynamic _addressLine2;
  String? _status;
  List<TransportContacts>? _contacts;
TransportContent copyWith({  num? id,
  String? name,
  dynamic email,
  dynamic gstNo,
  String? state,
  String? city,
  String? addressLine1,
  dynamic addressLine2,
  String? status,
  List<TransportContacts>? contacts,
}) => TransportContent(  id: id ?? _id,
  name: name ?? _name,
  email: email ?? _email,
  gstNo: gstNo ?? _gstNo,
  state: state ?? _state,
  city: city ?? _city,
  addressLine1: addressLine1 ?? _addressLine1,
  addressLine2: addressLine2 ?? _addressLine2,
  status: status ?? _status,
  contacts: contacts ?? _contacts,
);
  num? get id => _id;
  String? get name => _name;
  dynamic get email => _email;
  dynamic get gstNo => _gstNo;
  String? get state => _state;
  String? get city => _city;
  String? get addressLine1 => _addressLine1;
  dynamic get addressLine2 => _addressLine2;
  String? get status => _status;
  List<TransportContacts>? get contacts => _contacts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['gstNo'] = _gstNo;
    map['state'] = _state;
    map['city'] = _city;
    map['addressLine1'] = _addressLine1;
    map['addressLine2'] = _addressLine2;
    map['status'] = _status;
    if (_contacts != null) {
      map['contacts'] = _contacts?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// contactPerson : "Ggggggg"
/// contactNumber : "9643889191"
/// type : null

class TransportContacts {
  TransportContacts({
      String? contactPerson, 
      String? contactNumber, 
      dynamic type,}){
    _contactPerson = contactPerson;
    _contactNumber = contactNumber;
    _type = type;
}

  TransportContacts.fromJson(dynamic json) {
    _contactPerson = json['contactPerson'];
    _contactNumber = json['contactNumber'];
    _type = json['type'];
  }
  String? _contactPerson;
  String? _contactNumber;
  dynamic _type;
TransportContacts copyWith({  String? contactPerson,
  String? contactNumber,
  dynamic type,
}) => TransportContacts(  contactPerson: contactPerson ?? _contactPerson,
  contactNumber: contactNumber ?? _contactNumber,
  type: type ?? _type,
);
  String? get contactPerson => _contactPerson;
  String? get contactNumber => _contactNumber;
  dynamic get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['contactPerson'] = _contactPerson;
    map['contactNumber'] = _contactNumber;
    map['type'] = _type;
    return map;
  }

}