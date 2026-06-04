/// content : [{"staffId":9,"staffName":"Aman Shukla","phone":"9910756557","joiningDate":"2007-08-05"}]
/// page : 1
/// size : 10
/// totalElements : 1
/// totalPages : 1
/// last : true

class SearchStaffModel {
  SearchStaffModel({
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

  SearchStaffModel.fromJson(dynamic json) {
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
SearchStaffModel copyWith({  List<Content>? content,
  num? page,
  num? size,
  num? totalElements,
  num? totalPages,
  bool? last,
}) => SearchStaffModel(  content: content ?? _content,
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

/// staffId : 9
/// staffName : "Aman Shukla"
/// phone : "9910756557"
/// joiningDate : "2007-08-05"

class Content {
  Content({
      num? staffId, 
      String? staffName, 
      String? phone, 
      String? joiningDate,}){
    _staffId = staffId;
    _staffName = staffName;
    _phone = phone;
    _joiningDate = joiningDate;
}

  Content.fromJson(dynamic json) {
    _staffId = json['staffId'];
    _staffName = json['staffName'];
    _phone = json['phone'];
    _joiningDate = json['joiningDate'];
  }
  num? _staffId;
  String? _staffName;
  String? _phone;
  String? _joiningDate;
Content copyWith({  num? staffId,
  String? staffName,
  String? phone,
  String? joiningDate,
}) => Content(  staffId: staffId ?? _staffId,
  staffName: staffName ?? _staffName,
  phone: phone ?? _phone,
  joiningDate: joiningDate ?? _joiningDate,
);
  num? get staffId => _staffId;
  String? get staffName => _staffName;
  String? get phone => _phone;
  String? get joiningDate => _joiningDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['staffId'] = _staffId;
    map['staffName'] = _staffName;
    map['phone'] = _phone;
    map['joiningDate'] = _joiningDate;
    return map;
  }

}