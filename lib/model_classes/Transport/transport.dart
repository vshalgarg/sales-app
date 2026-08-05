class Transport {
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

  const Transport({
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

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
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
          ?.map((e) => TransportContact.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "gstNo": gstNo,
      "state": state,
      "city": city,
      "pinCode": pinCode,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "status": status,
      "contacts": contacts.map((e) => e.toJson()).toList(),
    };
  }
}

class TransportContact {
  final String? contactPerson;
  final String? contactNumber;
  final String? type;

  const TransportContact({
    this.contactPerson,
    this.contactNumber,
    this.type,
  });

  factory TransportContact.fromJson(Map<String, dynamic> json) {
    return TransportContact(
      contactPerson: json["contactPerson"],
      contactNumber: json["contactNumber"],
      type: json["type"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "contactPerson": contactPerson,
      "contactNumber": contactNumber,
      "type": type,
    };
  }
}