import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../model_classes/search_credit.dart';
import '../shared_preferences/login_token.dart';

Future<SearchCreditResponse> searchCredits({
  String? fromDate,
  String? toDate,
  int? supplierId,
  int? customerId,
  int page = 0,
  int size = 7,
}) async {
  final token = await AppStorage.getToken();

  final queryParams = {
    if (fromDate != null && fromDate.isNotEmpty) "fromDate": fromDate,

    if (toDate != null && toDate.isNotEmpty) "toDate": toDate,

    if (supplierId != null) "supplierId": supplierId.toString(),

    if (customerId != null) "customerId": customerId.toString(),

    "page": page.toString(),
    "size": size.toString(),
  };

  final url = Uri.parse(
    "http://192.168.1.100:8087/csm/api/v1/credit/entries/search",
  ).replace(queryParameters: queryParams);

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  debugPrint("Credit Search Status => ${response.statusCode}");

  debugPrint("Credit Search Response => ${response.body}");

  if (response.statusCode == 200) {
    final data = SearchCreditResponse.fromJson(
      jsonDecode(response.body),
    );
  for (final item in data.content) {
  }

  return data;
}
  throw Exception("Failed to fetch credit entries");
}
