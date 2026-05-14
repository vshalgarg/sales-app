class DeleteSupplierModel {
  String? code;
  String? message;

  DeleteSupplierModel({
    this.code,
    this.message,
  });
  factory DeleteSupplierModel.fromJson(Map<String, dynamic> json) {
    return DeleteSupplierModel(
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "code": code,
    };
  }
}