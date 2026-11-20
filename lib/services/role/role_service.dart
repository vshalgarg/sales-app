
import 'package:flutter/cupertino.dart';
import 'package:hisabio/network/api_service.dart';
import 'package:hisabio/network/response_result.dart';

import '../../model_classes/role/role_model.dart';

class RoleService {
  final ApiService _api;

  RoleService(this._api);

  static const String _basePath = '/role';

  // GET ALL ROLES
  Future<ResponseResult<List<RoleModel>>> getAllRoles() async {
    final result = await _api.get<List<dynamic>>(
      path: '$_basePath/get/all',
    );

    if (result.isFailure || result.data == null) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? 'Failed to fetch roles',
        statusCode: result.statusCode,
      );
    }

    final roles = result.data!
        .map((e) => RoleModel.fromJson(
      Map<String, dynamic>.from(e),
    ))
        .toList();

    return ResponseResult.success(roles, result.statusCode);
  }

  // GET ROLE DETAILS
  Future<ResponseResult<RoleDetails>> getRoleDetails(int roleId) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: '$_basePath/detail/get/$roleId',
    );

    if (result.isFailure || result.data == null) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? 'Failed to fetch role details',
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      RoleDetails.fromJson(result.data!),
      result.statusCode,
    );
  }

  // CREATE ROLE
  Future<ResponseResult<Map<String, dynamic>>> createRole({
    required String roleName,
    String? roleDesc,
    required List<int> permissionIds,
    int? parentRoleId,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: '$_basePath/create',
      data: {
        'roleName': roleName,
        'roleDesc': roleDesc,
        'permissionIds': permissionIds,
        'parentRoleId': parentRoleId,
      },
    );

    if (result.isFailure || result.data == null) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? 'Failed to create role',
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(result.data!, result.statusCode);
  }

  // UPDATE ROLE
  Future<ResponseResult<Map<String, dynamic>>> updateRole({
    required int roleId,
    String? roleName,
    String? roleDesc,
    List<int>? permissionIds,
    int? parentRoleId,
  }) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: '$_basePath/update/$roleId',
      data: {
        'roleName': roleName,
        'roleDesc': roleDesc,
        'permissionIds': permissionIds,
        'parentRoleId': parentRoleId,
      },
    );

    if (result.isFailure || result.data == null) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? 'Failed to update role',
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(result.data!, result.statusCode);
  }

  // GET ALL PERMISSIONS
  Future<ResponseResult<List<RolePermission>>> getAllPermissions() async {
    debugPrint('========== GET ALL PERMISSIONS ==========');

    final result = await _api.get<List<dynamic>>(
      path: '/permission/all',
    );

    debugPrint('Permission API success: ${result.isSuccess}');
    debugPrint('Permission API failure: ${result.isFailure}');
    debugPrint('Permission API status: ${result.statusCode}');
    debugPrint('Permission API error: ${result.errorMessage}');
    debugPrint('Permission API data: ${result.data}');

    if (result.isFailure || result.data == null) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? 'Failed to fetch permissions',
        statusCode: result.statusCode,
      );
    }

    final permissions = result.data!
        .map(
          (e) => RolePermission.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();

    debugPrint('Parsed permissions count: ${permissions.length}');

    return ResponseResult.success(permissions, result.statusCode);
  }

  // DELETE ROLE
  Future<ResponseResult<Map<String, dynamic>>> deleteRole(
      int roleId) async {
    final result = await _api.delete<Map<String, dynamic>>(
      path: '$_basePath/delete/$roleId',
    );

    if (result.isFailure || result.data == null) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? 'Failed to delete role',
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(result.data!, result.statusCode);
  }
}
