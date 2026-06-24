import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model_classes/search_bills.dart';
import '../shared_preferences/login_token.dart';

Future<List<BillEntry>> searchBills({
  String? fromDate,
  String? toDate,
  int? supplierId,
  int? customerId,
}) async {
  final queryParams = {
    if (fromDate != null && fromDate.isNotEmpty) "fromDate": fromDate,

    if (toDate != null && toDate.isNotEmpty) "toDate": toDate,

    if (supplierId != null) "supplierId": supplierId.toString(),

    if (customerId != null) "customerId": customerId.toString(),

    "page": "0",
    "size": "20",
  };

  final url = Uri.parse(
    "http://192.168.1.100:8087/csm/api/v1/bill/entries/search",
  ).replace(queryParameters: queryParams);
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
    if (data['code'] == 500) {
      throw Exception(data['message'] ?? "Server Error");
    }

    final List<dynamic> content = (data['content'] as List?) ?? [];
    for (final item in content) {
    }
    return content.map((e) => BillEntry.fromJson(e)).toList();
  }

  throw Exception(data['message'] ?? "Failed to load bills");
}
