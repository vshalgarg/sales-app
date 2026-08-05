class Retail {
  final int id;
  final String name;
  final DateTime date;
  final int customerId;
  final String customerName;
  final int? staffId;
  final String? staffName;

  Retail({
    required this.id,
    required this.name,
    required this.date,
    required this.customerId,
    required this.customerName,
    this.staffId,
    this.staffName,
  });

  factory Retail.fromJson(Map<String, dynamic> json) {
    return Retail(
      id: json["retailId"] ?? 0,
      name: json["retailName"] ?? "",
      date: DateTime.parse(json['date']),
      customerId: json["referredByCustomerId"] ?? 0,
      customerName: json["referredByCustomerName"] ?? "",
      staffId: json['staffId'],
      staffName: json['staffName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String().split('T').first,
      'customerId': customerId,
      'customerName': customerName,
      'staffId': staffId,
      'staffName': staffName,
    };
  }
}












// class RetailModel {
//   final int retailId;
//   final String name;
//   final String date;
//   final String customerName;
//   final String staffName;
//   final int customerId;
//   final int staffId;
//   final List<RetailSupplierModel> suppliers;
//
//   RetailModel({
//     required this.retailId,
//     required this.name,
//     required this.date,
//     required this.customerName,
//     required this.staffName,
//     required this.suppliers,
//     required this.customerId,
//     required this.staffId
//   });
//
//   factory RetailModel.fromJson(Map<String, dynamic> json) {
//     return RetailModel(
//       retailId: json["retailId"] ?? json["id"] ?? 0,
//       name: json["retailName"] ?? json["name"] ?? "",
//       date: json["date"] ?? "",
//       customerId: json["referredByCustomerId"] ??
//           json["customerId"] ??
//           0,
//       customerName: json["referredByCustomerName"] ??
//           json["customerName"] ??
//           "",
//       staffId: json["staffId"] ?? 0,
//       staffName: json["staffName"] ?? "",
//       suppliers: (json["suppliers"] as List? ?? [])
//           .map((e) => RetailSupplierModel.fromJson(e))
//           .toList(),
//     );
//   }
// }
//
// class RetailSupplierModel {
//   final int retailSupplierId;
//   final int supplierId;
//   final String supplierName;
//   final String supplierCity;
//   final int totalAmount;
//   final int depositAmount;
//   final int balanceAmount;
//   final List<RetailDepositModel> deposits;
//   RetailSupplierModel({
//     required this.retailSupplierId,
//     required this.supplierId,
//     required this.supplierName,
//     required this.supplierCity,
//     required this.totalAmount,
//     required this.depositAmount,
//     required this.balanceAmount,
//     required this.deposits,
//   });
//
//   factory RetailSupplierModel.fromJson(
//       Map<String, dynamic> json) {
//     return RetailSupplierModel(
//       retailSupplierId: json['retailSupplierId'] ?? 0,
//       supplierId: json['supplierId'] ?? 0,
//       supplierName: json['supplierName'] ?? '',
//       supplierCity: json['supplierCity'] ?? '',
//       totalAmount: json['totalAmount'] ?? 0,
//       depositAmount: json['depositAmount'] ?? 0,
//       balanceAmount: json['balanceAmount'] ?? 0,
//       deposits: (json['deposits'] as List? ?? [])
//           .map((e) => RetailDepositModel.fromJson(e))
//           .toList(),
//     );
//   }
//
// }
// class RetailDepositModel {
//   final String date;
//   final int amount;
//
//   RetailDepositModel({
//     required this.date,
//     required this.amount,
//   });
//
//   factory RetailDepositModel.fromJson(
//       Map<String, dynamic> json) {
//     return RetailDepositModel(
//       date: json['date'] ?? '',
//       amount: json['amount'] ?? 0,
//     );
//   }
// }