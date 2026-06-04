import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;
import '../model_classes/search_transport_model.dart';

class GetSearchTransportApi {
  Future<SearchTransportModel> getSearchTransport(String keyword) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/transports/search?keyword=$keyword&page=0&size=10",
      );
      final token = await AppStorage.getToken();
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return SearchTransportModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to search Transport");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
