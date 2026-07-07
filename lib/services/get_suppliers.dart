import 'dart:convert';

import 'package:hisabio/model_classes/get_supplier.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class GetSuppliersApi {
  Future<GetSupplier> getSupplier({int page =0, int size = 10}) async {
    try {
      final token = await AppStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception("Token is null or empty");
      }
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/suppliers/get",
      ).replace(queryParameters: {"page": "$page", "size": "$size"});
      print("Request URL: $url");
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return GetSupplier.fromJson(data);
      } else {
        throw Exception(data["message"]);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
