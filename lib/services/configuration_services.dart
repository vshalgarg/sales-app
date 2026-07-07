// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import '../shared_preferences/login_token.dart';
//
// Future<bool> getRetailFeatureStatus() async {
//   final token = await AppStorage.getToken();
//
//   final response = await http.get(
//     Uri.parse("http://192.168.1.100:8087/csm/api/v1/admin/configurations"),
//     headers: {
//       "Authorization": "Bearer $token",
//       "Content-Type": "application/json",
//     },
//   );
//
//   if (response.statusCode == 200) {
//     final json = jsonDecode(response.body);
//
//     final List data = json["data"];
//
//     final config = data.firstWhere(
//           (e) => e["key"] == "RETAIL_FEATURE",
//     );
//
//     return config["value"] == "true";
//   }
//
//   return false;
// }