import 'dart:convert';
import '../shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class UpdateRetailApi {
  Future<bool> updateRetail({
    required int retailId,
    required String name,
    required String date,
    required int referredByCustomerId,
    int? staffId,
  }) async {
    final token = await AppStorage.getToken();
    final url = Uri.parse(
      "http://192.168.1.100:8087/csm/api/v1/retail/$retailId",
    );

    final body = {
      "name": name,
      "date": date,
      "referredByCustomerId": referredByCustomerId,
      "staffId": staffId,
    };

    print("URL: $url");
    print("BODY: ${jsonEncode(body)}");
    final response = await http.put(
      Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/retail/$retailId",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "date": date,
        "referredByCustomerId": referredByCustomerId,
        "staffId": staffId,
      }),
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        "Failed to update retail. "
            "Status: ${response.statusCode}, "
            "Body: ${response.body}",
      );
    }
  }
}