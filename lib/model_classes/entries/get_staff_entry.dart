class GetStaffEntry {
  GetStaffEntry({
      num? staffId, 
      String? staffName, 
      String? phone, 
      String? joiningDate,}){
    _staffId = staffId;
    _staffName = staffName;
    _phone = phone;
    _joiningDate = joiningDate;
}

  GetStaffEntry.fromJson(dynamic json) {
    _staffId = json['staffId'];
    _staffName = json['staffName'];
    _phone = json['phone'];
    _joiningDate = json['joiningDate'];
  }
  num? _staffId;
  String? _staffName;
  String? _phone;
  String? _joiningDate;
GetStaffEntry copyWith({  num? staffId,
  String? staffName,
  String? phone,
  String? joiningDate,
}) => GetStaffEntry(  staffId: staffId ?? _staffId,
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