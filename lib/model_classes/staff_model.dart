class StaffModel {
  final int staffId;
  final String staffName;
  final String phone;
  final String joiningDate;

  StaffModel({
    required this.staffId,
    required this.staffName,
    required this.phone,
    required this.joiningDate,
  });

  factory StaffModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StaffModel(
      staffId: json['staffId'] ?? 0,
      staffName: json['staffName'] ?? '',
      phone: json['phone'] ?? '',
      joiningDate: json['joiningDate'] ?? '',
    );
  }
}