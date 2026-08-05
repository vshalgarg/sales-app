// import 'dart:convert';
// import 'package:hisabio/shared_preferences/login_token.dart';
// import 'package:http/http.dart' as http;
// import '../model_classes/user/get_users.dart';
//
// class GetUsersApi {
//   Future<GetUsers> getUsers() async {
//     try {
//       final url = Uri.parse(
//           "http://192.168.1.100:8087/csm/api/v1/users/get");
//       final token = await AppStorage.getToken();
//       final response = await http.get(
//         url, headers: { "Content-Type": "application/json",
//         "Authorization": "Bearer $token"},);
//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return GetUsers.fromJson(data);
//       } else {
//         throw Exception(data['message'] ?? "Failed to fetch users");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
// }
