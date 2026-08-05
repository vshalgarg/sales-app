class AddUserRequest {
  final String username;
  final String password;
  final List<String> roles;

  const AddUserRequest({
    required this.username,
    required this.password,
    required this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
      "roles": roles,
    };
  }

  AddUserRequest copyWith({
    String? username,
    String? password,
    List<String>? roles,
  }) {
    return AddUserRequest(
      username: username ?? this.username,
      password: password ?? this.password,
      roles: roles ?? this.roles,
    );
  }
}