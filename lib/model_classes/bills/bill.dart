class Bill {
  final num? id;
  final String? billNumber;
  final String? date;
  final String? receivedDate;
  final String? invoiceNo;
  final String? supplierName;
  final String? customerName;
  final num? billAmount;
  final String? supplierCity;
  final String? customerCity;

  Bill({
    this.id,
    this.billNumber,
    this.date,
    this.receivedDate,
    this.invoiceNo,
    this.supplierName,
    this.customerName,
    this.billAmount,
    this.supplierCity,
    this.customerCity,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      billNumber: json['billNumber'],
      date: json['date'],
      receivedDate: json['receivedDate'],
      invoiceNo: json['invoiceNo'],
      supplierName: json['supplierName'],
      customerName: json['customerName'],
      billAmount: json['billAmount'],
      supplierCity: json['supplierCity'],
      customerCity: json['customerCity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billNumber': billNumber,
      'date': date,
      'receivedDate': receivedDate,
      'invoiceNo': invoiceNo,
      'supplierName': supplierName,
      'customerName': customerName,
      'billAmount': billAmount,
      'supplierCity': supplierCity,
      'customerCity': customerCity,
    };
  }
}