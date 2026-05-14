class GetSupplierByIdModel {
  bool? success;
  String? message;

  num? id;
  String? code;
  String? supplierName;
  String? email;
  String? groupName;
  String? gstNo;
  String? commissionScheme;
  num? commissionRate;
  String? referenceBy;
  String? addressLine1;
  String? addressLine2;
  String? state;
  String? city;
  String? pinCode;
  String? msme;
  String? bankName;
  String? ifscCode;
  String? branchName;
  String? accountName;
  String? accountNumber;
  String? remark;
  String? status;

  List<dynamic>? contacts;
  List<dynamic>? preferredTransports;

  GetSupplierByIdModel({
    this.success,
    this.message,
    this.id,
    this.code,
    this.supplierName,
    this.email,
    this.groupName,
    this.gstNo,
    this.commissionScheme,
    this.commissionRate,
    this.referenceBy,
    this.addressLine1,
    this.addressLine2,
    this.state,
    this.city,
    this.pinCode,
    this.msme,
    this.bankName,
    this.ifscCode,
    this.branchName,
    this.accountName,
    this.accountNumber,
    this.remark,
    this.status,
    this.contacts,
    this.preferredTransports,
  });

  GetSupplierByIdModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];

    final data = json['data'];

    if (data != null) {
      id = data['id'];
      code = data['code'];
      supplierName = data['supplierName'];
      email = data['email'];
      groupName = data['groupName'];
      gstNo = data['gstNo'];
      commissionScheme = data['commissionScheme'];
      commissionRate = data['commissionRate'];
      referenceBy = data['referenceBy'];
      addressLine1 = data['addressLine1'];
      addressLine2 = data['addressLine2'];
      state = data['state'];
      city = data['city'];
      pinCode = data['pinCode'];
      msme = data['msme'];
      bankName = data['bankName'];
      ifscCode = data['ifscCode'];
      branchName = data['branchName'];
      accountName = data['accountName'];
      accountNumber = data['accountNumber'];
      remark = data['remark'];
      status = data['status'];

      contacts = data['contacts'];
      preferredTransports = data['preferredTransports'];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": {
        "id": id,
        "code": code,
        "supplierName": supplierName,
        "email": email,
        "groupName": groupName,
        "gstNo": gstNo,
        "commissionScheme": commissionScheme,
        "commissionRate": commissionRate,
        "referenceBy": referenceBy,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "state": state,
        "city": city,
        "pinCode": pinCode,
        "msme": msme,
        "bankName": bankName,
        "ifscCode": ifscCode,
        "branchName": branchName,
        "accountName": accountName,
        "accountNumber": accountNumber,
        "remark": remark,
        "status": status,
        "contacts": contacts,
        "preferredTransports": preferredTransports,
      }
    };
  }
}