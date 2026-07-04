class PurchaseEntry {
  final int id;
  final String date;
  final String staffName;
  final String supplierName;
  final String customerName;
  final String remarks;
  final String customerCity;
  final String supplierCity;

  PurchaseEntry({
    required this.id,
    required this.date,
    required this.staffName,
    required this.supplierName,
    required this.customerName,
    required this.remarks,
    required this.customerCity,
    required this.supplierCity,
  });

  factory PurchaseEntry.fromJson(Map<String, dynamic> json) {
    return PurchaseEntry(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      staffName: json['staffName'] ?? '',
      supplierName: json['supplierName'] ?? '',
      customerName: json['customerName'] ?? '',
      remarks: json['remarks'] ?? '',
      customerCity: json['customerCity'] ?? '',
      supplierCity: json['supplierCity'] ?? '',
    );
  }
}

class PurchaseSearchResponse {
  final List<PurchaseEntry> content;
  final int page;
  final int totalPages;
  final bool last;

  PurchaseSearchResponse({
    required this.content,
    required this.page,
    required this.totalPages,
    required this.last,
  });

  factory PurchaseSearchResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseSearchResponse(
      content: (json['content'] as List)
          .map((e) => PurchaseEntry.fromJson(e))
          .toList(),
      page: json['page'] ?? json['number'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      last: json['last'] ?? false,
    );
  }
}
