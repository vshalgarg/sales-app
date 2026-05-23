/// success : true
/// message : "Customer fetched successfully"
/// data : {"id":2037,"code":"C001979","customerName":"test cust","email":"tets","groupName":"test cust","gstNo":"27ABCDE1234F2Z5","referencedBy":"27ABCDE1234F2Z5","addressLine1":"27ABCDE1234F2Z5","addressLine2":"27ABCDE1234F2Z5","state":"Andhra Pradesh","city":"hy12n","pinCode":"212166","msme":"SMALL","remark":"sddsds","status":"INACTIVE","bankName":"hdfc","ifsc":"HDFC79799","branch":null,"accountName":null,"accountNumber":null,"contacts":[{"contactPerson":"were","mobileNumber":"1212121212","type":null}],"preferredTransports":[{"id":248,"name":"GATI KINTETSU EXPRESS","gstNo":null,"contactNumber":null,"city":null,"address":null,"status":null},{"id":255,"name":"OM SHANTI TRANSPORT COMPANY","gstNo":null,"contactNumber":null,"city":null,"address":null,"status":null},{"id":253,"name":"SHRINATH CARGO P LTD","gstNo":null,"contactNumber":null,"city":null,"address":null,"status":null}]}
//GetCustomerByidModel
class GetCustomerByidModel {
  GetCustomerByidModel({
      bool? success,
      String? message,
      Data? data,}){
    _success = success;
    _message = message;
    _data = data;
}

