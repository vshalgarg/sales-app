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



// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:hisabio/model_classes/login_model.dart';
// import 'package:http/http.dart' as http;
// class LoginApi {
//   Future< LoginModel> login(String username, String password) async {
//     try{
//
//       final url = Uri.parse('$baseUrl/login');
//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"username": username, "password": password}),
//     );
//
//     var data =jsonDecode(response.body);
//
//
//     if (response.statusCode == 200) {
//       return  LoginModel.fromJson(data);
//     } else {
//       throw Exception(data['message']??"Login Failed");
//     }}
//     catch (e){
//       debugPrint("Login Error => $e");
//       rethrow;
//     }
//   }
// }
