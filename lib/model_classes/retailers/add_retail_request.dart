class AddRetailRequest {
  final String name;
  final String date;
  final int referredByCustomerId;
  final int? staffId;

  AddRetailRequest({
    required this.name,
    required this.date,
    required this.referredByCustomerId,
    this.staffId,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "date": date,
      "referredByCustomerId": referredByCustomerId,
      "staffId": staffId,
    };
  }
}