class AddStaffRequest {
  final String staffName;
  final String phone;
  final String joiningDate;

  const AddStaffRequest({
    required this.staffName,
    required this.phone,
    required this.joiningDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "staffName": staffName,
      "phone": phone,
      "joiningDate": joiningDate,
    };
  }

  factory AddStaffRequest.fromJson(Map<String, dynamic> json) {
    return AddStaffRequest(
      staffName: json["staffName"] ?? "",
      phone: json["phone"] ?? "",
      joiningDate: json["joiningDate"] ?? "",
    );
  }

  AddStaffRequest copyWith({
    String? staffName,
    String? phone,
    String? joiningDate,
  }) {
    return AddStaffRequest(
      staffName: staffName ?? this.staffName,
      phone: phone ?? this.phone,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}