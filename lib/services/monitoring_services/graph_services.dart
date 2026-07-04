import 'dart:convert';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../../model_classes/graph_response_model.dart';
import '../../model_classes/monitoring_charts.dart';
import '../../model_classes/staff_analytics_model.dart';
class GraphResponseServices {
  Future<GraphResponse > graphResponse({
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/analytics/monthly",
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
        return GraphResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch details");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }

  Future<StaffAnalyticsModel> graphStaffResponse({
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/analytics/staff",
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
        return StaffAnalyticsModel.fromJson(data["data"]);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch details");
      }

    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future< AmountGraphModel> graphSupplierAmountResponse({
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/analytics/supplier/amount",
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
        return AmountGraphModel.fromJson(
          data["data"],
          "supplierVsAmount",
        );
      } else {
        throw Exception(data["message"] ?? "Failed to fetch data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }Future< AmountGraphModel> graphCustomerAmountResponse({
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/analytics/customer/amount",
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
        return AmountGraphModel.fromJson(
          data["data"],
          "customerVsAmount",
        );
      } else {
        throw Exception(data["message"] ?? "Failed to fetch data");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
