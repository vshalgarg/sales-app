import 'package:flutter/material.dart';

import '../../model_classes/user/add_user_request.dart';
import '../../model_classes/user/user.dart';
import '../../services/user/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service;

  UserProvider(this._service);

  List<User> _users = [];
  String? _errorMessage;

  List<User> get users => _users;
  String? get errorMessage => _errorMessage;
  String? _successMessage;

  String? get successMessage => _successMessage;

  Future<bool> fetchUsers() async {
    _errorMessage = null;
    notifyListeners();

    final result = await _service.getUsers();

    if (result.isSuccess) {
      _users = result.data ?? [];
      notifyListeners();
      return true;
    }

    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  int _searchRequestId = 0;

  Future<bool> searchUsers(String keyword) async {
    final requestId = ++_searchRequestId;

    _errorMessage = null;
    notifyListeners();

    final result = await _service.searchUsers(
      keyword: keyword,
    );
    if (requestId != _searchRequestId) {
      return false;
    }

    if (result.isSuccess) {
      _users = result.data ?? [];
      notifyListeners();
      return true;
    }

    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  Future<bool> addUser(AddUserRequest request) async {
    _errorMessage = null;
    _successMessage = null;

    final result = await _service.addUser(request);

    if (result.isSuccess) {
      _successMessage = result.data?.message;

      await fetchUsers();

      return true;
    }

    _errorMessage = result.errorMessage;
    notifyListeners();

    return false;
  }

  Future<bool> deleteUser(int id) async {
    final result = await _service.deleteUser(id);

    if (result.isSuccess) {
      await fetchUsers();
      return true;
    }

    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  Future<bool> updatePassword({
    required Map<String, dynamic> body,
  }) async {
    final result = await _service.updatePassword(body: body);

    if (result.isSuccess) {
      return true;
    }

    _errorMessage = result.errorMessage;
    notifyListeners();
    return false;
  }

  // FETCH USER ROLES
  Future<List<String>?> fetchUserRoles(int userId) async {
    _errorMessage = null;

    try {
      final result = await _service.getUserWithRoles(userId);

      if (result.isSuccess && result.data != null) {
        final roles = result.data!['roles'];

        if (roles is List) {
          return roles.map((e) => e.toString()).toList();
        }

        return [];
      }

      _errorMessage = result.errorMessage ?? 'Unable to fetch user roles';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

// UPDATE USER ROLES
  Future<bool> updateUserRoles({
    required int userId,
    required List<String> roleNames,
  }) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.updateUserRoles(
        userId: userId,
        roleNames: roleNames,
      );

      if (result.isSuccess) {
        _successMessage =
            result.data?['message']?.toString() ??
                'User roles updated successfully';

        await fetchUsers();
        return true;
      }

      _errorMessage = result.errorMessage ?? 'Failed to update user roles';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await fetchUsers();
  }

  void clearError() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}