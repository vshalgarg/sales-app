import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model_classes/retail_model.dart';
import '../shared_preferences/login_token.dart';

class RetailApi {

  Future<Map<String, dynamic>> searchRetail({
    String? fromDate,
    String? toDate,
    int? customerId,
    int? staffId,
    int? supplierId,
    int page = 0,
    int size = 10,
  }) async {
    final token = await AppStorage.getToken();
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (fromDate != null && fromDate.isNotEmpty) {
        queryParams['fromDate'] = fromDate;
      }

      if (toDate != null && toDate.isNotEmpty) {
        queryParams['toDate'] = toDate;
      }

      if (customerId != null) {
        queryParams['customerId'] = customerId.toString();
      }

      if (staffId != null) {
        queryParams['staffId'] = staffId.toString();
      }

      if (supplierId != null) {
        queryParams['supplierId'] = supplierId.toString();
      }

      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/retail/search",
      ).replace(queryParameters: queryParams);
      final response = await http.get(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
      );

      if (response.statusCode == 200) {
        print("RETAIL API RESPONSE:");
        print(response.body);
        final jsonData = jsonDecode(response.body);

        final content =
        jsonData["data"]["content"] as List<dynamic>;

        final retailList = content
            .map((e) => RetailModel.fromJson(e))
            .toList();

        return {
          "retails": retailList,
          "totalPages": jsonData["data"]["totalPages"] ?? 0,
          "last": jsonData["data"]["last"] ?? true,
        };
      }

      throw Exception("Failed to load retailers");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}