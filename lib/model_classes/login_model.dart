class LoginModel {
  final num? userId;
  final String? username;
  final List<String>? roles;
  final String? token;

  final int? code;
  final String? message;
  final String? timestamp;

  LoginModel({
    this.userId,
    this.username,
    this.roles,
    this.token,
    this.code,
    this.message,
    this.timestamp,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      userId: json['userId'],
      username: json['username'],
      roles: json['roles'] != null
          ? List<String>.from(json['roles'])
          : null,
      token: json['token'],

      code: json['code'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }

  // Helper functions (VERY useful)
  bool get isSuccess => token != null;

  bool get isError => token == null;

}