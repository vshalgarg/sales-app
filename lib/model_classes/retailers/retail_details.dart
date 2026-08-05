class RetailDetails {
  final int id;
  final String name;
  final DateTime date;
  final int referredByCustomerId;
  final String customerName;
  final int? staffId;
  final String? staffName;
  final List<RetailSupplier> suppliers;

  RetailDetails({
    required this.id,
    required this.name,
    required this.date,
    required this.referredByCustomerId,
    required this.customerName,
    this.staffId,
    this.staffName,
    required this.suppliers,
  });

  factory RetailDetails.fromJson(Map<String, dynamic> json) {
    return RetailDetails(
      id: json['id'],
      name: json['name'] ?? '',
      date: DateTime.parse(json['date']),
      referredByCustomerId: json['referredByCustomerId'],
      customerName: json['customerName'] ?? '',
      staffId: json['staffId'],
      staffName: json['staffName'],
      suppliers: (json['suppliers'] as List<dynamic>? ?? [])
          .map((e) => RetailSupplier.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String().split('T').first,
      'referredByCustomerId': referredByCustomerId,
      'customerName': customerName,
      'staffId': staffId,
      'staffName': staffName,
      'suppliers': suppliers.map((e) => e.toJson()).toList(),
    };
  }
}

class RetailSupplier {
  final int retailSupplierId;
  final int supplierId;
  final String supplierName;
  final String supplierCity;
  final double totalAmount;
  final double depositAmount;
  final double balanceAmount;

  RetailSupplier({
    required this.retailSupplierId,
    required this.supplierId,
    required this.supplierName,
    required this.supplierCity,
    required this.totalAmount,
    required this.depositAmount,
    required this.balanceAmount,
  });

  factory RetailSupplier.fromJson(Map<String, dynamic> json) {
    return RetailSupplier(
      retailSupplierId: json['retailSupplierId'],
      supplierId: json['supplierId'],
      supplierName: json['supplierName'] ?? '',
      supplierCity: json['supplierCity'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      depositAmount: (json['depositAmount'] ?? 0).toDouble(),
      balanceAmount: (json['balanceAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retailSupplierId': retailSupplierId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierCity': supplierCity,
      'totalAmount': totalAmount,
      'depositAmount': depositAmount,
      'balanceAmount': balanceAmount,
    };
  }
}