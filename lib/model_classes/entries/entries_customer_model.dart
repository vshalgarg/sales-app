/// id : 2033
/// customerName : "ABCD Traders Update checking"
/// customerGroup : "ABCD Traders Update"
/// customerGstNo : null
/// customerMsme : "Small"
/// city : null

class EntriesCustomerModel {
  EntriesCustomerModel({
      num? id, 
      String? customerName, 
      String? customerGroup, 
      dynamic customerGstNo, 
      String? customerMsme, 
      dynamic city,}){
    _id = id;
    _customerName = customerName;
    _customerGroup = customerGroup;
    _customerGstNo = customerGstNo;
    _customerMsme = customerMsme;
    _city = city;
}

  EntriesCustomerModel.fromJson(dynamic json) {
    _id = json['id'];
    _customerName = json['customerName'];
    _customerGroup = json['customerGroup'];
    _customerGstNo = json['customerGstNo'];
    _customerMsme = json['customerMsme'];
    _city = json['city'];
  }
  num? _id;
  String? _customerName;
  String? _customerGroup;
  dynamic _customerGstNo;
  String? _customerMsme;
  dynamic _city;
EntriesCustomerModel copyWith({  num? id,
  String? customerName,
  String? customerGroup,
  dynamic customerGstNo,
  String? customerMsme,
  dynamic city,
}) => EntriesCustomerModel(  id: id ?? _id,
  customerName: customerName ?? _customerName,
  customerGroup: customerGroup ?? _customerGroup,
  customerGstNo: customerGstNo ?? _customerGstNo,
  customerMsme: customerMsme ?? _customerMsme,
  city: city ?? _city,
);
  num? get id => _id;
  String? get customerName => _customerName;
  String? get customerGroup => _customerGroup;
  dynamic get customerGstNo => _customerGstNo;
  String? get customerMsme => _customerMsme;
  dynamic get city => _city;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['customerName'] = _customerName;
    map['customerGroup'] = _customerGroup;
    map['customerGstNo'] = _customerGstNo;
    map['customerMsme'] = _customerMsme;
    map['city'] = _city;
    return map;
  }

}