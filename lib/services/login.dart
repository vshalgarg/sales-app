import 'package:hisabio/network/api_service.dart';
import 'package:hisabio/network/response_result.dart';

import '../model_classes/login_model.dart';

class LoginService {
  final ApiService _api;

  LoginService(this._api);

  static const String _login = "/login";

  Future<ResponseResult<LoginModel>> login({
    required String username,
    required String password,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: _login,
      data: {
        "username": username,
        "password": password,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Login failed",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      LoginModel.fromJson(result.data!),
      result.statusCode,
    );
  }
}
