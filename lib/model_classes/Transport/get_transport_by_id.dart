// /// id : 255
// /// name : "OM SHANTI TRANSPORT COMPANY"
// /// email : null
// /// gstNo : null
// /// state : "Delhi"
// /// city : "Delhi"
// /// pinCode : "110028"
// /// addressLine1 : "HEAD OFFICE : CB-383/2 INDRA MARKET RING ROAD NARAINA NEW DELHI - 110028"
// /// addressLine2 : null
// /// status : "DELETE"
// /// contacts : [{"contactPerson":"JAMNA LAL","contactNumber":"8800231148","type":null},{"contactPerson":"JAMNA LAL","contactNumber":"9213565598","type":null}]
//
// class GetTransportById {
//   GetTransportById({
//       num? id,
//       String? name,
//       dynamic email,
//       dynamic gstNo,
//       String? state,
//       String? city,
//       String? pinCode,
//       String? addressLine1,
//       dynamic addressLine2,
//       String? status,
//       List<Contacts>? contacts,}){
//     _id = id;
//     _name = name;
//     _email = email;
//     _gstNo = gstNo;
//     _state = state;
//     _city = city;
//     _pinCode = pinCode;
//     _addressLine1 = addressLine1;
//     _addressLine2 = addressLine2;
//     _status = status;
//     _contacts = contacts;
// }
//
//   GetTransportById.fromJson(dynamic json) {
//     _id = json['id'];
//     _name = json['name'];
//     _email = json['email'];
//     _gstNo = json['gstNo'];
//     _state = json['state'];
//     _city = json['city'];
//     _pinCode = json['pinCode'];
//     _addressLine1 = json['addressLine1'];
//     _addressLine2 = json['addressLine2'];
//     _status = json['status'];
//     if (json['contacts'] != null) {
//       _contacts = [];
//       json['contacts'].forEach((v) {
//         _contacts?.add(Contacts.fromJson(v));
//       });
//     }
//   }
//   num? _id;
//   String? _name;
//   dynamic _email;
//   dynamic _gstNo;
//   String? _state;
//   String? _city;
//   String? _pinCode;
//   String? _addressLine1;
//   dynamic _addressLine2;
//   String? _status;
//   List<Contacts>? _contacts;
// GetTransportById copyWith({  num? id,
//   String? name,
//   dynamic email,
//   dynamic gstNo,
//   String? state,
//   String? city,
//   String? pinCode,
//   String? addressLine1,
//   dynamic addressLine2,
//   String? status,
//   List<Contacts>? contacts,
// }) => GetTransportById(  id: id ?? _id,
//   name: name ?? _name,
//   email: email ?? _email,
//   gstNo: gstNo ?? _gstNo,
//   state: state ?? _state,
//   city: city ?? _city,
//   pinCode: pinCode ?? _pinCode,
//   addressLine1: addressLine1 ?? _addressLine1,
//   addressLine2: addressLine2 ?? _addressLine2,
//   status: status ?? _status,
//   contacts: contacts ?? _contacts,
// );
//   num? get id => _id;
//   String? get name => _name;
//   dynamic get email => _email;
//   dynamic get gstNo => _gstNo;
//   String? get state => _state;
//   String? get city => _city;
//   String? get pinCode => _pinCode;
//   String? get addressLine1 => _addressLine1;
//   dynamic get addressLine2 => _addressLine2;
//   String? get status => _status;
//   List<Contacts>? get contacts => _contacts;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['name'] = _name;
//     map['email'] = _email;
//     map['gstNo'] = _gstNo;
//     map['state'] = _state;
//     map['city'] = _city;
//     map['pinCode'] = _pinCode;
//     map['addressLine1'] = _addressLine1;
//     map['addressLine2'] = _addressLine2;
//     map['status'] = _status;
//     if (_contacts != null) {
//       map['contacts'] = _contacts?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
//
// }
//
// /// contactPerson : "JAMNA LAL"
// /// contactNumber : "8800231148"
// /// type : null
//
// class Contacts {
//   Contacts({
//       String? contactPerson,
//       String? contactNumber,
//       dynamic type,}){
//     _contactPerson = contactPerson;
//     _contactNumber = contactNumber;
//     _type = type;
// }
//
//   Contacts.fromJson(dynamic json) {
//     _contactPerson = json['contactPerson'];
//     _contactNumber = json['contactNumber'];
//     _type = json['type'];
//   }
//   String? _contactPerson;
//   String? _contactNumber;
//   dynamic _type;
// Contacts copyWith({  String? contactPerson,
//   String? contactNumber,
//   dynamic type,
// }) => Contacts(  contactPerson: contactPerson ?? _contactPerson,
//   contactNumber: contactNumber ?? _contactNumber,
//   type: type ?? _type,
// );
//   String? get contactPerson => _contactPerson;
//   String? get contactNumber => _contactNumber;
//   dynamic get type => _type;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['contactPerson'] = _contactPerson;
//     map['contactNumber'] = _contactNumber;
//     map['type'] = _type;
//     return map;
//   }
//
// }