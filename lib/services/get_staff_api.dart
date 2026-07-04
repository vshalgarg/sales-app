import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/get_staff_details_model.dart';

class GetStaffApi {
  Future<GetStaffDetailsModel> getStaff({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/staffs/get?page=0&size=10");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return GetStaffDetailsModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch staff");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
