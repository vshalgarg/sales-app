// /// status : "ACTIVE"
//
// class AddNewuserModel {
//   AddNewuserModel({
//       String? status,}){
//     _status = status;
// }
//
//   AddNewuserModel.fromJson(dynamic json) {
//     _status = json['status'];
//   }
//   String? _status;
// AddNewuserModel copyWith({  String? status,
// }) => AddNewuserModel(  status: status ?? _status,
// );
//   String? get status => _status;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['status'] = _status;
//     return map;
//   }
//
// }