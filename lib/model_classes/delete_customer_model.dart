/// message : "Customer with code: C001980 successfully deleted"

class DeleteCustomerModel {
  DeleteCustomerModel({
      String? message,}){
    _message = message;
}

  DeleteCustomerModel.fromJson(dynamic json) {
    _message = json['message'];
  }
  String? _message;
DeleteCustomerModel copyWith({  String? message,
}) => DeleteCustomerModel(  message: message ?? _message,
);
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}