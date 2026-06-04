/// content : [{"staffId":26,"staffName":"wre","phone":"2323234232323","joiningDate":"2026-05-19"},{"staffId":24,"staffName":"Sachin","phone":"8435983800","joiningDate":"2026-03-07"},{"staffId":23,"staffName":"Karuna Nagar","phone":"8587962115","joiningDate":"2026-03-07"},{"staffId":22,"staffName":"Shivam","phone":"7566525262","joiningDate":"2026-03-07"},{"staffId":21,"staffName":"Vipin Kumar","phone":"9910330512","joiningDate":"2026-03-07"},{"staffId":20,"staffName":"Pradeep Goyal","phone":"9310988406","joiningDate":"2026-03-07"},{"staffId":19,"staffName":"Bablu","phone":"9315342007","joiningDate":"2026-03-07"},{"staffId":18,"staffName":"Surjeet Kumar Gupta","phone":"9958891943","joiningDate":"2026-03-07"},{"staffId":17,"staffName":"Mukesh","phone":"9643158600","joiningDate":"2026-03-07"},{"staffId":16,"staffName":"Khem Singh","phone":"9540159525","joiningDate":"2026-03-07"}]
/// page : 1
/// size : 10
/// totalElements : 18
/// totalPages : 2
/// last : false

class GetStaffDetailsModel {
  GetStaffDetailsModel({
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

  GetStaffDetailsModel.fromJson(dynamic json) {
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
GetStaffDetailsModel copyWith({  List<Content>? content,
  num? page,
  num? size,
  num? totalElements,
  num? totalPages,
  bool? last,
}) => GetStaffDetailsModel(  content: content ?? _content,
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

/// staffId : 26
/// staffName : "wre"
/// phone : "2323234232323"
/// joiningDate : "2026-05-19"

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