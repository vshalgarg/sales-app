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