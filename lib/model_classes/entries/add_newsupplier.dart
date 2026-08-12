class AddNewSupplier {
  AddNewSupplier({  String? message,
      String? supplierName, 
      String? email, 
      String? referenceBy, 
      String? supplierGroup, 
      String? supplierGstNo, 
      String? supplierMsme, 
      String? commissionScheme, 
      num? commissionRate, 
      String? addressLine1, 
      String? addressLine2, 
      String? state, 
      String? city, 
      String? pinCode, 
      String? bankName, 
      String? ifscCode, 
      String? branchName, 
      String? accountName, 
      String? accountNumber, 
      List<num>? preferredTransportIds, 
      String? remark, 
      List<Contacts>? contacts,}){
    _supplierName = supplierName;
    _email = email;
     _message = message;
    _referenceBy = referenceBy;
    _supplierGroup = supplierGroup;
    _supplierGstNo = supplierGstNo;
    _supplierMsme = supplierMsme;
    _commissionScheme = commissionScheme;
    _commissionRate = commissionRate;
    _addressLine1 = addressLine1;
    _addressLine2 = addressLine2;
    _state = state;
    _city = city;
    _pinCode = pinCode;
    _bankName = bankName;
    _ifscCode = ifscCode;
    _branchName = branchName;
    _accountName = accountName;
    _accountNumber = accountNumber;
    _preferredTransportIds = preferredTransportIds;
    _remark = remark;
    _contacts = contacts;
}

  AddNewSupplier.fromJson(dynamic json) {
    _supplierName = json['supplierName'];
    _email = json['email'];
    _message = json['message'];
    _referenceBy = json['referenceBy'];
    _supplierGroup = json['supplierGroup'];
    _supplierGstNo = json['supplierGstNo'];
    _supplierMsme = json['supplierMsme'];
    _commissionScheme = json['commissionScheme'];
    _commissionRate = json['commissionRate'];
    _addressLine1 = json['addressLine1'];
    _addressLine2 = json['addressLine2'];
    _state = json['state'];
    _city = json['city'];
    _pinCode = json['pinCode'];
    _bankName = json['bankName'];
    _ifscCode = json['ifscCode'];
    _branchName = json['branchName'];
    _accountName = json['accountName'];
    _accountNumber = json['accountNumber'];
    _preferredTransportIds = json['preferredTransportIds'] != null ? json['preferredTransportIds'].cast<num>() : [];
    _remark = json['remark'];
    if (json['contacts'] != null) {
      _contacts = [];
      json['contacts'].forEach((v) {
        _contacts?.add(Contacts.fromJson(v));
      });
    }
  }
  String? _supplierName;
  String? _email;
  String? _referenceBy;
  String? _supplierGroup;
  String? _supplierGstNo;
  String? _supplierMsme;
  String? _commissionScheme;
  num? _commissionRate;
  String? _addressLine1;
  String? _addressLine2;
  String? _state;
  String? _city;
  String? _pinCode;
  String? _bankName;
  String? _message;
  String? _ifscCode;
  String? _branchName;
  String? _accountName;
  String? _accountNumber;
  List<num>? _preferredTransportIds;
  String? _remark;
  List<Contacts>? _contacts;
AddNewSupplier copyWith({  String? supplierName,
  String? email,
  String?message,
  String? referenceBy,
  String? supplierGroup,
  String? supplierGstNo,
  String? supplierMsme,
  String? commissionScheme,
  num? commissionRate,
  String? addressLine1,
  String? addressLine2,
  String? state,
  String? city,
  String? pinCode,
  String? bankName,
  String? ifscCode,
  String? branchName,
  String? accountName,
  String? accountNumber,
  List<num>? preferredTransportIds,
  String? remark,
  List<Contacts>? contacts,
}) => AddNewSupplier(  supplierName: supplierName ?? _supplierName,
  email: email ?? _email,
  referenceBy: referenceBy ?? _referenceBy,
  supplierGroup: supplierGroup ?? _supplierGroup,
  supplierGstNo: supplierGstNo ?? _supplierGstNo,
  supplierMsme: supplierMsme ?? _supplierMsme,
  commissionScheme: commissionScheme ?? _commissionScheme,
  commissionRate: commissionRate ?? _commissionRate,
  addressLine1: addressLine1 ?? _addressLine1,
  addressLine2: addressLine2 ?? _addressLine2,
  state: state ?? _state,
  city: city ?? _city,
  pinCode: pinCode ?? _pinCode,
  bankName: bankName ?? _bankName,
  ifscCode: ifscCode ?? _ifscCode,
  branchName: branchName ?? _branchName,
  accountName: accountName ?? _accountName,
  accountNumber: accountNumber ?? _accountNumber,
  preferredTransportIds: preferredTransportIds ?? _preferredTransportIds,
  remark: remark ?? _remark,
  contacts: contacts ?? _contacts,
);
  String? get supplierName => _supplierName;
  String? get email => _email;
  String? get message => _message;
  String? get referenceBy => _referenceBy;
  String? get supplierGroup => _supplierGroup;
  String? get supplierGstNo => _supplierGstNo;
  String? get supplierMsme => _supplierMsme;
  String? get commissionScheme => _commissionScheme;
  num? get commissionRate => _commissionRate;
  String? get addressLine1 => _addressLine1;
  String? get addressLine2 => _addressLine2;
  String? get state => _state;
  String? get city => _city;
  String? get pinCode => _pinCode;
  String? get bankName => _bankName;
  String? get ifscCode => _ifscCode;
  String? get branchName => _branchName;
  String? get accountName => _accountName;
  String? get accountNumber => _accountNumber;
  List<num>? get preferredTransportIds => _preferredTransportIds;
  String? get remark => _remark;
  List<Contacts>? get contacts => _contacts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['supplierName'] = _supplierName;
    map['email'] = _email;
    map['message'] = _message;
    map['referenceBy'] = _referenceBy;
    map['supplierGroup'] = _supplierGroup;
    map['supplierGstNo'] = _supplierGstNo;
    map['supplierMsme'] = _supplierMsme;
    map['commissionScheme'] = _commissionScheme;
    map['commissionRate'] = _commissionRate;
    map['addressLine1'] = _addressLine1;
    map['addressLine2'] = _addressLine2;
    map['state'] = _state;
    map['city'] = _city;
    map['pinCode'] = _pinCode;
    map['bankName'] = _bankName;
    map['ifscCode'] = _ifscCode;
    map['branchName'] = _branchName;
    map['accountName'] = _accountName;
    map['accountNumber'] = _accountNumber;
    map['preferredTransportIds'] = _preferredTransportIds;
    map['remark'] = _remark;
    if (_contacts != null) {
      map['contacts'] = _contacts?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Contacts {
  Contacts({
      String? name, 
      String? mobile, 
      String? designation,}){
    _name = name;
    _mobile = mobile;
    _designation = designation;
}

  Contacts.fromJson(dynamic json) {
    _name = json['name'];
    _mobile = json['mobile'];
    _designation = json['designation'];
  }
  String? _name;
  String? _mobile;
  String? _designation;
Contacts copyWith({  String? name,
  String? mobile,
  String? designation,
}) => Contacts(  name: name ?? _name,
  mobile: mobile ?? _mobile,
  designation: designation ?? _designation,
);
  String? get name => _name;
  String? get mobile => _mobile;
  String? get designation => _designation;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    map['mobile'] = _mobile;
    map['designation'] = _designation;
    return map;
  }

}