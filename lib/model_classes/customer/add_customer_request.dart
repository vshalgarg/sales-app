import '../supplier/bank_details_request.dart';

class AddCustomerRequest {
  final String customerName;
  final String? email;
  final int? groupId;
  final String? gstNo;
  final String? referencedBy;
  final String? msme;
  final String? remark;
  final bool status;

  final String? addressLine1;
  final String? addressLine2;
  final String? state;
  final String? city;
  final String? pinCode;

  final List<BankDetailRequest> bankDetails;

  final List<CustomerContactRequest> contacts;
  final List<int> preferredTransportIds;

  const AddCustomerRequest({
    required this.customerName,
    this.email,
    this.groupId,
    this.gstNo,
    this.referencedBy,
    this.msme,
    this.remark,
    this.status = true,
    this.addressLine1,
    this.addressLine2,
    this.state,
    this.city,
    this.pinCode,
    this.bankDetails = const [],
    this.contacts = const [],
    this.preferredTransportIds = const [],
  });

  factory AddCustomerRequest.fromJson(Map<String, dynamic> json) {
    return AddCustomerRequest(
      customerName: json['customerName'] ?? '',
      email: json['email'],
      groupId: json['groupId'],
      gstNo: json['customerGstNo'],
      referencedBy: json['referencedBy'],
      msme: json['customerMsme'],
      remark: json['remark'],
      status: json['status'] ?? true,
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      state: json['state'],
      city: json['city'],
      pinCode: json['pinCode']?.toString(),
      bankDetails: (json['bankDetails'] as List?)
          ?.map(
            (e) => BankDetailRequest.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList() ??
          const [],
      contacts: (json['contacts'] as List?)
          ?.map((e) => CustomerContactRequest.fromJson(e))
          .toList() ??
          const [],
      preferredTransportIds:
      (json['preferredTransportIds'] as List?)
          ?.map((e) => e as int)
          .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'email': email,
      'customerGroup': groupId,
      'customerGstNo': gstNo,
      'customerMsme': msme,
      'referencedBy': referencedBy,
      'remark': remark,
      'status': status,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'bankDetails': bankDetails
          .map((bank) => bank.toJson())
          .toList(),
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'preferredTransportIds': preferredTransportIds,
    };
  }
  Map<String, dynamic> toUpdateJson() {
    return {
      'customerName': customerName,
      'email': email,
      'groupName': groupId,
      'gstNo': gstNo,
      'msme': msme,
      'referencedBy': referencedBy,
      'remark': remark,
      'status': status,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'bankDetails': bankDetails.map((bank) => bank.toJson()).toList(),
      'contacts': contacts.map((e) => e.toJson()).toList(),
      'preferredTransportIds': preferredTransportIds,
    };
  }

  AddCustomerRequest copyWith({
    String? customerName,
    String? email,
    int? groupId,
    String? gstNo,
    String? referencedBy,
    String? msme,
    String? remark,
    bool? status,
    String? addressLine1,
    String? addressLine2,
    int? stateId,
    int? cityId,
    String? pinCode,
    List<BankDetailRequest>? bankDetails,
    List<CustomerContactRequest>? contacts,
    List<int>? preferredTransportIds,
  }) {
    return AddCustomerRequest(
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      groupId: groupId ?? this.groupId,
      gstNo: gstNo ?? this.gstNo,
      referencedBy: referencedBy ?? this.referencedBy,
      msme: msme ?? this.msme,
      remark: remark ?? this.remark,
      status: status ?? this.status,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      state: state ?? state,
      city: city ?? city,
      pinCode: pinCode ?? this.pinCode,
      bankDetails: bankDetails ?? this.bankDetails,
      contacts: contacts ?? this.contacts,
      preferredTransportIds:
      preferredTransportIds ?? this.preferredTransportIds,
    );
  }

}

class CustomerContactRequest {
  final String contactPerson;
  final String mobileNumber;
  final String? type;
  final String? email;
  final bool primaryContact;

  const CustomerContactRequest({
    required this.contactPerson,
    required this.mobileNumber,
    this.type,
    this.email,
    this.primaryContact = false,
  });

  factory CustomerContactRequest.fromJson(Map<String, dynamic> json) {
    return CustomerContactRequest(
      contactPerson: json['contactPerson'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      type: json['type'],
      email: json['email'],
      primaryContact: json['primaryContact'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contactPerson': contactPerson,
      'mobileNumber': mobileNumber,
      'type': type,
      'email': email,
      'primaryContact': primaryContact,
    };
  }

  CustomerContactRequest copyWith({
    String? contactPerson,
    String? mobileNumber,
    String? type,
    String? email,
    bool? primaryContact,
  }) {
    return CustomerContactRequest(
      contactPerson: contactPerson ?? this.contactPerson,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      type: type ?? this.type,
      email: email ?? this.email,
      primaryContact: primaryContact ?? this.primaryContact,
    );
  }
}