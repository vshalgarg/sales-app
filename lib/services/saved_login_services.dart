
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SavedLoginService {
  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _accountsKey = 'hisabio_saved_accounts';
  static const String _lastUsernameKey = 'hisabio_last_username';

  // Get all saved accounts
  static Future<Map<String, String>> getSavedAccounts() async {
    final data = await _storage.read(key: _accountsKey);

    if (data == null || data.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;

      return decoded.map(
            (key, value) => MapEntry(key, value.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  // Save username and password
  static Future<void> saveLogin({
    required String username,
    required String password,
  }) async {
    final accounts = await getSavedAccounts();

    accounts[username] = password;

    await _storage.write(
      key: _accountsKey,
      value: jsonEncode(accounts),
    );

    await _storage.write(
      key: _lastUsernameKey,
      value: username,
    );
  }

  // Get last logged-in username
  static Future<String?> getLastUsername() async {
    return await _storage.read(key: _lastUsernameKey);
  }

  // Get last logged-in credentials
  static Future<Map<String, String>?> getLastLogin() async {
    final username = await getLastUsername();

    if (username == null) return null;

    final accounts = await getSavedAccounts();

    final password = accounts[username];

    if (password == null) return null;

    return {
      'username': username,
      'password': password,
    };
  }

  // Remove a saved account
  static Future<void> removeLogin(String username) async {
    final accounts = await getSavedAccounts();

    accounts.remove(username);

    if (accounts.isEmpty) {
      await _storage.delete(key: _accountsKey);
      await _storage.delete(key: _lastUsernameKey);
      return;
    }

    await _storage.write(
      key: _accountsKey,
      value: jsonEncode(accounts),
    );

    final lastUsername = await getLastUsername();

    if (lastUsername == username) {
      await _storage.write(
        key: _lastUsernameKey,
        value: accounts.keys.last,
      );
    }
  }
}
