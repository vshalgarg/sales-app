
class RoleModel {
  final int id;
  final String roleName;
  final String? roleDesc;

  RoleModel({
    required this.id,
    required this.roleName,
    this.roleDesc,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: (json['id'] as num).toInt(),
      roleName: json['roleName']?.toString() ?? '',
      roleDesc: json['roleDesc']?.toString(),
    );
  }
}

class RolePermission {
  final int id;
  final String name;
  final String? description;

  RolePermission({
    required this.id,
    required this.name,
    this.description,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      description: json['desc']?.toString(),
    );
  }
}

class RoleDetails {
  final String roleName;
  final String? roleDesc;
  final int? parentRoleId;
  final String? parentRoleName;
  final List<RolePermission> permissions;

  RoleDetails({
    required this.roleName,
    this.roleDesc,
    this.parentRoleId,
    this.parentRoleName,
    required this.permissions,
  });

  factory RoleDetails.fromJson(Map<String, dynamic> json) {
    return RoleDetails(
      roleName: json['roleName']?.toString() ?? '',
      roleDesc: json['roleDesc']?.toString(),
      parentRoleId: json['parentRoleId'] == null
          ? null
          : (json['parentRoleId'] as num).toInt(),
      parentRoleName: json['parentRoleName']?.toString(),
      permissions: (json['permissions'] as List? ?? [])
          .map((e) => RolePermission.fromJson(
          Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
