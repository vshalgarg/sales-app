import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../model_classes/purchases/update_purchase_model.dart';
import '../shared_preferences/login_token.dart';

Future<UpdatePurchaseResponse> updatePurchase({
  required int id,
  required String date,
  required int customerId,
  required int supplierId,
  required int staffId,
  required String remarks,
  required List<String> existingImageKeys,
  required List<File> supplierImages,
}) async {
  try {
    final token = await AppStorage.getToken();

    final request = http.MultipartRequest(
      "PATCH",
      Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/purchase/entry/update/$id",
      ),
    );

    request.headers["Authorization"] = "Bearer $token";
    request.headers["Accept"] = "application/json";

    final payload = {
      "date": date,
      "staffId": staffId,
      "customerId": customerId,
      "supplierId": supplierId,
      "remarks": remarks,
      "existingImageKeys": existingImageKeys,
    };

    print("UPDATE URL: ${request.url}");
    print("REQUEST JSON: ${jsonEncode(payload)}");

    // Send JSON as multipart part instead of normal field
    request.files.add(
      http.MultipartFile.fromString(
        "data",
        jsonEncode(payload),
        contentType: MediaType("application", "json"),
      ),
    );

    // Attach images
    for (final file in supplierImages) {
      request.files.add(
        await http.MultipartFile.fromPath(
          "supplier_${supplierId}_images",
          file.path,
        ),
      );
    }

    print("FIELDS: ${request.fields}");

    for (final file in request.files) {
      print(
        "PART -> field: ${file.field}, filename: ${file.filename}, contentType: ${file.contentType}",
      );
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    print("STATUS CODE: ${streamedResponse.statusCode}");
    print("RESPONSE BODY: $responseBody");

    Map<String, dynamic> responseJson = {};

    try {
      responseJson = jsonDecode(responseBody);
    } catch (_) {
      throw Exception("Invalid response from server");
    }

    if (streamedResponse.statusCode == 200) {
      if (responseJson["code"] == 500) {
        throw Exception(
          responseJson["message"] ??
              "Something went wrong. Please try again later.",
        );
      }

      return UpdatePurchaseResponse.fromJson(responseJson);
    }

    throw Exception(
      responseJson["message"] ??
          "Failed to update purchase",
    );
  } catch (e) {
    print("UPDATE PURCHASE ERROR");
    print(e);
    rethrow;
  }
}