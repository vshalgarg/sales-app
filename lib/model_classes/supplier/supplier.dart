class Supplier {
  final int id;
  final String code;
  final String supplierName;
  final String? supplierGstNo;
  final String? address;
  final String? city;
  final String? mobile;

  const Supplier({
    required this.id,
    required this.code,
    required this.supplierName,
    this.supplierGstNo,
    this.address,
    this.city,
    this.mobile,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      supplierName: json['supplierName'] ?? '',
      supplierGstNo: json['supplierGstNo'],
      address: json['address'],
      city: json['city'],
      mobile: json['mobile'],
    );
  }

  Map<String, dynamic> toJson() => {
      'id': id,
      'code': code,
      'supplierName': supplierName,
      'supplierGstNo': supplierGstNo,
      'address': address,
      'city': city,
      'mobile': mobile,
    };
    Supplier copyWith({
      int? id,
      String? code,
      String? supplierName,
      String? supplierGstNo,
      String? address,
      String? city,
      String? mobile,
    }) {
      return Supplier(
        id: id ?? this.id,
        code: code ?? this.code,
        supplierName: supplierName ?? this.supplierName,
        supplierGstNo: supplierGstNo ?? this.supplierGstNo,
        address: address ?? this.address,
        city: city ?? this.city,
        mobile: mobile ?? this.mobile,
      );
    }

    @override
    String toString() => 'Supplier(id: $id, supplierName: $supplierName)';
  }