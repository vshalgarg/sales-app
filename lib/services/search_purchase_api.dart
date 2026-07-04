import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model_classes/search_purchase.dart';
import '../shared_preferences/login_token.dart';

Future<PurchaseSearchResponse> searchPurchaseEntries({
  String? fromDate,
  String? toDate,
  int? supplierId,
  int? customerId,
  int? staffId,
  int page = 0,
  int size = 20,
}) async {
  final token = await AppStorage.getToken();

  final queryParams = {
    if (fromDate != null && fromDate.isNotEmpty) "fromDate": fromDate,
    if (toDate != null && toDate.isNotEmpty) "toDate": toDate,
    if (supplierId != null) "supplierId": supplierId.toString(),
    if (customerId != null) "customerId": customerId.toString(),
    if (staffId != null) "staffId": staffId.toString(),
    "page": page.toString(),
    "size": size.toString(),
  };

  final uri = Uri.http(
    "192.168.1.100:8087",
    "/csm/api/v1/purchase/entries/search",
    queryParams,
  );

  final response = await http.get(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    return PurchaseSearchResponse.fromJson(jsonDecode(response.body));
  }

  throw Exception("Failed to search purchase entries: ${response.statusCode}");
}
