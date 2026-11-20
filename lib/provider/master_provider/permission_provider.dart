import 'package:flutter/material.dart';

class PermissionProvider extends ChangeNotifier {
  Set<String> _permissions = {};

  Set<String> get permissions => _permissions;

  void setPermissions(List<dynamic> permissions) {
    _permissions = permissions.map((e) {
      String permission = e.toString().trim();

      // Remove PERM_ prefix if present.
      if (permission.startsWith('PERM_')) {
        permission = permission.substring(5);
      }

      return permission;
    }).toSet();

    debugPrint('========== PERMISSIONS LOADED ==========');
    debugPrint('Permissions: $_permissions');
    debugPrint('Customer View: ${canView('CUSTOMER')}');
    debugPrint('Purchase Report View: ${canView('PURCHASE_REPORT')}');
    debugPrint('Ledger Report View: ${canView('LEDGER_REPORT')}');
    debugPrint('========================================');

    notifyListeners();
  }

  bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }

  bool canAccessModule(String module) {
    return hasPermission('${module}_VIEW') ||
        hasPermission('${module}_CREATE');
  }

  bool canView(String module) => hasPermission('${module}_VIEW');

  bool canCreate(String module) => hasPermission('${module}_CREATE');

  bool canUpdate(String module) => hasPermission('${module}_UPDATE');

  bool canDelete(String module) => hasPermission('${module}_DELETE');

  void clearPermissions() {
    _permissions.clear();
    notifyListeners();
  }
}