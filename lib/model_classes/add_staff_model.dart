/// message : "Staff added successfully"

class AddStaffModel {
  AddStaffModel({
      String? message,}){
    _message = message;
}

  AddStaffModel.fromJson(dynamic json) {
    _message = json['message'];
  }
  String? _message;
AddStaffModel copyWith({  String? message,
}) => AddStaffModel(  message: message ?? _message,
);
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}