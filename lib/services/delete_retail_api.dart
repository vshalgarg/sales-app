import 'dart:convert';
import 'package:http/http.dart' as http;

import '../shared_preferences/login_token.dart';

class DeleteRetailApi {
  Future<bool> deleteRetail(int retailId) async {
    final token = await AppStorage.getToken();

    final response = await http.delete(
      Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/retail/$retailId",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print("Delete Retail Status : ${response.statusCode}");
    print("Delete Retail Response : ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["success"] == true;
    }

    return false;
  }
}