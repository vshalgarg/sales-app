import 'package:hisabio/model_classes/Transport/transport.dart';

class TransportDetails {
  final num? id;
  final String? name;
  final String? email;
  final String? gstNo;
  final String? state;
  final String? city;
  final String? pinCode;
  final String? addressLine1;
  final String? addressLine2;
  final String? status;
  final List<TransportContact> contacts;

  const TransportDetails({
    this.id,
    this.name,
    this.email,
    this.gstNo,
    this.state,
    this.city,
    this.pinCode,
    this.addressLine1,
    this.addressLine2,
    this.status,
    this.contacts = const [],
  });

  factory TransportDetails.fromJson(Map<String, dynamic> json) {
    return TransportDetails(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      gstNo: json['gstNo'],
      state: json['state'],
      city: json['city'],
      pinCode: json['pinCode'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      status: json['status'],
      contacts: (json['contacts'] as List<dynamic>?)
          ?.map((e) => TransportContact.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gstNo': gstNo,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'status': status,
      'contacts': contacts.map((e) => e.toJson()).toList(),
    };
  }
}