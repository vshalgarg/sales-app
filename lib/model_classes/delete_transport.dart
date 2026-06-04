/// message : "Transport marked as deleted"
/// success : true

class DeleteTransport {
  DeleteTransport({
      String? message, 
      bool? success,}){
    _message = message;
    _success = success;
}

  DeleteTransport.fromJson(dynamic json) {
    _message = json['message'];
    _success = json['success'];
  }
  String? _message;
  bool? _success;
DeleteTransport copyWith({  String? message,
  bool? success,
}) => DeleteTransport(  message: message ?? _message,
  success: success ?? _success,
);
  String? get message => _message;
  bool? get success => _success;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['success'] = _success;
    return map;
  }

}