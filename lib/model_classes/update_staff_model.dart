/// message : "Staff updated successfully"

class UpdateStaffModel {
  UpdateStaffModel({
      String? message,}){
    _message = message;
}

  UpdateStaffModel.fromJson(dynamic json) {
    _message = json['message'];
  }
  String? _message;
UpdateStaffModel copyWith({  String? message,
}) => UpdateStaffModel(  message: message ?? _message,
);
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}