  GetCustomerByidModel.fromJson(dynamic json) {
    _success = json['success'];
    _message = json['message'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? _success;
  String? _message;
  Data? _data;
GetCustomerByidModel copyWith({  bool? success,
  String? message,
  Data? data,
}) => GetCustomerByidModel(  success: success ?? _success,
  message: message ?? _message,
  data: data ?? _data,
);
  bool? get success => _success;
  String? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

/// id : 2037
/// code : "C001979"
/// customerName : "test cust"
/// email : "tets"
/// groupName : "test cust"
/// gstNo : "27ABCDE1234F2Z5"
/// referencedBy : "27ABCDE1234F2Z5"
/// addressLine1 : "27ABCDE1234F2Z5"
/// addressLine2 : "27ABCDE1234F2Z5"
/// state : "Andhra Pradesh"
/// city : "hy12n"
/// pinCode : "212166"
/// msme : "SMALL"
/// remark : "sddsds"
/// status : "INACTIVE"
/// bankName : "hdfc"
/// ifsc : "HDFC79799"
/// branch : null
/// accountName : null
/// accountNumber : null
/// contacts : [{"contactPerson":"were","mobileNumber":"1212121212","type":null}]
/// preferredTransports : [{"id":248,"name":"GATI KINTETSU EXPRESS","gstNo":null,"contactNumber":null,"city":null,"address":null,"status":null},{"id":255,"name":"OM SHANTI TRANSPORT COMPANY","gstNo":null,"contactNumber":null,"city":null,"address":null,"status":null},{"id":253,"name":"SHRINATH CARGO P LTD","gstNo":null,"contactNumber":null,"city":null,"address":null,"status":null}]

class Data {
  Data({
      num? id,
      String? code,
      String? customerName,
      String? email,
      String? groupName,
      String? gstNo,
      String? referencedBy,
      String? addressLine1,
      String? addressLine2,
      String? state,
      String? city,
      String? pinCode,
      String? msme,
      String? remark,
      String? status,
      String? bankName,
      String? ifsc,
      dynamic branch,
      dynamic accountName,
      dynamic accountNumber,
      List<Contacts>? contacts,
      List<PreferredTransports>? preferredTransports,}){
    _id = id;
    _code = code;
    _customerName = customerName;
    _email = email;
    _groupName = groupName;
    _gstNo = gstNo;
    _referencedBy = referencedBy;
    _addressLine1 = addressLine1;
    _addressLine2 = addressLine2;
    _state = state;
    _city = city;
    _pinCode = pinCode;
    _msme = msme;
    _remark = remark;
    _status = status;
    _bankName = bankName;
    _ifsc = ifsc;
    _branch = branch;
    _accountName = accountName;
    _accountNumber = accountNumber;
    _contacts = contacts;
    _preferredTransports = preferredTransports;
}

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _code = json['code'];
    _customerName = json['customerName'];
    _email = json['email'];
    _groupName = json['groupName'];
    _gstNo = json['gstNo'];
    _referencedBy = json['referencedBy'];
    _addressLine1 = json['addressLine1'];
    _addressLine2 = json['addressLine2'];
    _state = json['state'];
    _city = json['city'];
    _pinCode = json['pinCode'];
    _msme = json['msme'];
    _remark = json['remark'];
    _status = json['status'];
    _bankName = json['bankName'];
    _ifsc = json['ifsc'];
    _branch = json['branch'];
    _accountName = json['accountName'];
    _accountNumber = json['accountNumber'];
    if (json['contacts'] != null) {
      _contacts = [];
      json['contacts'].forEach((v) {
        _contacts?.add(Contacts.fromJson(v));
      });
    }
    if (json['preferredTransports'] != null) {
      _preferredTransports = [];
      json['preferredTransports'].forEach((v) {
        _preferredTransports?.add(PreferredTransports.fromJson(v));
      });
    }
  }
  num? _id;
  String? _code;
  String? _customerName;
  String? _email;
  String? _groupName;
  String? _gstNo;
  String? _referencedBy;
  String? _addressLine1;
  String? _addressLine2;
  String? _state;
  String? _city;
  String? _pinCode;
  String? _msme;
  String? _remark;
  String? _status;
  String? _bankName;
  String? _ifsc;
  dynamic _branch;
  dynamic _accountName;
  dynamic _accountNumber;
  List<Contacts>? _contacts;
  List<PreferredTransports>? _preferredTransports;
Data copyWith({  num? id,
  String? code,
  String? customerName,
  String? email,
  String? groupName,
  String? gstNo,
  String? referencedBy,
  String? addressLine1,
  String? addressLine2,
  String? state,
  String? city,
  String? pinCode,
  String? msme,
  String? remark,
  String? status,
  String? bankName,
  String? ifsc,
  dynamic branch,
  dynamic accountName,
  dynamic accountNumber,
  List<Contacts>? contacts,
  List<PreferredTransports>? preferredTransports,
}) => Data(  id: id ?? _id,
  code: code ?? _code,
  customerName: customerName ?? _customerName,
  email: email ?? _email,
  groupName: groupName ?? _groupName,
  gstNo: gstNo ?? _gstNo,
  referencedBy: referencedBy ?? _referencedBy,
  addressLine1: addressLine1 ?? _addressLine1,
  addressLine2: addressLine2 ?? _addressLine2,
  state: state ?? _state,
  city: city ?? _city,
  pinCode: pinCode ?? _pinCode,
  msme: msme ?? _msme,
  remark: remark ?? _remark,
  status: status ?? _status,
  bankName: bankName ?? _bankName,
  ifsc: ifsc ?? _ifsc,
  branch: branch ?? _branch,
  accountName: accountName ?? _accountName,
  accountNumber: accountNumber ?? _accountNumber,
  contacts: contacts ?? _contacts,
  preferredTransports: preferredTransports ?? _preferredTransports,
);
  num? get id => _id;
  String? get code => _code;
  String? get customerName => _customerName;
  String? get email => _email;
  String? get groupName => _groupName;
  String? get gstNo => _gstNo;
  String? get referencedBy => _referencedBy;
  String? get addressLine1 => _addressLine1;
  String? get addressLine2 => _addressLine2;
  String? get state => _state;
  String? get city => _city;
  String? get pinCode => _pinCode;
  String? get msme => _msme;
  String? get remark => _remark;
  String? get status => _status;
  String? get bankName => _bankName;
  String? get ifsc => _ifsc;
  dynamic get branch => _branch;
  dynamic get accountName => _accountName;
  dynamic get accountNumber => _accountNumber;
  List<Contacts>? get contacts => _contacts;
  List<PreferredTransports>? get preferredTransports => _preferredTransports;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['code'] = _code;
    map['customerName'] = _customerName;
    map['email'] = _email;
    map['groupName'] = _groupName;
    map['gstNo'] = _gstNo;
    map['referencedBy'] = _referencedBy;
    map['addressLine1'] = _addressLine1;
    map['addressLine2'] = _addressLine2;
    map['state'] = _state;
    map['city'] = _city;
    map['pinCode'] = _pinCode;
    map['msme'] = _msme;
    map['remark'] = _remark;
    map['status'] = _status;
    map['bankName'] = _bankName;
    map['ifsc'] = _ifsc;
    map['branch'] = _branch;
    map['accountName'] = _accountName;
    map['accountNumber'] = _accountNumber;
    if (_contacts != null) {
      map['contacts'] = _contacts?.map((v) => v.toJson()).toList();
    }
    if (_preferredTransports != null) {
      map['preferredTransports'] = _preferredTransports?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 248
/// name : "GATI KINTETSU EXPRESS"
/// gstNo : null
/// contactNumber : null
/// city : null
/// address : null
/// status : null

class PreferredTransports {
  PreferredTransports({
      num? id,
      String? name,
      dynamic gstNo,
      dynamic contactNumber,
      dynamic city,
      dynamic address,
      dynamic status,}){
    _id = id;
    _name = name;
    _gstNo = gstNo;
    _contactNumber = contactNumber;
    _city = city;
    _address = address;
    _status = status;
}

  PreferredTransports.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _gstNo = json['gstNo'];
    _contactNumber = json['contactNumber'];
    _city = json['city'];
    _address = json['address'];
    _status = json['status'];
  }
  num? _id;
  String? _name;
  dynamic _gstNo;
  dynamic _contactNumber;
  dynamic _city;
  dynamic _address;
  dynamic _status;
PreferredTransports copyWith({  num? id,
  String? name,
  dynamic gstNo,
  dynamic contactNumber,
  dynamic city,
  dynamic address,
  dynamic status,
}) => PreferredTransports(  id: id ?? _id,
  name: name ?? _name,
  gstNo: gstNo ?? _gstNo,
  contactNumber: contactNumber ?? _contactNumber,
  city: city ?? _city,
  address: address ?? _address,
  status: status ?? _status,
);
  num? get id => _id;
  String? get name => _name;
  dynamic get gstNo => _gstNo;
  dynamic get contactNumber => _contactNumber;
  dynamic get city => _city;
  dynamic get address => _address;
  dynamic get status => _status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['gstNo'] = _gstNo;
    map['contactNumber'] = _contactNumber;
    map['city'] = _city;
    map['address'] = _address;
    map['status'] = _status;
    return map;
  }

}

/// contactPerson : "were"
/// mobileNumber : "1212121212"
/// type : null

class Contacts {
  Contacts({
      String? contactPerson,
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
  String? _contactPerson;
  String? _mobileNumber;
  dynamic _type;
Contacts copyWith({  String? contactPerson,
  String? mobileNumber,
  dynamic type,
}) => Contacts(  contactPerson: contactPerson ?? _contactPerson,
  mobileNumber: mobileNumber ?? _mobileNumber,
  type: type ?? _type,
);
  String? get contactPerson => _contactPerson;
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