import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared_preferences/login_token.dart';

Future<void> deleteCredit(int id) async {
  final token = await AppStorage.getToken();

  final url = Uri.parse(
    "http://192.168.1.100:8087/csm/api/v1/credit/entry/delete/$id",
  );

  print("Delete Credit URL => $url");

  final response = await http.delete(
    url,
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );

  print(
    "Delete Credit Status => ${response.statusCode}",
  );

  print(
    "Delete Credit Response => ${response.body}",
  );

  if (response.statusCode != 200) {
    throw Exception(
      "Failed to delete credit",
    );
  }

  final body = jsonDecode(response.body);

  if (body["message"] == null) {
    throw Exception("Delete failed");
  }
}