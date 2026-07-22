class PurchaseDetailsResponse {
  final bool success;
  final String message;
  final PurchaseDetails? data;

  PurchaseDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PurchaseDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? PurchaseDetails.fromJson(json['data'])
          : null,
    );
  }
}

class PurchaseDetails {
  final int id;
  final String date;
  final int staffId;
  final String staffName;
  final int customerId;
  final String customerName;
  final String remarks;
  final SupplierPurchaseDetail supplier;

  PurchaseDetails({
    required this.id,
    required this.date,
    required this.staffId,
    required this.staffName,
    required this.customerId,
    required this.customerName,
    required this.remarks,
    required this.supplier,
  });

  factory PurchaseDetails.fromJson(Map<String, dynamic> json) {
    return PurchaseDetails(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      staffId: json['staffId'] ?? 0,
      staffName: json['staffName'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      remarks: json['remarks'] ?? '',
      supplier: SupplierPurchaseDetail.fromJson(
        json['supplier'] ?? {},
      ),
    );
  }
}

class SupplierPurchaseDetail {
  final int supplierId;
  final String supplierName;
  final List<PurchaseImage> images;

  SupplierPurchaseDetail({
    required this.supplierId,
    required this.supplierName,
    required this.images,
  });

  factory SupplierPurchaseDetail.fromJson(Map<String, dynamic> json) {
    return SupplierPurchaseDetail(
      supplierId: json['supplierId'] ?? 0,
      supplierName: json['supplierName'] ?? '',
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => PurchaseImage.fromJson(e))
          .toList(),
    );
  }
}

class PurchaseImage {
  final String key;
  final String url;
  final String fileName;

  PurchaseImage({
    required this.key,
    required this.url,
    required this.fileName,
  });

  factory PurchaseImage.fromJson(Map<String, dynamic> json) {
    return PurchaseImage(
      key: json['key'] ?? '',
      url: json['url'] ?? '',
      fileName: json['fileName'] ?? '',
    );
  }
}