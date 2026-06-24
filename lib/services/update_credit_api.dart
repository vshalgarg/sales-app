import 'dart:convert';
import 'package:http/http.dart' as http;

import '../shared_preferences/login_token.dart';

Future<void> updateCredit({
  required int id,
  required String date,
  required int supplierId,
  int? customerId,
  required String paymentType,
  String? referenceNumber,
  String? referenceDate,
  String? slipNumber,
  String? drawType,
  required double receivedAmount,
  String? remark,
}) async {
  final token = await AppStorage.getToken();

  final url = Uri.parse(
    "http://192.168.1.100:8087/csm/api/v1/credit/entry/update/$id",
  );

  final body = {
    "date": date,
    "supplierId": supplierId,
    "customerId": customerId,
    "paymentType": paymentType,
    "referenceNumber": referenceNumber?.trim().isEmpty ?? true
        ? null
        : referenceNumber,
    "referenceDate": referenceDate?.trim().isEmpty ?? true
        ? null
        : referenceDate,
    "slipNumber": slipNumber?.trim().isEmpty ?? true ? null : slipNumber,
    "drawType": drawType,
    "receivedAmount": receivedAmount,
    "remark": remark?.trim().isEmpty ?? true ? null : remark,
  };
  print("Update Credit URL => $url");
  print("Update Credit Body => ${jsonEncode(body)}");


  final response = await http.patch(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(body),
  );

  print("Update Credit Status => ${response.statusCode}");

  print("Update Credit Response => ${response.body}");

  Map<String, dynamic>? responseData;

  try {
    responseData = jsonDecode(response.body);
  } catch (_) {}

  if (response.statusCode == 200) {
    if (responseData != null && responseData["code"] == 500) {
      print("SERVER ERROR => ${responseData["message"]}");
      throw Exception(responseData["message"]);
    }

    return;
  }

  throw Exception(responseData?["message"] ?? "Failed to update credit");
}
