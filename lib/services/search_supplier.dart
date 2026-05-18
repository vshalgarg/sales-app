import 'dart:convert';
import 'package:hisabio/model_classes/search_supplier.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class GetSearchSuppliersApi {
  Future<SearchSupplier> getSearchSupplier(String keyword) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/suppliers/search/v2?keyword=$keyword&page=0&size=10&sortBy=supplierName&sortDir=asc",
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
        return SearchSupplier.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to search suppliers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
