
import 'package:flutter/material.dart';
import 'package:hisabio/services/role/role_service.dart';

import '../../model_classes/role/role_model.dart';

class RoleProvider extends ChangeNotifier {
  final RoleService _service;

  RoleProvider(this._service);

  List<RoleModel> _roles = [];
  List<RoleModel> get roles => _roles;
  List<RolePermission> _permissions = [];
  List<RolePermission> get permissions => _permissions;

  RoleDetails? _roleDetails;
  RoleDetails? get roleDetails => _roleDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _permissionsLoading = false;
  bool get permissionsLoading => _permissionsLoading;

  bool _detailsLoading = false;
  bool get detailsLoading => _detailsLoading;

  bool _actionLoading = false;
  bool get actionLoading => _actionLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchRoles({bool showLoader = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getAllRoles(
        showLoader: showLoader,
      );

      if (result.isSuccess && result.data != null) {
        _roles = result.data!;
      } else {
        _error = result.errorMessage ?? 'Unable to load roles';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchPermissions({bool showLoader = true}) async {
    _permissionsLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getAllPermissions(
        showLoader: showLoader,
      );

      if (result.isSuccess && result.data != null) {
        _permissions = result.data!;
        debugPrint('Provider permissions: ${_permissions.length}');
        return true;
      }

      _error = result.errorMessage ?? 'Unable to load permissions';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _permissionsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchRoleDetails(
      int roleId, {
        bool showLoader = true,
      }) async {
    _detailsLoading = true;
    _roleDetails = null;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getRoleDetails(
        roleId,
        showLoader: showLoader,
      );

      if (result.isSuccess && result.data != null) {
        _roleDetails = result.data!;
        return true;
      }

      _error = result.errorMessage ?? 'Unable to load role details';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _detailsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRole({
    required String roleName,
    String? roleDesc,
    required List<int> permissionIds,
    int? parentRoleId,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.createRole(
        roleName: roleName,
        roleDesc: roleDesc,
        permissionIds: permissionIds,
        parentRoleId: parentRoleId,
      );

      if (result.isSuccess) {
        await fetchRoles();
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRole({
    required int roleId,
    String? roleName,
    String? roleDesc,
    List<int>? permissionIds,
    int? parentRoleId,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updateRole(
        roleId: roleId,
        roleName: roleName,
        roleDesc: roleDesc,
        permissionIds: permissionIds,
        parentRoleId: parentRoleId,
      );

      if (result.isSuccess) {
        await fetchRoles();
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  void clearDetails() {
    _roleDetails = null;
    notifyListeners();
  }
}
