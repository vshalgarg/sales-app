import 'dart:convert';

import 'package:hisabio/model_classes/configuration_model.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class ConfigurationService {

  Future<List<ConfigurationModel>> getConfiguration() async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/admin/configurations",
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
        final List list = data["data"];

        return list
            .map((e) => ConfigurationModel.fromJson(e))
            .toList();
      } else {
        throw Exception(data["message"] ?? "Failed to fetch configuration");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<String> updateConfiguration(bool value) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/admin/configurations/1"
      );

      final token = await AppStorage.getToken();

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "value": value.toString(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data["message"];
      } else {
        throw Exception(data["message"] ?? "Failed to update configuration");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}