import 'dart:convert';

import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/retail_model.dart';

Future<RetailModel> getRetailDetails(int id) async {
  final token = await AppStorage.getToken();

  final response = await http.get(
    Uri.parse("http://192.168.1.100:8087/csm/api/v1/retail/get/$id"),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return RetailModel.fromJson(data["data"]);
  }

  throw Exception("Failed to load retail details");
}
