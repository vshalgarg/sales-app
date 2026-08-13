import 'package:jwt_decoder/jwt_decoder.dart';
import '../shared_preferences/login_token.dart';

class AuthService {
  static Future<bool> isTokenValid() async {
    try {
      final token = await AppStorage.getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }
}