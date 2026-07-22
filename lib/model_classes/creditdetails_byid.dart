class CreditDetailsResponse {
  final bool success;
  final String message;
  final CreditDetails? data;

  CreditDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreditDetailsResponse.fromJson(Map<String, dynamic> json) {
    return CreditDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CreditDetails.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CreditDetails {
  final int id;
  final String paymentType;
  final String billNumber;
  final String date;
  final String referenceNumber;
  final String referenceDate;
  final double receivedAmount;
  final String? drawType;
  final String? remark;
  final String? slipNumber;
  final int supplierId;
  final String supplierName;
  final String supplierCity;
  final int customerId;
  final String customerName;
  final String customerCity;

  CreditDetails({
    required this.id,
    required this.paymentType,
    required this.billNumber,
    required this.date,
    required this.referenceNumber,
    required this.referenceDate,
    required this.receivedAmount,
    this.drawType,
    this.remark,
    this.slipNumber,
    required this.supplierId,
    required this.supplierName,
    required this.supplierCity,
    required this.customerId,
    required this.customerName,
    required this.customerCity,
  });

  factory CreditDetails.fromJson(Map<String, dynamic> json) {
    return CreditDetails(
      id: json['id'] ?? 0,
      paymentType: json['paymentType'] ?? '',
      billNumber: json['billNumber'] ?? '',
      date: json['date'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      referenceDate: json['referenceDate'] ?? '',
      receivedAmount: (json['receivedAmount'] as num?)?.toDouble() ?? 0.0,
      drawType: json['drawType'],
      remark: json['remark'],
      slipNumber: json['slipNumber'],
      supplierId: json['supplierId'] ?? 0,
      supplierName: json['supplierName'] ?? '',
      supplierCity: json['supplierCity'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerCity: json['customerCity'] ?? '',
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
      'drawType': drawType,
      'remark': remark,
      'slipNumber': slipNumber,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'supplierCity': supplierCity,
      'customerId': customerId,
      'customerName': customerName,
      'customerCity': customerCity,
    };
  }
}