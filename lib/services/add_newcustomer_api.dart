import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/add_customer.dart';

class AddNewCustomerApi {
  Future<AddCustomer> addNewCustomer(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/customer/add",
      );
      final token = await AppStorage.getToken();
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print(body);
      final data = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        return AddCustomer.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to add new customer");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
