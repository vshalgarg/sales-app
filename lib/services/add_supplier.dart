import 'dart:convert';
import 'package:http/http.dart' as http;

import '../shared_preferences/login_token.dart';

class AddSupplierApi {
  Future<String> addSupplier(Map<String, dynamic> body) async {
    final token = await AppStorage.getToken();

    final response = await http.post(
      Uri.parse("http://192.168.1.100:8087/csm/api/v1/retail-suppliers"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data["success"] == true) {
      return data["message"];
    } else {
      throw Exception(data["message"] ?? "Failed to add supplier");
    }
  }
}