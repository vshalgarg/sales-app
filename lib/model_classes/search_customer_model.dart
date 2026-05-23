/// content : [{"id":1108,"code":"C001050","customerName":"ARPAN FASHION","customerGstNo":"24AJFPG9389N1ZI","address":"101, COSY HILL APARTMENT, OPP. DOMINO'S PIZZA,, 10- PATEL COLONY, P.N. MARG, JAMNAGAR.","city":"JAMNAGAR","contacts":[{"contactPerson":null,"mobileNumber":"02882751999","type":null},{"contactPerson":null,"mobileNumber":"9427776555","type":null},{"contactPerson":"MAHIPAT SINGH GOHIL","mobileNumber":"9377795111","type":null}]},{"id":2040,"code":"C001982","customerName":"arpan katiyar kannoj","customerGstNo":null,"address":"","city":null,"contacts":[]},{"id":2042,"code":"C001984","customerName":"arpan katiyar98 kannoj","customerGstNo":null,"address":"","city":null,"contacts":[]}]
/// page : 1
/// size : 10
/// totalElements : 3
/// totalPages : 1
/// last : true

class SearchCustomerModel {
  SearchCustomerModel({
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

  SearchCustomerModel.fromJson(dynamic json) {
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
SearchCustomerModel copyWith({  List<Content>? content,
  num? page,
  num? size,
  num? totalElements,
  num? totalPages,
  bool? last,
}) => SearchCustomerModel(  content: content ?? _content,
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

/// id : 1108
/// code : "C001050"
/// customerName : "ARPAN FASHION"
/// customerGstNo : "24AJFPG9389N1ZI"
/// address : "101, COSY HILL APARTMENT, OPP. DOMINO'S PIZZA,, 10- PATEL COLONY, P.N. MARG, JAMNAGAR."
/// city : "JAMNAGAR"
/// contacts : [{"contactPerson":null,"mobileNumber":"02882751999","type":null},{"contactPerson":null,"mobileNumber":"9427776555","type":null},{"contactPerson":"MAHIPAT SINGH GOHIL","mobileNumber":"9377795111","type":null}]

class Content {
  Content({
      num? id, 
      String? code, 
      String? customerName, 
      String? customerGstNo, 
      String? address, 
      String? city, 
      List<Contacts>? contacts,}){
    _id = id;
    _code = code;
    _customerName = customerName;
    _customerGstNo = customerGstNo;
    _address = address;
    _city = city;
    _contacts = contacts;
}

  Content.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _customerName = json['customerName'];
    _customerGstNo = json['customerGstNo'];
    _address = json['address'];
    _city = json['city'];
    if (json['contacts'] != null) {
      _contacts = [];
      json['contacts'].forEach((v) {
        _contacts?.add(Contacts.fromJson(v));
      });
    }
  }
  num? _id;
  String? _code;
  String? _customerName;
  String? _customerGstNo;
  String? _address;
  String? _city;
  List<Contacts>? _contacts;
Content copyWith({  num? id,
  String? code,
  String? customerName,
  String? customerGstNo,
  String? address,
  String? city,
  List<Contacts>? contacts,
}) => Content(  id: id ?? _id,
  code: code ?? _code,
  customerName: customerName ?? _customerName,
  customerGstNo: customerGstNo ?? _customerGstNo,
  address: address ?? _address,
  city: city ?? _city,
  contacts: contacts ?? _contacts,
);
  num? get id => _id;
  String? get code => _code;
  String? get customerName => _customerName;
  String? get customerGstNo => _customerGstNo;
  String? get address => _address;
  String? get city => _city;
  List<Contacts>? get contacts => _contacts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['customerName'] = _customerName;
    map['customerGstNo'] = _customerGstNo;
    map['address'] = _address;
    map['city'] = _city;
    if (_contacts != null) {
      map['contacts'] = _contacts?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// contactPerson : null
/// mobileNumber : "02882751999"
/// type : null

class Contacts {
  Contacts({
      dynamic contactPerson, 
      String? mobileNumber, 
      dynamic type,}){
    _contactPerson = contactPerson;
    _mobileNumber = mobileNumber;
    _type = type;
}

  Contacts.fromJson(dynamic json) {
    _contactPerson = json['contactPerson'];
    _mobileNumber = json['mobileNumber'];
    _type = json['type'];
  }
  dynamic _contactPerson;
  String? _mobileNumber;
  dynamic _type;
Contacts copyWith({  dynamic contactPerson,
  String? mobileNumber,
  dynamic type,
}) => Contacts(  contactPerson: contactPerson ?? _contactPerson,
  mobileNumber: mobileNumber ?? _mobileNumber,
  type: type ?? _type,
);
  dynamic get contactPerson => _contactPerson;
  String? get mobileNumber => _mobileNumber;
  dynamic get type => _type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['contactPerson'] = _contactPerson;
    map['mobileNumber'] = _mobileNumber;
    map['type'] = _type;
    return map;
  }

}