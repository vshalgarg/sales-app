class Purchase {
  final num? id;
  final String? date;
  final String? staffName;
  final String? supplierName;
  final String? customerName;
  final String? remarks;
  final String? customerCity;
  final String? supplierCity;

  Purchase({
    this.id,
    this.date,
    this.staffName,
    this.supplierName,
    this.customerName,
    this.remarks,
    this.customerCity,
    this.supplierCity,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json["id"],
      date: json["date"],
      staffName: json["staffName"],
      supplierName: json["supplierName"],
      customerName: json["customerName"],
      remarks: json["remarks"],
      customerCity: json["customerCity"],
      supplierCity: json["supplierCity"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date,
      "staffName": staffName,
      "supplierName": supplierName,
      "customerName": customerName,
      "remarks": remarks,
      "customerCity": customerCity,
      "supplierCity": supplierCity,
    };
  }
}