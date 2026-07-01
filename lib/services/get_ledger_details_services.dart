import 'dart:convert';
import 'dart:typed_data';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;
import '../model_classes/get_ledger_details.dart';

class GetLedgerDetailsServices {
  Future<GetLedgerDetails> getLedgerDetails(
    int supplierId,
    int customerId,
    String viewType,
  ) async {
    try {
      final url = Uri.parse(
        "http://192.168.1.100:8087/csm/api/v1/ledger?supplierId=$supplierId&customerId=$customerId&viewType=$viewType",
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
        return GetLedgerDetails.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to fetch Ledger Details");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<Uint8List> downloadLedger(
      int supplierId,
      int customerId,
      String viewType,
      ) async {
    final token = await AppStorage.getToken();

    final url = Uri.parse(
      "http://192.168.1.100:8087/csm/api/v1/ledger/download?supplierId=$supplierId&customerId=$customerId&viewType=$viewType",
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw Exception("Download failed");
  }
}
