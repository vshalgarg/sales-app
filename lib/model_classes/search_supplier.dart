/// content : [{"id":1395,"code":"S001385","supplierName":"BHARAT MOTAR (FOR PANCHKULA)","supplierGstNo":null,"address":"NAYA BAZAR PILI KOTHI","city":null,"mobile":"23960157"},{"id":811,"code":"S000801","supplierName":"DEEP DESIGNERS (TARUN JI )","supplierGstNo":"07AJPPG9994B1ZQ,07AAOFD5772A1ZG","address":"IX/6433, MUKHERJEE GALI , GANDHI NAGAR, DELHI- 110031","city":"DELHI","mobile":"22077491"},{"id":1141,"code":"S001131","supplierName":"NAMTARA DESIGNER STUDIO","supplierGstNo":null,"address":"3RD FLOOR BLOCK C 177 , MANSI RAM GUPTA MARG NARAINA INDUSTRIAL AREA PHASE -1 NEW DELHI","city":"NEW DELHI","mobile":"9220963955"},{"id":1340,"code":"S001330","supplierName":"SUNIL TARANSPORT COMPANY","supplierGstNo":null,"address":"52 KHANNA MKT TIS HAZARI DELHI-54","city":"DELHI","mobile":"9350090240"},{"id":387,"code":"S000377","supplierName":"TARA SYNTEX PVT. LTD.","supplierGstNo":null,"address":"831-832, MAIN ROAD CHANDNI CHOWK NEAR KATRA DELHI-6","city":"Delhi","mobile":"9873096369"},{"id":1639,"code":"S001629","supplierName":"tarun","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1661,"code":"S001651","supplierName":"tarun","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":270,"code":"S000260","supplierName":"TARUN & COM.","supplierGstNo":null,"address":"5523, MOTI KATRA NAI SARAK CHANDINI CHOWK DELHI-6","city":"Delhi","mobile":"9810159540"},{"id":1650,"code":"S001640","supplierName":"tarun bbbb","supplierGstNo":null,"address":"","city":null,"mobile":null},{"id":1635,"code":"S001625","supplierName":"tarun Traders","supplierGstNo":null,"address":"","city":null,"mobile":null}]
/// page : 1
/// size : 10
/// totalElements : 12
/// totalPages : 2
/// last : false

class SearchSupplier {
  SearchSupplier({
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

  SearchSupplier.fromJson(dynamic json) {
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
SearchSupplier copyWith({  List<Content>? content,
  num? page,
  num? size,
  num? totalElements,
  num? totalPages,
  bool? last,
}) => SearchSupplier(  content: content ?? _content,
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

/// id : 1395
/// code : "S001385"
/// supplierName : "BHARAT MOTAR (FOR PANCHKULA)"
/// supplierGstNo : null
/// address : "NAYA BAZAR PILI KOTHI"
/// city : null
/// mobile : "23960157"

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