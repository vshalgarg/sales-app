/// message : "Staff ID: 26 became INACTIVE"

class DeleteStaff {
  DeleteStaff({
      String? message,}){
    _message = message;
}

  DeleteStaff.fromJson(dynamic json) {
    _message = json['message'];
  }
  String? _message;
DeleteStaff copyWith({  String? message,
}) => DeleteStaff(  message: message ?? _message,
);
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}