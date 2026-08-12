class BankDetailRequest {
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? branchName;
  final String? accountName;

  const BankDetailRequest({
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.branchName,
    this.accountName,
  });

  factory BankDetailRequest.fromJson(Map<String, dynamic> json) {
    return BankDetailRequest(
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      ifscCode: json['ifscCode'],
      branchName: json['branchName'],
      accountName: json['accountName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'accountName': accountName,
    };
  }

  BankDetailRequest copyWith({
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? branchName,
    String? accountName,
  }) {
    return BankDetailRequest(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      accountName: accountName ?? this.accountName,
    );
  }
}