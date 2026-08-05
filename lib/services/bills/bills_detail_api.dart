// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// import '../model_classes/bills/bill_details.dart';
// import '../shared_preferences/login_token.dart';
//
// Future<BillDetails> getBillDetails(String billNumber) async {
//   try{
//   final token = await AppStorage.getToken();
//
//   final response = await http.get(
//     Uri.parse("http://192.168.1.100:8087/csm/api/v1/bill/$billNumber"),
//     headers: {
//       "Authorization": "Bearer $token",
//       "Content-Type": "application/json",
//     },
//   );
//   //final data = jsonDecode(response.body);
//
//   // if (response.statusCode == 200) {
//   //
//   //   return BillDetails().fromJson(data);
//   // }
//   // else{
//   //   throw Exception(data["message"]);
//   // }
// }
// catch (e) {
//   throw Exception("Error $e");
// }}
