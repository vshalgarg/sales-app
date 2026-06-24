import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared_preferences/login_token.dart';

Future<Map<String, dynamic>> getPurchaseDetails(
    int id,
    ) async {
  final token = await AppStorage.getToken();

  final response = await http.get(
    Uri.parse(
      "http://192.168.1.100:8087/csm/api/v1/purchase/get/details/$id",
    ),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    "Failed to fetch purchase details",
  );
}