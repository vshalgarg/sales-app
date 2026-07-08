import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model_classes/search_bills.dart';
import '../shared_preferences/login_token.dart';

Future<List<BillEntry>> searchBills({
  int page = 0,
  int size = 20,
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
  print("URL : $url");
  print("TOKEN : $token");
  final response = await http.get(
    url,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );
  if (response.body.isEmpty) {
    throw Exception("Empty response from server");
  }
  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    if (data['code'] == 500) {
      throw Exception(data['message']);
    }

    final List<dynamic> content = (data['content'] as List?) ?? [];
    return content.map((e) => BillEntry.fromJson(e)).toList();
  }

  throw Exception("Status: ${response.statusCode}\nResponse: ${response.body}");
}
