import 'package:hisabio/model_classes/Transport/transport.dart';

class AddTransportRequest {
  final String name;
  final String? email;
  final String? gstNo;
  final String? state;
  final String? city;
  final String? pinCode;
  final String? addressLine1;
  final String? addressLine2;
  final String? status;
  final List<TransportContact> contacts;

  const AddTransportRequest({
    required this.name,
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

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "gstNo": gstNo,
      "state": state,
      "city": city,
      "pincode": pinCode,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "status": status,
      "contacts": contacts.map((e) => e.toJson()).toList(),
    };
  }
}