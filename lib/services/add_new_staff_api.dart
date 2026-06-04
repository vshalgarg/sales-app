import 'dart:convert';

import 'package:hisabio/model_classes/add_newsupplier.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class AddNewStaffApi {
  Future<AddNewsupplier> addNewStaff(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/staff/add");
      final token = await AppStorage.getToken();
      final response = await http.post(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AddNewsupplier.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to add new staff");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
