import 'bank_details_request.dart';

class AddSupplierRequest {
  final String supplierName;
  final String? email;
  final String? supplierGroup;
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

  final List<BankDetailRequest>? bankDetails;

  final String? remark;
  final List<Map<String, dynamic>>? contacts;
  final List<int>? preferredTransportIds;

  const AddSupplierRequest({
    required this.supplierName,
    this.email,
    this.supplierGroup,
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
    this.bankDetails,
    this.remark,
    this.contacts,
    this.preferredTransportIds,
  });

  factory AddSupplierRequest.fromJson(Map<String, dynamic> json) {
    return AddSupplierRequest(
      supplierName: json['supplierName'] ?? '',
      email: json['email'],
      supplierGroup: json['supplierGroup'],
      gstNo: json['gstNo'],
      commissionScheme: json['commissionScheme'],
      commissionRate: json['commissionRate'],
      referenceBy: json['referenceBy'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      state: json['state'],
      city: json['city'],
      pinCode: json['pinCode'],
      msme: json['msme'],
      bankDetails: (json['bankDetails'] as List?)
          ?.map(
            (e) => BankDetailRequest.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),
      remark: json['remark'],
      contacts: (json['contacts'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      preferredTransportIds:
      (json['preferredTransportIds'] as List?)
          ?.map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierName': supplierName,
      'email': email,
      'supplierGroup': supplierGroup,
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
      'bankDetails':
      bankDetails?.map((bank) => bank.toJson()).toList(),
      'remark': remark,
      'contacts': contacts,
      'preferredTransportIds': preferredTransportIds,
    };
  }

  AddSupplierRequest copyWith({
    String? supplierName,
    String? email,
    String? supplierGroup,
    String? gstNo,
    String? commissionScheme,
    num? commissionRate,
    String? referenceBy,
    String? addressLine1,
    String? addressLine2,
    String? state,
    String? city,
    String? pinCode,
    String? msme,
    List<BankDetailRequest>? bankDetails,
    String? remark,
    List<Map<String, dynamic>>? contacts,
    List<int>? preferredTransportIds,
  }) {
    return AddSupplierRequest(
      supplierName: supplierName ?? this.supplierName,
      email: email ?? this.email,
      supplierGroup: supplierGroup ?? this.supplierGroup,
      gstNo: gstNo ?? this.gstNo,
      commissionScheme: commissionScheme ?? this.commissionScheme,
      commissionRate: commissionRate ?? this.commissionRate,
      referenceBy: referenceBy ?? this.referenceBy,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      state: state ?? this.state,
      city: city ?? this.city,
      pinCode: pinCode ?? this.pinCode,
      msme: msme ?? this.msme,
      bankDetails: bankDetails ?? this.bankDetails,
      remark: remark ?? this.remark,
      contacts: contacts ?? this.contacts,
      preferredTransportIds:
      preferredTransportIds ?? this.preferredTransportIds,
    );
  }

  @override
  String toString() {
    return 'AddSupplierRequest(supplierName: $supplierName)';
  }
}