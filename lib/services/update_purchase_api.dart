import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../shared_preferences/login_token.dart';

Future<void> updatePurchase({
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

    final Map<String, dynamic> payload = {
      "date": date,
      "staffId": staffId,
      "customerId": customerId,
      "supplierId": supplierId,
      "remarks": remarks,
    };


    if (existingImageKeys.isNotEmpty) {
      payload["existingImageKeys"] = existingImageKeys;
    }


    request.fields["data"] = jsonEncode(payload);

    // Upload new files
    for (final file in supplierImages) {

      request.files.add(
        await http.MultipartFile.fromPath(
          "supplierImages",
          file.path,
        ),
      );
    }

    final streamedResponse = await request.send();

    final responseBody =
    await streamedResponse.stream.bytesToString();



    Map<String, dynamic> responseJson = {};

    try {
      responseJson = jsonDecode(responseBody);
    } catch (_) {
      throw Exception("Invalid response from server");
    }
    if (responseJson["code"] == 500) {
      throw Exception(
        responseJson["message"] ??
            "Server error while updating purchase",
      );
    }

    if (streamedResponse.statusCode == 200) {
      print("PURCHASE UPDATED SUCCESSFULLY");
      return;
    }

    throw Exception(
      responseJson["message"] ??
          "Failed to update purchase",
    );
  } catch (e) {
    print(" UPDATE PURCHASE ERROR ");
    print(e);
    rethrow;
  }
}