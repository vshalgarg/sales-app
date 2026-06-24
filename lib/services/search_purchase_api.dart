import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model_classes/search_purchase.dart';
import '../shared_preferences/login_token.dart';

Future<List<PurchaseEntry>> searchPurchaseEntries({
  String? fromDate,
  String? toDate,
  int? supplierId,
  int? customerId,
  int? staffId,
  int page = 0,
  int size = 7,
}) async {
  final token = await AppStorage.getToken();

  final queryParams = {
    if (fromDate != null && fromDate.isNotEmpty)
      "fromDate": fromDate,

    if (toDate != null && toDate.isNotEmpty)
      "toDate": toDate,

    if (supplierId != null)
      "supplierId": supplierId.toString(),

    if (customerId != null)
      "customerId": customerId.toString(),

    if (staffId != null)
      "staffId": staffId.toString(),

    "page": page.toString(),
    "size": size.toString(),
  };

  final uri = Uri.http(
    "192.168.1.100:8087",
    "/csm/api/v1/purchase/entries/search",
    queryParams,
  );

  print("Search URL => $uri");

  final response = await http.get(
    uri,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  print("Status Code => ${response.statusCode}");
  print("Response => ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    final List content = data['content'] ?? [];

    return content
        .map((e) => PurchaseEntry.fromJson(e))
        .toList();
  } else {
    throw Exception(
      "Failed to search purchase entries: ${response.statusCode}",
    );
  }
}