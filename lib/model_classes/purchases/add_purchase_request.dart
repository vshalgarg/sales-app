class AddPurchaseRequest {
  final String date;
  final num? staffId;
  final num? customerId;
  final List<PurchaseSupplierRequest> suppliers;

  AddPurchaseRequest({
    required this.date,
    this.staffId,
    this.customerId,
    required this.suppliers,
  });

  Map<String, dynamic> toJson() {
    return {
      "date": date,
      "staffId": staffId,
      "customerId": customerId,
      "suppliers": suppliers.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseSupplierRequest {
  final num? supplierId;
  final String remarks;

  PurchaseSupplierRequest({this.supplierId, required this.remarks});

  Map<String, dynamic> toJson() {
    return {
      "supplierId": supplierId,
      "remarks": (remarks.trim().isEmpty) ? null : remarks,
    };
  }
}
