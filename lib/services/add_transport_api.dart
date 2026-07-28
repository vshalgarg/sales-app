import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;
import '../model_classes/add_transport_model.dart';
import '../model_classes/update_customer_model.dart';

class AddNewTransportApi {
  Future<AddTransportModel > addNewTransport(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/transports/add",
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
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AddTransportModel .fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to add new Transport");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<UpdateCustomerModel > updateTransport(Map<String, dynamic> body,int id) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/transports/update/$id",
      );
      final token = await AppStorage.getToken();
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      print("URL: $url");
      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");
      print("Request Body: ${jsonEncode(body)}");
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return UpdateCustomerModel.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to update transport");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
