import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const  _tokenKey = "token";

  // SET TOKEN
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // GET TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}