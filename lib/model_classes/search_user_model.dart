/// id : 674
/// username : "tamanna@neepanlok.com"

class SearchUserModel {
  SearchUserModel({
    num? id,
    String? username,}){
    _id = id;
    _username = username;
  }

  SearchUserModel.fromJson(dynamic json) {
    _id = json['id'];
    _username = json['username'];
  }
  num? _id;
  String? _username;
  SearchUserModel copyWith({  num? id,
    String? username,
  }) => SearchUserModel(  id: id ?? _id,
    username: username ?? _username,
  );
  num? get id => _id;
  String? get username => _username;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['username'] = _username;
    return map;
  }

}