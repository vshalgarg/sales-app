class BillEntry {
  final int id;
  final String billNumber;
  final String date;
  final String receivedDate;
  final String invoiceNo;
  final String supplierName;
  final String customerName;
  final double billAmount;
  final String supplierCity;
  final String customerCity;

  BillEntry({
    required this.id,
    required this.billNumber,
    required this.date,
    required this.receivedDate,
    required this.invoiceNo,
    required this.supplierName,
    required this.customerName,
    required this.billAmount,
    required this.supplierCity,
    required this.customerCity,
  });

  factory BillEntry.fromJson(Map<String, dynamic> json) {
    return BillEntry(
      id: json['id'],
      billNumber: json['billNumber'] ?? '',
      date: json['date'] ?? '',
      receivedDate: json['receivedDate'] ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      supplierName: json['supplierName'] ?? '',
      customerName: json['customerName'] ?? '',
      billAmount: (json['billAmount'] ?? 0).toDouble(),
      supplierCity: json['supplierCity'] ?? '',
      customerCity: json['customerCity'] ?? '',
    );
  }
}