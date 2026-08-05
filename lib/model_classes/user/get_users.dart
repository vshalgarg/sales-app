// /// users : [{"id":1713,"username":"csmadmin1@gmail.com"},{"id":1722,"username":"aman"},{"id":1723,"username":"test007"}]
//
// class GetUsers {
//   GetUsers({
//       List<Users>? users,}){
//     _users = users;
// }
//
//   GetUsers.fromJson(dynamic json) {
//     if (json['users'] != null) {
//       _users = [];
//       json['users'].forEach((v) {
//         _users?.add(Users.fromJson(v));
//       });
//     }
//   }
//   List<Users>? _users;
// GetUsers copyWith({  List<Users>? users,
// }) => GetUsers(  users: users ?? _users,
// );
//   List<Users>? get users => _users;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     if (_users != null) {
//       map['users'] = _users?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
//
// }
//
// /// id : 1713
// /// username : "csmadmin1@gmail.com"
//
// class Users {
//   Users({
//       num? id,
//       String? username,}){
//     _id = id;
//     _username = username;
// }
//
//   Users.fromJson(dynamic json) {
//     _id = json['id'];
//     _username = json['username'];
//   }
//   num? _id;
//   String? _username;
// Users copyWith({  num? id,
//   String? username,
// }) => Users(  id: id ?? _id,
//   username: username ?? _username,
// );
//   num? get id => _id;
//   String? get username => _username;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = _id;
//     map['username'] = _username;
//     return map;
//   }
//
// }