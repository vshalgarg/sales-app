import 'package:http/http.dart' as http;

import '../../shared_preferences/login_token.dart';

Future<bool> deleteBill(String billNumber) async {
  final token = await AppStorage.getToken();

  final url =
      "http://192.168.1.100:8087/csm/api/v1/bill/entry/delete/$billNumber";

  final response = await http.delete(
    Uri.parse(url),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );


  if (response.statusCode == 200) {
    return true;
  }

  throw Exception("Failed to delete bill: ${response.body}");
}
