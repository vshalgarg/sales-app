import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../shared_preferences/login_token.dart';
import 'auth.dart';

class AuthManager with WidgetsBindingObserver {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() => _instance;

  AuthManager._internal();

  Timer? _expiryTimer;

  GlobalKey<NavigatorState>? _navigatorKey;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    WidgetsBinding.instance.addObserver(this);

    checkToken();
  }

  Future<void> checkToken() async {
    final isValid = await AuthService.isTokenValid();

    if (!isValid) {
      await logout();
      return;
    }

    await _scheduleTokenExpiry();
  }

  Future<void> _scheduleTokenExpiry() async {
    _expiryTimer?.cancel();

    try {
      final token = await AppStorage.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      final expiryDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();

      final duration = expiryDate.difference(now);

      if (duration.isNegative || duration == Duration.zero) {
        await logout();
        return;
      }

      _expiryTimer = Timer(duration, () async {
        await logout();
      });
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    _expiryTimer?.cancel();
    _expiryTimer = null;

    // Use your actual AppStorage token delete method here.
    await AppStorage.clear();

    final navigator = _navigatorKey?.currentState;

    if (navigator == null) {
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      '/login',
          (route) => false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkToken();
    }
  }

  void dispose() {
    _expiryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}