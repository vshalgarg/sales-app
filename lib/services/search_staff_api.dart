import 'dart:convert';
import 'package:hisabio/model_classes/search_supplier.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/search_staff_model.dart';

class GetSearchStaffApi {
  Future<SearchStaffModel> getSearchStaff(String keyword) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/staffs/search?keyword=$keyword&page=0&size=10",
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
        return SearchStaffModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to search Staff");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
