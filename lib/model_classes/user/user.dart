class User {
  final int? id;
  final String? username;
  final String? role;
  const User({
    this.id,
    this.username,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int?,
      username: json['username'] as String?,
      role: (json['roles'] as List?)?.join(", ") ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role : role ?? this.role
    );
  }
}