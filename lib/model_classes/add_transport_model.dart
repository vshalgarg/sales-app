/// success : true
/// message : "Transport added successfully"
/// id : 259

class AddTransportModel {
  AddTransportModel({
      bool? success, 
      String? message, 
      num? id,}){
    _success = success;
    _message = message;
    _id = id;
}

  AddTransportModel.fromJson(dynamic json) {
    _success = json['success'];
    _message = json['message'];
    _id = json['id'];
  }
  bool? _success;
  String? _message;
  num? _id;
AddTransportModel copyWith({  bool? success,
  String? message,
  num? id,
}) => AddTransportModel(  success: success ?? _success,
  message: message ?? _message,
  id: id ?? _id,
);
  bool? get success => _success;
  String? get message => _message;
  num? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['message'] = _message;
    map['id'] = _id;
    return map;
  }

}