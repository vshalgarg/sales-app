class AddCreditRequest {
  final String? billNumber;
  final String date;
  final int supplierId;
  final int? customerId;
  final String paymentType;
  final String referenceNumber;
  final String referenceDate;
  final String? slipNumber;
  final String? drawType;
  final double receivedAmount;
  final String? remark;

  const AddCreditRequest({
    this.billNumber,
    required this.date,
    required this.supplierId,
    this.customerId,
    required this.paymentType,
    required this.referenceNumber,
    required this.referenceDate,
    this.slipNumber,
    this.drawType,
    required this.receivedAmount,
    this.remark,
  });

  factory AddCreditRequest.fromJson(Map<String, dynamic> json) {
    return AddCreditRequest(
      billNumber: json['billNumber'],
      date: json['date'] ?? '',
      supplierId: json['supplierId'] ?? 0,
      customerId: json['customerId'],
      paymentType: json['paymentType'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      referenceDate: json['referenceDate'] ?? '',
      slipNumber: json['slipNumber'],
      drawType: json['drawType'],
      receivedAmount: json['receivedAmount'] == null ||
          json['receivedAmount'].toString().isEmpty
          ? 0.0
          : double.parse(json['receivedAmount'].toString()),
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "billNumber": billNumber ?? "",
      "date": date,
      "supplierId": supplierId,
      "customerId": customerId,
      "paymentType": paymentType,
      "referenceNumber": referenceNumber,
      "referenceDate": referenceDate,
      "slipNumber": slipNumber ?? "",
      "drawType": drawType,
      "receivedAmount": receivedAmount,
      "remark": remark ?? "",
    };
  }

  AddCreditRequest copyWith({
    String? billNumber,
    String? date,
    int? supplierId,
    int? customerId,
    String? paymentType,
    String? referenceNumber,
    String? referenceDate,
    String? slipNumber,
    String? drawType,
    double? receivedAmount,
    String? remark,
  }) {
    return AddCreditRequest(
      billNumber: billNumber ?? this.billNumber,
      date: date ?? this.date,
      supplierId: supplierId ?? this.supplierId,
      customerId: customerId ?? this.customerId,
      paymentType: paymentType ?? this.paymentType,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      referenceDate: referenceDate ?? this.referenceDate,
      slipNumber: slipNumber ?? this.slipNumber,
      drawType: drawType ?? this.drawType,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      remark: remark ?? this.remark,
    );
  }
}