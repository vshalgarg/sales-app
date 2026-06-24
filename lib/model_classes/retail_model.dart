class RetailModel {
  final int id;
  final String name;
  final String date;
  final int customerId;
  final String customerName;
  final int staffId;
  final String staffName;

  RetailModel({
    required this.id,
    required this.name,
    required this.date,
    required this.customerId,
    required this.customerName,
    required this.staffId,
    required this.staffName,
  });

  factory RetailModel.fromJson(Map<String, dynamic> json) {
    return RetailModel(
      id: json['retailId'] ?? 0,
      name: json['retailName'] ?? '',
      date: json['date'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerName: json['referredByCustomerName'] ?? '',
      staffId: json['staffId'] ?? 0,
      staffName: json['staffName'] ?? '',
    );
  }
}