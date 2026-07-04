import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/login_model.dart';
import 'package:hisabio/services/login.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
class LoginProvider extends ChangeNotifier {

  final LoginApi _loginApi = LoginApi();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  LoginModel? userData;

  Future<bool> login({
    required String username,
    required String password,
  }) async {

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {

      final response = await _loginApi.login(
        username,
        password,
      );

      userData = response;
      await  AppStorage.setToken(userData!.token!);
      await AppStorage.setEmail(userData!.username ?? "");
      return true;

    } catch (e) {

      _error = e.toString();

      return false;

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }
}