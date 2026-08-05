// /// message : "User deactivated successfully"
//
// class DeleteUserModel {
//   DeleteUserModel({
//       String? message,}){
//     _message = message;
// }
//
//   DeleteUserModel.fromJson(dynamic json) {
//     _message = json['message'];
//   }
//   String? _message;
// DeleteUserModel copyWith({  String? message,
// }) => DeleteUserModel(  message: message ?? _message,
// );
//   String? get message => _message;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['message'] = _message;
//     return map;
//   }
//
// }