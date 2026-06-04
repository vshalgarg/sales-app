import 'package:flutter/material.dart';
import '../model_classes/get_users.dart';
import '../services/get_users_api.dart';

class GetUsersProvider
    extends ChangeNotifier {

  final GetUsersApi _api =
  GetUsersApi();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  GetUsers? _users;

  GetUsers? get users => _users;

  String? _error;

  String? get error => _error;

  Future<void> getUsers() async {

    _isLoading = true;

    _error = null;

    notifyListeners();

    try {

      final result =
      await _api.getUsers();

      _users = result;

    } catch (e) {

      _error = e.toString();

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }

  void clearUsers() {

    _users = null;

    notifyListeners();
  }
}