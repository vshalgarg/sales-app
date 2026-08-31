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
  // GET USERS

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

  // SEARCH USERS

  int _searchRequestId = 0;

  Future<bool> searchUsers(String keyword) async {
    final requestId = ++_searchRequestId;

    _errorMessage = null;
    notifyListeners();

    final result = await _service.searchUsers(
      keyword: keyword,
    );

    // Ignore an old response.
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

  // ADD USER

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

  // DELETE USER

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

  // UPDATE PASSWORD

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

  // REFRESH

  Future<void> refresh() async {
    await fetchUsers();
  }

  // CLEAR ERROR

  void clearError() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}