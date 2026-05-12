import 'dart:convert';

import 'package:hisabio/model_classes/add_newsupplier.dart';
import 'package:hisabio/model_classes/get_supplier.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class AddNewSupplierApiApi {
  Future<AddNewsupplier> addNewSupplier(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/supplier/add");
      final token = await AppStorage.getToken();
      final response = await http.post(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      print(body);
      final data = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        return AddNewsupplier.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to add new supplier");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
