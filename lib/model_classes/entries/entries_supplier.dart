/// id : 1585
/// supplierName : "(AMRITAS) ATEX TEXTILE (P) LTD."
/// supplierGroup : "(AMRITAS) ATEX TEXTILE (P) LTD."
/// supplierGstNo : "07AAJCA1036A1ZD"
/// supplierMsme : "SMALL"
/// city : "DELHI"

class EntriesModel {
  EntriesModel({
      num? id, 
      String? supplierName, 
      String? supplierGroup, 
      String? supplierGstNo, 
      String? supplierMsme, 
      String? city,}){
    _id = id;
    _supplierName = supplierName;
    _supplierGroup = supplierGroup;
    _supplierGstNo = supplierGstNo;
    _supplierMsme = supplierMsme;
    _city = city;
}

  EntriesModel.fromJson(dynamic json) {
    _id = json['id'];
    _supplierName = json['supplierName'];
    _supplierGroup = json['supplierGroup'];
    _supplierGstNo = json['supplierGstNo'];
    _supplierMsme = json['supplierMsme'];
    _city = json['city'];
  }
  num? _id;
  String? _supplierName;
  String? _supplierGroup;
  String? _supplierGstNo;
  String? _supplierMsme;
  String? _city;
EntriesModel copyWith({  num? id,
  String? supplierName,
  String? supplierGroup,
  String? supplierGstNo,
  String? supplierMsme,
  String? city,
}) => EntriesModel(  id: id ?? _id,
  supplierName: supplierName ?? _supplierName,
  supplierGroup: supplierGroup ?? _supplierGroup,
  supplierGstNo: supplierGstNo ?? _supplierGstNo,
  supplierMsme: supplierMsme ?? _supplierMsme,
  city: city ?? _city,
);
  num? get id => _id;
  String? get supplierName => _supplierName;
  String? get supplierGroup => _supplierGroup;
  String? get supplierGstNo => _supplierGstNo;
  String? get supplierMsme => _supplierMsme;
  String? get city => _city;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['supplierName'] = _supplierName;
    map['supplierGroup'] = _supplierGroup;
    map['supplierGstNo'] = _supplierGstNo;
    map['supplierMsme'] = _supplierMsme;
    map['city'] = _city;
    return map;
  }

}