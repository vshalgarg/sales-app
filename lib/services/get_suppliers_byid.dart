import 'dart:convert';
import 'package:hisabio/model_classes/get_suppliers_byid.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class GetSuppliersByIdApi {
  Future<GetSupplierByIdModel> getSupplierById(int id) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/suppliers/get/id/$id");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return GetSupplierByIdModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch suppliers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
