class StaffDetails {
  final int? staffId;
  final String? staffName;
  final String? phone;
  final String? joiningDate;

  const StaffDetails({
    this.staffId,
    this.staffName,
    this.phone,
    this.joiningDate,
  });

  factory StaffDetails.fromJson(Map<String, dynamic> json) {
    return StaffDetails(
      staffId: json['staffId'],
      staffName: json['staffName'],
      phone: json['phone'],
      joiningDate: json['joiningDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'staffName': staffName,
      'phone': phone,
      'joiningDate': joiningDate,
    };
  }

  StaffDetails copyWith({
    int? staffId,
    String? staffName,
    String? phone,
    String? joiningDate,
  }) {
    return StaffDetails(
      staffId: staffId ?? this.staffId,
      staffName: staffName ?? this.staffName,
      phone: phone ?? this.phone,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}