/// content : [{"id":93,"name":"BHARAT MOTAR (FOR PANCHKULA)","email":null,"gstNo":null,"state":"Delhi","city":"DELHI","addressLine1":"NAYA BAZAR PILI KOTHI","addressLine2":null,"status":"ACTIVE","contacts":[{"contactPerson":"BHARAT MOTAR (FOR PANCHKULA)","contactNumber":"23960157","type":null}]},{"id":88,"name":"MAURANIPUR TPT TO SHAHDOL / CHHATTARPUR","email":null,"gstNo":"07AAXPN0632L1Z8","state":"Delhi","city":"DELHI","addressLine1":"86, NEW KUTAB ROAD, SADAR BAZAR, DELHI- 110006","addressLine2":null,"status":"ACTIVE","contacts":[{"contactPerson":"MAURANIPUR TPT TO SHAHDOL / CHHATTARPUR","contactNumber":"9350611682","type":null},{"contactPerson":"MAURANIPUR TPT TO SHAHDOL / CHHATTARPUR","contactNumber":"9350011182","type":null},{"contactPerson":"ENQUIRY","contactNumber":"9311987427","type":null},{"contactPerson":"ENQUIRY","contactNumber":"9311970569","type":null}]},{"id":64,"name":"SUNIL TARANSPORT COMPANY","email":null,"gstNo":null,"state":"Delhi","city":"DELHI-54 ","addressLine1":"52 KHANNA MKT TIS HAZARI DELHI-54 ","addressLine2":null,"status":"ACTIVE","contacts":[{"contactPerson":"SUNIL TARANSPORT COMPANY","contactNumber":"9350090240","type":null},{"contactPerson":"SUNIL TARANSPORT COMPANY","contactNumber":"23911415","type":null}]},{"id":260,"name":"tarun foogat","email":"hjsxhjvgx@gmail","gstNo":"acjhbcjhvbc","state":null,"city":null,"addressLine1":null,"addressLine2":null,"status":"ACTIVE","contacts":[{"contactPerson":null,"contactNumber":null,"type":null}]}]
/// page : 1
/// size : 10
/// totalElements : 4
/// totalPages : 1
/// last : true

class SearchTransportModel {
  SearchTransportModel({
      List<Content>? content, 
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

  SearchTransportModel.fromJson(dynamic json) {
    if (json['content'] != null) {
      _content = [];
      json['content'].forEach((v) {
        _content?.add(Content.fromJson(v));
      });
    }
    _page = json['page'];
    _size = json['size'];
    _totalElements = json['totalElements'];
    _totalPages = json['totalPages'];
    _last = json['last'];
  }
  List<Content>? _content;
  num? _page;
  num? _size;
  num? _totalElements;
  num? _totalPages;
  bool? _last;
SearchTransportModel copyWith({  List<Content>? content,
  num? page,
  num? size,
  num? totalElements,
  num? totalPages,
  bool? last,
}) => SearchTransportModel(  content: content ?? _content,
  page: page ?? _page,
  size: size ?? _size,
  totalElements: totalElements ?? _totalElements,
  totalPages: totalPages ?? _totalPages,
  last: last ?? _last,
);
  List<Content>? get content => _content;
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

/// id : 93
/// name : "BHARAT MOTAR (FOR PANCHKULA)"
/// email : null
/// gstNo : null
/// state : "Delhi"
/// city : "DELHI"
/// addressLine1 : "NAYA BAZAR PILI KOTHI"
/// addressLine2 : null
/// status : "ACTIVE"
/// contacts : [{"contactPerson":"BHARAT MOTAR (FOR PANCHKULA)","contactNumber":"23960157","type":null}]

class Content {
  Content({
      num? id, 
      String? name, 
      dynamic email, 
      dynamic gstNo, 
      String? state, 
      String? city, 
      String? addressLine1, 
      dynamic addressLine2, 
      String? status, 
      List<Contacts>? contacts,}){
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

  Content.fromJson(dynamic json) {
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
        _contacts?.add(Contacts.fromJson(v));
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
  List<Contacts>? _contacts;
Content copyWith({  num? id,
  String? name,
  dynamic email,
  dynamic gstNo,
  String? state,
  String? city,
  String? addressLine1,
  dynamic addressLine2,
  String? status,
  List<Contacts>? contacts,
}) => Content(  id: id ?? _id,
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
  List<Contacts>? get contacts => _contacts;

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

/// contactPerson : "BHARAT MOTAR (FOR PANCHKULA)"
/// contactNumber : "23960157"
/// type : null

class Contacts {
  Contacts({
      String? contactPerson, 
      String? contactNumber, 
      dynamic type,}){
    _contactPerson = contactPerson;
    _contactNumber = contactNumber;
    _type = type;
}

  Contacts.fromJson(dynamic json) {
    _contactPerson = json['contactPerson'];
    _contactNumber = json['contactNumber'];
    _type = json['type'];
  }
  String? _contactPerson;
  String? _contactNumber;
  dynamic _type;
Contacts copyWith({  String? contactPerson,
  String? contactNumber,
  dynamic type,
}) => Contacts(  contactPerson: contactPerson ?? _contactPerson,
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