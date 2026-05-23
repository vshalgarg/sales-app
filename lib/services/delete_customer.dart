import 'dart:convert';

import 'package:hisabio/model_classes/delete_supplier.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/delete_customer_model.dart';

class DeleteCustomerApi {
  Future< DeleteCustomerModel> deleteCustomer(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/customer/delete");
      final token = await AppStorage.getToken();
      final response = await http.put(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      print(body);
      final data = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        return DeleteCustomerModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to delete customer");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
