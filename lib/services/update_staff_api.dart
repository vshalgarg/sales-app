import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/update_staff_model.dart';

class UpdateStaffApi{
  Future<UpdateStaffModel> updateStaff({required Map<String, dynamic> body,required int id,}) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/staff/$id");
      final token = await AppStorage.getToken();
      final response = await http.put(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return UpdateStaffModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to update staff");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
