import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model_classes/delete_purchase_model.dart';

Future<DeletePurchaseResponse> deletePurchase(
    int id,
    String token,
    ) async {
  final url = Uri.parse(
    "http://192.168.1.100:8087/csm/api/v1/purchase/entry/delete/$id",
  );

  print("DELETE URL: $url");

  final response = await http.delete(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
  );

  print("STATUS CODE: ${response.statusCode}");
  print("RESPONSE BODY: ${response.body}");

  final responseJson = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return DeletePurchaseResponse.fromJson(responseJson);
  }

  throw Exception(
    responseJson["message"] ?? "Failed to delete purchase",
  );
}