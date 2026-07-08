import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/get_transport_by_id.dart';

class GetTransportByIdApi {
  Future<GetTransportById> getTransportById(int id) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/transports/$id");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return GetTransportById.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch transport");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
