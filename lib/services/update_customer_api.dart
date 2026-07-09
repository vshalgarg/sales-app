import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/update_customer_model.dart';

class UpdateCustomerApi {
  Future<UpdateCustomerModel> updateCustomer({
    required Map<String, dynamic> body,
    required int id,
  }) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/customers/update/id/$id",
      );
      final token = await AppStorage.getToken();
      print("UPDATE URL: $url");
      print("UPDATE BODY: ${jsonEncode(body)}");
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE: ${response.body}");
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UpdateCustomerModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to update customer");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
