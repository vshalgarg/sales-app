/// message : "Customer added successfully"

class AddCustomer {
  AddCustomer({
      String? message,}){
    _message = message;
}

  AddCustomer.fromJson(dynamic json) {
    _message = json['message'];
  }
  String? _message;
AddCustomer copyWith({  String? message,
}) => AddCustomer(  message: message ?? _message,
);
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    return map;
  }

}