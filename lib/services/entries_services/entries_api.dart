import 'dart:convert';
import 'package:hisabio/model_classes/entries_customer_model.dart';
import 'package:hisabio/model_classes/entries_supplier.dart';
import 'package:hisabio/model_classes/get_transportname_id_model.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

class EntriesApi {
  Future<List<EntriesModel>> getEntrySupplier() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/suppliers/get/all");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final  List<dynamic>data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data
            .map((e) => EntriesModel.fromJson(e))
            .toList();
      } else {
        throw Exception( "Failed to fetch suppliers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<List<EntriesCustomerModel>> getEntryCustomer() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/customers/get/all");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final  List<dynamic>data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data
            .map((e) => EntriesCustomerModel.fromJson(e))
            .toList();
      } else {
        throw Exception( "Failed to fetch customers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<List<GetTransportnameIdModel>> getTransporters() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/transports/getAll");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final  List<dynamic>data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data
            .map((e) => GetTransportnameIdModel.fromJson(e))
            .toList();
      } else {
        throw Exception( "Failed to fetch transport");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
