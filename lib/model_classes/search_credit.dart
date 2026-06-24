class SearchCreditResponse {
  final List<SearchCreditEntry> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  SearchCreditResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory SearchCreditResponse.fromJson(
      Map<String, dynamic> json) {
    return SearchCreditResponse(
      content: (json['content'] as List?)
          ?.map(
            (e) => SearchCreditEntry.fromJson(e),
      )
          .toList() ??
          [],
      page: json['page'] ?? 0,
      size: json['size'] ?? 0,
      totalElements:
      json['totalElements'] ?? 0,
      totalPages:
      json['totalPages'] ?? 0,
      last: json['last'] ?? false,
    );
  }
}
class SearchCreditEntry {
  final int? id;
  final String? paymentType;
  final String? billNumber;
  final String? date;
  final String? referenceNumber;
  final String? referenceDate;
  final double? receivedAmount;
  final String? supplierName;
  final String? customerName;
  final String? slipNumber;
  final String? drawType;
  final String? remark;
  final int? supplierId;
  final int? customerId;
  final String? supplierCity;
  final String? customerCity;

  SearchCreditEntry({
    this.id,
    this.paymentType,
    this.billNumber,
    this.date,
    this.referenceNumber,
    this.referenceDate,
    this.receivedAmount,
    this.supplierName,
    this.customerName,
    this.slipNumber,
    this.drawType,
    this.remark,
    this.supplierId,
    this.customerId,
    this.supplierCity,
    this.customerCity,
  });

  factory SearchCreditEntry.fromJson(
      Map<String, dynamic> json) {
    return SearchCreditEntry(
      id: json['id'],
      paymentType: json['paymentType'],
      billNumber: json['billNumber'],
      date: json['date'],
      referenceNumber:
      json['referenceNumber'],
      referenceDate:
      json['referenceDate'],
      receivedAmount:
      json['receivedAmount'] == null
          ? null
          : double.tryParse(
        json['receivedAmount']
            .toString(),
      ),
      supplierName:
      json['supplierName'],
      customerName:
      json['customerName'],
      slipNumber: json['slipNumber'],
      drawType: json['drawType'],
      remark: json['remark'],
      supplierId: json['supplierId'],
      customerId: json['customerId'],
      supplierCity:
      json['supplierCity'],
      customerCity:
      json['customerCity'],
    );
  }
}