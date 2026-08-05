class Credit {
  final num? id;
  final String? paymentType;
  final String? billNumber;
  final String? date;
  final String? referenceNumber;
  final String? referenceDate;
  final num? receivedAmount;
  final String? supplierName;
  final String? customerName;
  final String? slipNumber;
  final String? drawType;
  final String? remark;
  final num? supplierId;
  final num? customerId;
  final String? supplierCity;
  final String? customerCity;

  Credit({
    this.id,
    this.paymentType,
    this.billNumber,
    this.date,
    this.referenceNumber,
    this.referenceDate,
    this.receivedAmount,
    this.supplierName,
    this.customerName,
    this.slipNumber,
    this.drawType,
    this.remark,
    this.supplierId,
    this.customerId,
    this.supplierCity,
    this.customerCity,
  });

  factory Credit.fromJson(Map<String, dynamic> json) {
    return Credit(
      id: json['id'],
      paymentType: json['paymentType'],
      billNumber: json['billNumber'],
      date: json['date'],
      referenceNumber: json['referenceNumber'],
      referenceDate: json['referenceDate'],
      receivedAmount: json['receivedAmount'],
      supplierName: json['supplierName'],
      customerName: json['customerName'],
      slipNumber: json['slipNumber'],
      drawType: json['drawType'],
      remark: json['remark'],
      supplierId: json['supplierId'],
      customerId: json['customerId'],
      supplierCity: json['supplierCity'],
      customerCity: json['customerCity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentType': paymentType,
      'billNumber': billNumber,
      'date': date,
      'referenceNumber': referenceNumber,
      'referenceDate': referenceDate,
      'receivedAmount': receivedAmount,
      'supplierName': supplierName,
      'customerName': customerName,
      'slipNumber': slipNumber,
      'drawType': drawType,
      'remark': remark,
      'supplierId': supplierId,
      'customerId': customerId,
      'supplierCity': supplierCity,
      'customerCity': customerCity,
    };
  }
}