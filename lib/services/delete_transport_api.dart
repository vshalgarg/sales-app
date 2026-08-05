// import 'dart:convert';
// import 'package:hisabio/shared_preferences/login_token.dart';
// import 'package:http/http.dart' as http;
//
// import '../model_classes/Transport/delete_transport.dart';
//
// class DeleteTransportApi {
//   Future<DeleteTransport> deleteTransport(int id) async {
//     try {
//       final url = Uri.parse(
//           "http://192.168.1.100:8087/csm/api/v1/transports/delete/$id");
//       final token = await AppStorage.getToken();
//       final response = await http.delete(
//         url, headers: { "Content-Type": "application/json",
//         "Authorization": "Bearer $token"},
//         );
//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return  DeleteTransport .fromJson(data);
//       } else {
//         throw Exception(data['message'] ?? "Failed to delete transport");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
// }
