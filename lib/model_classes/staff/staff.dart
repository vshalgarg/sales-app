class Staff {
  final int id;
  final String? staffName;
  final String? phone;
  final String? joiningDate;

  const Staff({
    required this.id,
    this.staffName,
    this.phone,
    this.joiningDate,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['staffId'],
      staffName: json['staffName'],
      phone: json['phone'],
      joiningDate: json['joiningDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': id,
      'staffName': staffName,
      'phone': phone,
      'joiningDate': joiningDate,
    };
  }

  Staff copyWith({
    int? staffId,
    String? staffName,
    String? phone,
    String? joiningDate,
  }) {
    return Staff(
      id: staffId ?? id,
      staffName: staffName ?? this.staffName,
      phone: phone ?? this.phone,
      joiningDate: joiningDate ?? this.joiningDate,
    );
  }
}