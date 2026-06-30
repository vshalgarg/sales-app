import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model_classes/retail_deposit_history_model.dart';
import '../shared_preferences/login_token.dart';

Future<List<RetailDepositHistoryModel>> getRetailDepositHistory(
  int retailId,
) async {
  final token = await AppStorage.getToken();

  final response = await http.get(
    Uri.parse("http://192.168.1.100:8087/csm/api/v1/retail/$retailId/deposits"),

    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);

    return (body["data"] as List)
        .map((e) => RetailDepositHistoryModel.fromJson(e))
        .toList();
  }

  throw Exception("Unable to fetch deposit history");
}
