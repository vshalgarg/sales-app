import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model_classes/staff_model.dart';
import '../shared_preferences/login_token.dart';

class GetAllStaffApi {
  Future<List<StaffModel>> getStaffs() async {
    final token = await AppStorage.getToken();

    final response = await http.get(
      Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/staffs/get/all",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => StaffModel.fromJson(e))
          .toList();
    }

    throw Exception(
      "Failed to fetch staff list",
    );
  }
}