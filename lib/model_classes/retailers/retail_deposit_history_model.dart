class RetailDepositHistoryModel {
  final int retailSupplierId;
  final int supplierId;
  final String supplierName;
  final String supplierCity;
  final int totalAmount;
  final int depositAmount;
  final int balanceAmount;
  final List<DepositHistory> deposits;

  RetailDepositHistoryModel({
    required this.retailSupplierId,
    required this.supplierId,
    required this.supplierName,
    required this.supplierCity,
    required this.totalAmount,
    required this.depositAmount,
    required this.balanceAmount,
    required this.deposits,
  });

  factory RetailDepositHistoryModel.fromJson(
      Map<String, dynamic> json) {
    return RetailDepositHistoryModel(
      retailSupplierId: json["retailSupplierId"] ?? 0,
      supplierId: json["supplierId"] ?? 0,
      supplierName: json["supplierName"] ?? "",
      supplierCity: json["supplierCity"] ?? "",
      totalAmount: json["totalAmount"] ?? 0,
      depositAmount: json["depositAmount"] ?? 0,
      balanceAmount: json["balanceAmount"] ?? 0,
      deposits: (json["deposits"] as List? ?? [])
          .map((e) => DepositHistory.fromJson(e))
          .toList(),
    );
  }
}

class DepositHistory {
  final String date;
  final int amount;

  DepositHistory({
    required this.date,
    required this.amount,
  });

  factory DepositHistory.fromJson(
      Map<String, dynamic> json) {
    return DepositHistory(
      date: json["date"] ?? "",
      amount: json["amount"] ?? 0,
    );
  }
}