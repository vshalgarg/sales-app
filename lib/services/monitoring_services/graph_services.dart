import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../../model_classes/graph_response_model.dart';
class GraphResponseServices {
  Future<GraphResponse > graphResponse({
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/analytics/monthly",
      );
      final token = await AppStorage.getToken();
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return GraphResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch details");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
