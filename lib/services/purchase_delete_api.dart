import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> deletePurchase(int id, String token) async {
  final url = Uri.parse(
    "http://192.168.1.100:8087/csm/api/v1/purchase/entry/delete/$id",
  );

  final response = await http.delete(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data;
  } else {
    throw Exception(data["message"] ?? "Failed to delete purchase");
  }
}