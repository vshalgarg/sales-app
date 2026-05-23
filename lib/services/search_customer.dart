import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../model_classes/search_customer_model.dart';

class GetSearchCustomersApi {
  Future<SearchCustomerModel> getSearchCustomer(String keyword) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/customers/search?keyword=$keyword&page=0&size=10",
      );
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
        return SearchCustomerModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to search customers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
