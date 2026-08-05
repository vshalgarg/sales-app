class UserDetails {
  final int? id;
  final String? username;

  const UserDetails({
    this.id,
    this.username,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'] as int?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }

  UserDetails copyWith({
    int? id,
    String? username,
  }) {
    return UserDetails(
      id: id ?? this.id,
      username: username ?? this.username,
    );
  }
}