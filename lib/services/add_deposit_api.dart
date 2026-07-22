import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model_classes/add_deposit_model.dart';
import '../shared_preferences/login_token.dart';

class AddDepositApi {
  Future<Map<String, dynamic>> addDeposits(
      AddDepositModel model,
      ) async {
    final token = await AppStorage.getToken();

    final response = await http.post(
      Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/retail-supplier-deposits",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(model.toJson()),
    );
    print("Deposit Payload: ${jsonEncode(model.toJson())}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);

    return {
      "success": response.statusCode == 200,
      "message": data["message"] ?? "Something went wrong",
    };
  }
}