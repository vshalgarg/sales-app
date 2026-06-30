class AddDepositModel {
  final List<DepositItem> deposits;

  AddDepositModel({
    required this.deposits,
  });

  Map<String, dynamic> toJson() {
    return {
      "deposits": deposits
          .map((e) => e.toJson())
          .toList(),
    };
  }
}

class DepositItem {
  final int retailSupplierId;
  final String depositDate;
  final int amount;

  DepositItem({
    required this.retailSupplierId,
    required this.depositDate,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      "retailSupplierId": retailSupplierId,
      "depositDate": depositDate,
      "amount": amount,
    };
  }
}