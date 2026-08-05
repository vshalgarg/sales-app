import 'bill_item_model.dart';

class BillDetails {
  final num? id;
  final String? billNumber;
  final String? date;
  final String? receivedDate;
  final String? invoiceNo;

  final String? supplierName;
  final num? supplierId;
  final String? supplierGroup;
  final String? supplierGstNo;
  final String? supplierMsme;

  final String? customerName;
  final num? customerId;
  final String? customerGroup;
  final String? customerGstNo;
  final String? customerMsme;

  final num? billAmount;
  final num? taxableValue;

  final String? transport;
  final String? lrNumber;
  final String? remarks;

  final List<BillItem>? items;

  final List<dynamic>? objectKeys;
  final List<dynamic>? publicUrls;
  final List<dynamic>? originalFileNames;

  BillDetails({
    this.id,
    this.billNumber,
    this.date,
    this.receivedDate,
    this.invoiceNo,
    this.supplierName,
    this.supplierId,
    this.supplierGroup,
    this.supplierGstNo,
    this.supplierMsme,
    this.customerName,
    this.customerId,
    this.customerGroup,
    this.customerGstNo,
    this.customerMsme,
    this.billAmount,
    this.taxableValue,
    this.transport,
    this.lrNumber,
    this.remarks,
    this.items,
    this.objectKeys,
    this.publicUrls,
    this.originalFileNames,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) {
    return BillDetails(
      id: json['id'],
      billNumber: json['billNumber'],
      date: json['date'],
      receivedDate: json['receivedDate'],
      invoiceNo: json['invoiceNo'],
      supplierName: json['supplierName'],
      supplierId: json['supplierId'],
      supplierGroup: json['supplierGroup'],
      supplierGstNo: json['supplierGstNo'],
      supplierMsme: json['supplierMsme'],
      customerName: json['customerName'],
      customerId: json['customerId'],
      customerGroup: json['customerGroup'],
      customerGstNo: json['customerGstNo'],
      customerMsme: json['customerMsme'],
      billAmount: json['billAmount'],
      taxableValue: json['taxableValue'],
      transport: json['transport'],
      lrNumber: json['lrNumber'],
      remarks: json['remarks'],
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => BillItem.fromJson(e))
          .toList(),
      objectKeys: json['objectKeys'] ?? [],
      publicUrls: json['publicUrls'] ?? [],
      originalFileNames: json['originalFileNames'] ?? [],
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
      'supplierId': supplierId,
      'supplierGroup': supplierGroup,
      'supplierGstNo': supplierGstNo,
      'supplierMsme': supplierMsme,
      'customerName': customerName,
      'customerId': customerId,
      'customerGroup': customerGroup,
      'customerGstNo': customerGstNo,
      'customerMsme': customerMsme,
      'billAmount': billAmount,
      'taxableValue': taxableValue,
      'transport': transport,
      'lrNumber': lrNumber,
      'remarks': remarks,
      'items': items?.map((e) => e.toJson()).toList(),
      'objectKeys': objectKeys,
      'publicUrls': publicUrls,
      'originalFileNames': originalFileNames,
    };
  }
}







// import 'bill_item_model.dart';
//
// class BillResponse {
//   final int? id;
//   final String? billNumber;
//   final String? date;
//   final String? receivedDate;
//   final String? invoiceNo;
//   final String? supplierName;
//   final String? customerName;
//   final double? billAmount;
//   final double? taxableValue;
//   final int? supplierId;
//   final String? supplierGroup;
//   final String? supplierGstNo;
//   final String? supplierMsme;
//   final int? customerId;
//   final String? customerGroup;
//   final String? customerGstNo;
//   final String? customerMsme;
//   final String? transport;
//   final String? lrNumber;
//   final String? remarks;
//   final List<BillItem>? items;
//   final List<dynamic>? objectKeys;
//   final List<dynamic>? publicUrls;
//   final List<dynamic>? originalFileNames;
//
//   BillResponse({
//      this.id,
//      this.billNumber,
//      this.date,
//      this.receivedDate,
//      this.invoiceNo,
//      this.supplierName,
//      this.customerName,
//      this.billAmount,
//      this.taxableValue,
//      this.supplierId,
//      this.supplierGroup,
//     this.supplierGstNo,
//      this.supplierMsme,
//      this.customerId,
//      this.customerGroup,
//     this.customerGstNo,
//      this.customerMsme,
//      this.transport,
//      this.lrNumber,
//      this.remarks,
//      this.items,
//      this.objectKeys,
//      this.publicUrls,
//      this.originalFileNames,
//   });
//
//   factory BillResponse.fromJson(Map<String, dynamic> json) {
//     return BillResponse(
//       id: json['id'],
//       billNumber: json['billNumber'],
//       date: json['date'],
//       receivedDate: json['receivedDate'],
//       invoiceNo: json['invoiceNo'],
//       supplierName: json['supplierName'],
//       customerName: json['customerName'],
//       billAmount: (json['billAmount'] as num).toDouble(),
//       taxableValue: (json['taxableValue'] as num).toDouble(),
//       supplierId: json['supplierId'],
//       supplierGroup: json['supplierGroup'],
//       supplierGstNo: json['supplierGstNo'],
//       supplierMsme: json['supplierMsme'],
//       customerId: json['customerId'],
//       customerGroup: json['customerGroup'],
//       customerGstNo: json['customerGstNo'],
//       customerMsme: json['customerMsme'],
//       transport: json['transport'],
//       lrNumber: json['lrNumber'],
//       remarks: json['remarks'],
//       items: (json['items'] as List)
//           .map((e) => BillItem.fromJson(e))
//           .toList(),
//       objectKeys: json['objectKeys'] ?? [],
//       publicUrls: json['publicUrls'] ?? [],
//       originalFileNames: json['originalFileNames'] ?? [],
//     );
//   }
// }
//
// class ReportingBillItem {
//   final int? pieces;
//   final double? discountPercent;
//   final double? gstPercent;
//   final double? grossAmount;
//   final double? discountAmount;
//   final double? addOnAmount;
//   final double? ecrAmount;
//   final double? gstAmount;
//
//   ReportingBillItem({
//      this.pieces,
//      this.discountPercent,
//     this.gstPercent,
//      this.grossAmount,
//      this.discountAmount,
//      this.addOnAmount,
//      this.ecrAmount,
//      this.gstAmount,
//   });
//
//   factory ReportingBillItem.fromJson(Map<String, dynamic> json) {
//     return ReportingBillItem(
//       pieces: json['pieces'],
//       discountPercent: (json['discountPercent'] as num).toDouble(),
//       gstPercent: (json['gstPercent'] as num).toDouble(),
//       grossAmount: (json['grossAmount'] as num).toDouble(),
//       discountAmount: (json['discountAmount'] as num).toDouble(),
//       addOnAmount: (json['addOnAmount'] as num).toDouble(),
//       ecrAmount: (json['ecrAmount'] as num).toDouble(),
//       gstAmount: (json['gstAmount'] as num).toDouble(),
//     );
//   }
// }