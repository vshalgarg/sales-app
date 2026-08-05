

import 'bill_item_model.dart';

class AddBillRequest {
  final num? id;
  final String? billNumber;
  final String? date;
  final String? receivedDate;
  final String? invoiceNo;

  final num? supplierId;
  final num? customerId;

  final String? transport;
  final String? lrNumber;
  final String? remarks;

  final num? billAmount;
  final num? taxableValue;

  final List<BillItem>? items;

  AddBillRequest({
    this.id,
    this.billNumber,
    this.date,
    this.receivedDate,
    this.invoiceNo,
    this.supplierId,
    this.customerId,
    this.transport,
    this.lrNumber,
    this.remarks,
    this.billAmount,
    this.taxableValue,
    this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billNumber': billNumber,
      'date': date,
      'receivedDate': receivedDate,
      'invoiceNo': invoiceNo,
      'supplierId': supplierId,
      'customerId': customerId,
      'transport': transport,
      'lrNumber': lrNumber,
      'remarks': remarks,
      'billAmount': billAmount,
      'taxableValue': taxableValue,
      'items': items?.map((e) => e.toJson()).toList(),
    };
  }

  factory AddBillRequest.fromJson(Map<String, dynamic> json) {
    return AddBillRequest(
      id: json['id'],
      billNumber: json['billNumber'],
      date: json['date'],
      receivedDate: json['receivedDate'],
      invoiceNo: json['invoiceNo'],
      supplierId: json['supplierId'],
      customerId: json['customerId'],
      transport: json['transport'],
      lrNumber: json['lrNumber'],
      remarks: json['remarks'],
      billAmount: json['billAmount'],
      taxableValue: json['taxableValue'],
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => BillItem.fromJson(e))
          .toList(),
    );
  }

  AddBillRequest copyWith({
    num? id,
    String? billNumber,
    String? date,
    String? receivedDate,
    String? invoiceNo,
    num? supplierId,
    num? customerId,
    String? transport,
    String? lrNumber,
    String? remarks,
    num? billAmount,
    num? taxableValue,
    List<BillItem>? items,
  }) {
    return AddBillRequest(
      id: id ?? this.id,
      billNumber: billNumber ?? this.billNumber,
      date: date ?? this.date,
      receivedDate: receivedDate ?? this.receivedDate,
      invoiceNo: invoiceNo ?? this.invoiceNo,
      supplierId: supplierId ?? this.supplierId,
      customerId: customerId ?? this.customerId,
      transport: transport ?? this.transport,
      lrNumber: lrNumber ?? this.lrNumber,
      remarks: remarks ?? this.remarks,
      billAmount: billAmount ?? this.billAmount,
      taxableValue: taxableValue ?? this.taxableValue,
      items: items ?? this.items,
    );
  }
}














// class BillEntry {
//   final int id;
//   final String billNumber;
//   final String date;
//   final String receivedDate;
//   final String invoiceNo;
//   final String supplierName;
//   final String customerName;
//   final double billAmount;
//   final String supplierCity;
//   final String customerCity;
//
//   BillEntry({
//     required this.id,
//     required this.billNumber,
//     required this.date,
//     required this.receivedDate,
//     required this.invoiceNo,
//     required this.supplierName,
//     required this.customerName,
//     required this.billAmount,
//     required this.supplierCity,
//     required this.customerCity,
//   });
//
//   factory BillEntry.fromJson(Map<String, dynamic> json) {
//     return BillEntry(
//       id: json['id'],
//       billNumber: json['billNumber'] ?? '',
//       date: json['date'] ?? '',
//       receivedDate: json['receivedDate'] ?? '',
//       invoiceNo: json['invoiceNo'] ?? '',
//       supplierName: json['supplierName'] ?? '',
//       customerName: json['customerName'] ?? '',
//       billAmount: (json['billAmount'] ?? 0).toDouble(),
//       supplierCity: json['supplierCity'] ?? '',
//       customerCity: json['customerCity'] ?? '',
//     );
//   }
// }