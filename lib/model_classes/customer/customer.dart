class Customer {
  final int id;
  final String code;
  final String customerName;
  final String? customerGstNo;
  final String? address;
  final String? city;
  final String? email;
  final List<CustomerContact> contacts;


  const Customer({
    required this.id,
    required this.code,
    required this.customerName,
    this.customerGstNo,
    this.address,
    this.city,
    this.email,
    this.contacts = const [],
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      customerName: json['customerName'] ?? '',
      customerGstNo: json['customerGstNo'],
      address: json['address'],
      city: json['city'],
      email: json['email'],
      contacts: (json['contacts'] as List?)
          ?.map((e) => CustomerContact.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'customerName': customerName,
    'customerGstNo': customerGstNo,
    'address': address,
    'city': city,
    'email': email,
    'contacts': contacts.map((e) => e.toJson()).toList(),
  };

  Customer copyWith({
    int? id,
    String? code,
    String? customerName,
    String? customerGstNo,
    String? address,
    String? city,
    String? email,
    List<CustomerContact>? contacts,
  }) {
    return Customer(
      id: id ?? this.id,
      code: code ?? this.code,
      customerName: customerName ?? this.customerName,
      customerGstNo: customerGstNo ?? this.customerGstNo,
      address: address ?? this.address,
      city: city ?? this.city,
      email: email ?? this.email,
      contacts: contacts ?? this.contacts,
    );
  }

  @override
  String toString() => 'Customer(id: $id, customerName: $customerName)';
}

class CustomerContact {
  final String? contactPerson;
  final String? mobileNumber;
  final String? type;

  const CustomerContact({
    this.contactPerson,
    this.mobileNumber,
    this.type,
  });

  factory CustomerContact.fromJson(Map<String, dynamic> json) {
    return CustomerContact(
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