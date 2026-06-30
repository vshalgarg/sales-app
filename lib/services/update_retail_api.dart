import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
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

    final response = await http.put(
      Uri.parse(
        "http//192.168.1.100/csm/api/v1/retail/$retailId",
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

    print("UPDATE RETAIL URL => ${response.request?.url}");
    print("STATUS => ${response.statusCode}");
    print("BODY => ${response.body}");

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception("Failed to update retail");
  }
}