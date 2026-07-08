import 'dart:convert';
import 'package:http/http.dart' as http;

import '../shared_preferences/login_token.dart';

Future<Map<String, dynamic>> getBillDetails(String billNumber) async {
  final token = await AppStorage.getToken();

  final response = await http.get(
    Uri.parse("http://192.168.1.100:8087/csm/api/v1/bill/$billNumber"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {

    return jsonDecode(response.body);
  }

  throw Exception("Failed to load bill details");
}
