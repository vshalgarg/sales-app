import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model_classes/purchases/get_purchase_model.dart';
import '../shared_preferences/login_token.dart';

Future<PurchaseDetailsResponse> getPurchaseDetails(int id) async {
  final token = await AppStorage.getToken();

try{
  final response = await http.get(
    Uri.parse(
      "http://192.168.1.100:8087/csm/api/v1/purchase/get/details/$id",
    ),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  final json = jsonDecode(response.body);
  print(jsonEncode(json));
  if (response.statusCode == 200) {
    return PurchaseDetailsResponse.fromJson(json);
  } else {
    throw Exception(json['message'] ?? "Failed to fetch purchase details");
  }
} catch (e) {
  throw Exception("Error: $e");
}
}