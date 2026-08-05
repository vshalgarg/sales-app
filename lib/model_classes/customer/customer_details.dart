class CustomerDetailsResponse {
  final bool success;
  final String message;
  final CustomerDetails? data;

  const CustomerDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CustomerDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CustomerDetails.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class CustomerDetails {
  final int? id;
  final String? code;
  final String? customerName;
  final String? email;
  final String? groupName;
  final String? gstNo;
  final String? referencedBy;

  final String? addressLine1;
  final String? addressLine2;
  final String? state;
  final String? city;
  final String? pinCode;

  final String? msme;
  final String? remark;
  final String? status;

  final String? bankName;
  final String? ifsc;
  final String? branch;
  final String? accountName;
  final String? accountNumber;

  final List<CustomerContactDetails> contacts;
  final List<CustomerPreferredTransport> preferredTransports;

  const CustomerDetails({
    this.id,
    this.code,
    this.customerName,
    this.email,
    this.groupName,
    this.gstNo,
    this.referencedBy,
    this.addressLine1,
    this.addressLine2,
    this.state,
    this.city,
    this.pinCode,
    this.msme,
    this.remark,
    this.status,
    this.bankName,
    this.ifsc,
    this.branch,
    this.accountName,
    this.accountNumber,
    this.contacts = const [],
    this.preferredTransports = const [],
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      id: json['id'] as int?,
      code: json['code'],
      customerName: json['customerName'],
      email: json['email'],
      groupName: json['groupName'],
      gstNo: json['gstNo'],
      referencedBy: json['referencedBy'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      state: json['state'],
      city: json['city'],
      pinCode: json['pinCode']?.toString(),
      msme: json['msme'],
      remark: json['remark'],
      status: json['status'],
      bankName: json['bankName'],
      ifsc: json['ifsc'],
      branch: json['branch'],
      accountName: json['accountName'],
      accountNumber: json['accountNumber'],
      contacts: (json['contacts'] as List?)
          ?.map((e) => CustomerContactDetails.fromJson(e))
          .toList() ??
          const [],
      preferredTransports:
      (json['preferredTransports'] as List?)
          ?.map((e) => CustomerPreferredTransport.fromJson(e))
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'customerName': customerName,
    'email': email,
    'groupName': groupName,
    'gstNo': gstNo,
    'referencedBy': referencedBy,
    'addressLine1': addressLine1,
    'addressLine2': addressLine2,
    'state': state,
    'city': city,
    'pinCode': pinCode,
    'msme': msme,
    'remark': remark,
    'status': status,
    'bankName': bankName,
    'ifsc': ifsc,
    'branch': branch,
    'accountName': accountName,
    'accountNumber': accountNumber,
    'contacts': contacts.map((e) => e.toJson()).toList(),
    'preferredTransports':
    preferredTransports.map((e) => e.toJson()).toList(),
  };
}

class CustomerContactDetails {
  final String? contactPerson;
  final String? mobileNumber;
  final String? type;

  const CustomerContactDetails({
    this.contactPerson,
    this.mobileNumber,
    this.type,
  });

  factory CustomerContactDetails.fromJson(Map<String, dynamic> json) {
    return CustomerContactDetails(
      contactPerson: json['contactPerson'],
      mobileNumber: json['mobileNumber'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'contactPerson': contactPerson,
    'mobileNumber': mobileNumber,
    'type': type,
  };
}

class CustomerPreferredTransport {
  final int? id;
  final String? name;

  const CustomerPreferredTransport({
    this.id,
    this.name,
  });

  factory CustomerPreferredTransport.fromJson(
      Map<String, dynamic> json) {
    return CustomerPreferredTransport(
      id: json['id'] as int?,
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}