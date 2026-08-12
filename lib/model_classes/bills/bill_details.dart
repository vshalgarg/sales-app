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