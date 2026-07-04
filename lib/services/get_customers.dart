import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class GetCustomersApi {
  Future<dynamic> getCustomers({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final token = await AppStorage.getToken();

      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/customers/get",
      ).replace(
        queryParameters: {
          "page": "$page",
          "size": "$size",
        },
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
