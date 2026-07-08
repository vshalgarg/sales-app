import 'dart:convert';

//import 'package:hisabio/model_classes/add_newsupplier.dart';
//import 'package:hisabio/model_classes/get_supplier.dart';
import 'package:hisabio/model_classes/update_supplier_model.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class UpdateSupplierApi{
  Future<UpdateSupplierModel> updateSupplier({required Map<String, dynamic> body,required int id,}) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/suppliers/update/id/$id");
      final token = await AppStorage.getToken();
      final response = await http.put(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return UpdateSupplierModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to update supplier");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
