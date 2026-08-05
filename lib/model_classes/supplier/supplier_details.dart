class SupplierDetailsResponse {
  final bool success;
  final String message;
  final SupplierDetails? data;

 const SupplierDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SupplierDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SupplierDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SupplierDetails.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class SupplierDetails {
  final int? id;
  final String? code;
  final String? supplierName;
  final String? email;
  final String? groupName;
  final String? gstNo;
  final String? commissionScheme;
  final num? commissionRate;
  final String? referenceBy;
  final String? addressLine1;
  final String? addressLine2;
  final String? state;
  final String? city;
  final String? pinCode;
  final String? msme;
  final String? bankName;
  final String? ifscCode;
  final String? branchName;
  final String? accountName;
  final String? accountNumber;
  final String? remark;
  final String? status;

  final List<dynamic> contacts;
  final List<dynamic> preferredTransports;

 const SupplierDetails({
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
    this.contacts = const [],
    this.preferredTransports = const [],
  });

  factory SupplierDetails.fromJson(Map<String, dynamic> json) {
    return SupplierDetails(
      id: json['id']as int?,
      code: json['code'],
      supplierName: json['supplierName'],
      email: json['email'],
      groupName: json['groupName'],
      gstNo: json['gstNo'],
      commissionScheme: json['commissionScheme'],
      commissionRate: json['commissionRate'],
      referenceBy: json['referenceBy'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      state: json['state'],
      city: json['city'],
      pinCode: json['pinCode']?.toString(),
      msme: json['msme'],
      bankName: json['bankName'],
      ifscCode: json['ifscCode'],
      branchName: json['branchName'],
      accountName: json['accountName'],
      accountNumber: json['accountNumber'],
      remark: json['remark'],
      status: json['status'],
      contacts: json['contacts'] ?? [],
      preferredTransports: json['preferredTransports'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'supplierName': supplierName,
      'email': email,
      'groupName': groupName,
      'gstNo': gstNo,
      'commissionScheme': commissionScheme,
      'commissionRate': commissionRate,
      'referenceBy': referenceBy,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'msme': msme,
      'bankName': bankName,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'remark': remark,
      'status': status,
      'contacts': contacts,
      'preferredTransports': preferredTransports,
    };
  }
}