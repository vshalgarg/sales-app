/// userId : 1723
/// status : "SUCCESS"
/// message : "Password changed successfully."

class OnUpdatePassword {
  OnUpdatePassword({
      num? userId, 
      String? status, 
      String? message,}){
    _userId = userId;
    _status = status;
    _message = message;
}

  OnUpdatePassword.fromJson(dynamic json) {
    _userId = json['userId'];
    _status = json['status'];
    _message = json['message'];
  }
  num? _userId;
  String? _status;
  String? _message;
OnUpdatePassword copyWith({  num? userId,
  String? status,
  String? message,
}) => OnUpdatePassword(  userId: userId ?? _userId,
  status: status ?? _status,
  message: message ?? _message,
);
  num? get userId => _userId;
  String? get status => _status;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = _userId;
    map['status'] = _status;
    map['message'] = _message;
    return map;
  }

}