class PurchaseDetails {
  final num? id;
  final String? date;
  final num? staffId;
  final String? staffName;
  final num? customerId;
  final String? customerName;
  final String? remarks;
  final PurchaseSupplier? supplier;

  PurchaseDetails({
    this.id,
    this.date,
    this.staffId,
    this.staffName,
    this.customerId,
    this.customerName,
    this.remarks,
    this.supplier,
  });

  factory PurchaseDetails.fromJson(Map<String, dynamic> json) {
    return PurchaseDetails(
      id: json["id"],
      date: json["date"],
      staffId: json["staffId"],
      staffName: json["staffName"],
      customerId: json["customerId"],
      customerName: json["customerName"],
      remarks: json["remarks"],
      supplier: json["supplier"] != null
          ? PurchaseSupplier.fromJson(json["supplier"])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date,
      "staffId": staffId,
      "staffName": staffName,
      "customerId": customerId,
      "customerName": customerName,
      "remarks": remarks,
      "supplier": supplier?.toJson(),
    };
  }
}

class PurchaseSupplier {
  final num? supplierId;
  final String? supplierName;
  final List<PurchaseImage> images;

  PurchaseSupplier({
    this.supplierId,
    this.supplierName,
    required this.images,
  });

  factory PurchaseSupplier.fromJson(Map<String, dynamic> json) {
    return PurchaseSupplier(
      supplierId: json["supplierId"],
      supplierName: json["supplierName"],
      images: (json["images"] as List<dynamic>? ?? [])
          .map((e) => PurchaseImage.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "supplierId": supplierId,
      "supplierName": supplierName,
      "images": images.map((e) => e.toJson()).toList(),
    };
  }
}

class PurchaseImage {
  final String? key;
  final String? url;
  final String? fileName;

  PurchaseImage({
    this.key,
    this.url,
    this.fileName,
  });

  factory PurchaseImage.fromJson(Map<String, dynamic> json) {
    return PurchaseImage(
      key: json["key"],
      url: json["url"],
      fileName: json["fileName"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "url": url,
      "fileName": fileName,
    };
  }
}