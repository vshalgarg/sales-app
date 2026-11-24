import 'package:flutter/material.dart';

import '../../model_classes/user/add_user_request.dart';
import '../../model_classes/user/user.dart';
import '../../services/user/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _service;

  UserProvider(this._service);

  List<User> _users = [];
  String? _errorMessage;
  String? _successMessage;

  // A shared request ID prevents an older search response from replacing
  // the result of a newer search or a fetchUsers() call.
  int _requestId = 0;

  List<User> get users => _users;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // FETCH ALL USERS.
  // Pagination remains client-side: LocalPaginationWidget divides this list
  // into pages of 10 without changing the existing API.
  Future<bool> fetchUsers({bool showLoader = true}) async {
    final requestId = ++_requestId;

    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getUsers(showLoader: showLoader);

      if (requestId != _requestId) return false;

      if (result.isSuccess) {
        _users = result.data ?? [];
        notifyListeners();
        return true;
      }

      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    } catch (e) {
      if (requestId == _requestId) {
        _errorMessage = e.toString();
        notifyListeners();
      }
      return false;
    }
  }

  // SEARCH USERS.
  // The existing keyword-only search API is preserved.
  // SEARCH USERS
  Future<bool> searchUsers(
      String keyword, {
        bool showLoader = true,
      }) async {
    final requestId = ++_requestId;

    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.searchUsers(
        keyword: keyword,
        showLoader: showLoader,
      );

      if (requestId != _requestId) return false;

      if (result.isSuccess) {
        _users = result.data ?? [];
        notifyListeners();
        return true;
      }

      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    } catch (e) {
      if (requestId == _requestId) {
        _errorMessage = e.toString();
        notifyListeners();
      }
      return false;
    }
  }

  // ADD USER.
  Future<bool> addUser(AddUserRequest request) async {
    _errorMessage = null;
    _successMessage = null;

    try {
      final result = await _service.addUser(request);

      if (result.isSuccess) {
        _successMessage = result.data?.message;
        await fetchUsers();
        return true;
      }

      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // DELETE USER.
  Future<bool> deleteUser(int id) async {
    _errorMessage = null;

    try {
      final result = await _service.deleteUser(id);

      if (result.isSuccess) {
        await fetchUsers();
        return true;
      }

      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // UPDATE PASSWORD.
  Future<bool> updatePassword({
    required Map<String, dynamic> body,
  }) async {
    try {
      final result = await _service.updatePassword(body: body);

      if (result.isSuccess) return true;

      _errorMessage = result.errorMessage;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // FETCH USER ROLES.
  Future<List<String>?> fetchUserRoles(
      int userId, {
        bool showLoader = true,
      }) async {
    _errorMessage = null;

    try {
      final result = await _service.getUserWithRoles(
        userId,
        showLoader: showLoader,
      );

      if (result.isSuccess && result.data != null) {
        final roles = result.data!['roles'];

        if (roles is List) {
          return roles.map((e) {
            if (e is Map) {
              return (e['roleName'] ?? e['name'] ?? '').toString().trim();
            }
            return e.toString().trim();
          }).where((role) => role.isNotEmpty).toList();
        }

        return [];
      }

      _errorMessage = result.errorMessage ?? 'Unable to fetch user roles';
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    }
  }

  // UPDATE USER ROLES.
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
        _successMessage = result.data?['message']?.toString() ??
            'User roles updated successfully';

        await fetchUsers(showLoader: false);
        return true;
      }

      _errorMessage =
          result.errorMessage ?? 'Failed to update user roles';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // REFRESH.
  Future<void> refresh() async {
    await fetchUsers();
  }

  // CLEAR ERRORS / MESSAGES.
  void clearError() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
