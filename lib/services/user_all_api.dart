import 'dart:convert';

import 'package:hisabio/model_classes/add_newuser_model.dart';
import 'package:http/http.dart' as http;

import '../model_classes/delete_user_model.dart';
import '../model_classes/onUpdate_Password.dart';
import '../shared_preferences/login_token.dart';

class UserServices{
  Future<AddNewuserModel> addNewUser(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/user/add");
      final token = await AppStorage.getToken();
      final response = await http.post(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AddNewuserModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to add new user");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<DeleteUserModel> deleteUser(int id) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/user/delete/$id");
      final token = await AppStorage.getToken();
      final response = await http.post(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return DeleteUserModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to delete user");
      }
    } catch (e) {
      throw Exception("Error $e");

    }
  }
  Future getSearchUser(String keyword) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/users/search?keyword=$keyword",
      );
      final token = await AppStorage.getToken();
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? "Failed to search users");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<OnUpdatePassword> updateStaff({required Map<String, dynamic> body,}) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/admin/change/password");
      final token = await AppStorage.getToken();
      final response = await http.put(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return OnUpdatePassword.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to update password");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}