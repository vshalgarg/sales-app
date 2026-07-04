import 'dart:convert';

/// content : [{"id":1636,"code":"S001626","supplierName":"QSSD","supplierGstNo":null,"address":"","city":null,"mobile":"98888888888"},{"id":1635,"code":"S001625","supplierName":"tarun Traders","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1634,"code":"S001624","supplierName":"ABCd Traders","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1633,"code":"S001623","supplierName":"ABCd Traders","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1632,"code":"S001622","supplierName":"ABCd Traders","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1631,"code":"S001621","supplierName":"ABCd Traders","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1630,"code":"S001620","supplierName":"ABCd Traders","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1629,"code":"S001619","supplierName":"Owais Welders Pvt. Ltd.","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1628,"code":"S001618","supplierName":"ABCd Traders","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1627,"code":"S001617","supplierName":"test search","supplierGstNo":null,"address":"","city":null,"mobile":"995306061234453"}]
/// page : 1
/// size : 10
/// totalElements : 1593
/// totalPages : 160
/// last : false

class GetSupplier {
  GetSupplier({
      List<Content>? content, 
      num? page, 
      num? size, 
      num? totalElements, 
      num? totalPages, 
      bool? last,}) {
    _content = content;
    _page = page;
    _size = size;
    _totalElements = totalElements;
    _totalPages = totalPages;
    _last = last;
  }

  GetSupplier.fromJson(dynamic json) {
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
GetSupplier copyWith({  List<Content>? content,
  num? page,
  num? size,
  num? totalElements,
  num? totalPages,
  bool? last,
}) => GetSupplier(  content: content ?? _content,
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

/// id : 1636
/// code : "S001626"
/// supplierName : "QSSD"
/// supplierGstNo : null
/// address : ""
/// city : null
/// mobile : "98888888888"

class Content {
  Content({
      num? id, 
      String? code, 
      String? supplierName, 
      dynamic supplierGstNo, 
      String? address, 
      dynamic city, 
      String? mobile,}){
    _id = id;
    _code = code;
    _supplierName = supplierName;
    _supplierGstNo = supplierGstNo;
    _address = address;
    _city = city;
    _mobile = mobile;
}

  Content.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _supplierName = json['supplierName'];
    _supplierGstNo = json['supplierGstNo'];
    _address = json['address'];
    _city = json['city'];
    _mobile = json['mobile'];
  }
  num? _id;
  String? _code;
  String? _supplierName;
  dynamic _supplierGstNo;
  String? _address;
  dynamic _city;
  String? _mobile;
Content copyWith({  num? id,
  String? code,
  String? supplierName,
  dynamic supplierGstNo,
  String? address,
  dynamic city,
  String? mobile,
}) => Content(  id: id ?? _id,
  code: code ?? _code,
  supplierName: supplierName ?? _supplierName,
  supplierGstNo: supplierGstNo ?? _supplierGstNo,
  address: address ?? _address,
  city: city ?? _city,
  mobile: mobile ?? _mobile,
);
  num? get id => _id;
  String? get code => _code;
  String? get supplierName => _supplierName;
  dynamic get supplierGstNo => _supplierGstNo;
  String? get address => _address;
  dynamic get city => _city;
  String? get mobile => _mobile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['supplierName'] = _supplierName;
    map['supplierGstNo'] = _supplierGstNo;
    map['address'] = _address;
    map['city'] = _city;
    map['mobile'] = _mobile;
    return map;
  }

}