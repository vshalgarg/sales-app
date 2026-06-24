class PurchaseEntry {
  final int id;
  final String date;
  final String staffName;
  final String supplierName;
  final String customerName;
  final String remarks;
  final String customerCity;
  final String supplierCity;

  PurchaseEntry({
    required this.id,
    required this.date,
    required this.staffName,
    required this.supplierName,
    required this.customerName,
    required this.remarks,
    required this.customerCity,
    required this.supplierCity,
  });

  factory PurchaseEntry.fromJson(Map<String, dynamic> json) {
    return PurchaseEntry(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      staffName: json['staffName'] ?? '',
      supplierName: json['supplierName'] ?? '',
      customerName: json['customerName'] ?? '',
      remarks: json['remarks'] ?? '',
      customerCity: json['customerCity'] ?? '',
      supplierCity: json['supplierCity'] ?? '',
    );
  }
}