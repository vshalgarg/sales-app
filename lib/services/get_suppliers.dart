import 'dart:convert';

import 'package:hisabio/model_classes/get_supplier.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class GetSuppliersApi {
  Future<GetSupplier> getSupplier() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/suppliers/get?page=0&size=10");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return GetSupplier.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch suppliers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
