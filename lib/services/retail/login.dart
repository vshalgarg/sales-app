
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:hisabio/model_classes/login_model.dart';
import 'package:http/http.dart' as http;
class LoginApi {
  Future< LoginModel> login(String username, String password) async {
    try{

    final url = Uri.parse("http://192.168.1.100:8087/csm/api/v1/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    var data =jsonDecode(response.body);


    if (response.statusCode == 200) {
      return  LoginModel.fromJson(data);
    } else {
      throw Exception(data['message']??"Login Failed");
    }}
    catch (e){
      debugPrint("Login Error => $e");
      rethrow;
    }
  }
}
