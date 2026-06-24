import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../shared_preferences/login_token.dart';

Future<void> updateBill({
  required int id,

  required String date,
  required String receivedDate,

  required int supplierId,
  required int customerId,

  required String remarks,
  required String lrNumber,
  required String transport,

  required double taxableValue,
  required double billAmount,

  required List<Map<String, dynamic>> billItems,

  required List<String> existingImageKeys,

  required List<File> files,
}) async {
  final token = await AppStorage.getToken();

  final url = "http://192.168.1.100:8087/csm/api/v1/bill/entry/update/$id";

  debugPrint("URL => $url");

  final requestData = {
    "date": date,
    "receivedDate": receivedDate,

    "supplierId": supplierId,
    "customerId": customerId,

    "transport": transport,
    "lrNumber": lrNumber,
    "remarks": remarks,

    "taxableValue": taxableValue,
    "billAmount": billAmount,

    "billItems": billItems,

    "existingImageKeys": existingImageKeys,
  };

  debugPrint("Request JSON => ${jsonEncode(requestData)}");

  var request = http.MultipartRequest('PATCH', Uri.parse(url));

  request.headers['Authorization'] = "Bearer $token";

  request.files.add(
    http.MultipartFile.fromString(
      'data',
      jsonEncode(requestData),
      contentType: MediaType('application', 'json'),
    ),
  );

  for (final file in files) {
    debugPrint("Uploading => ${file.path}");

    request.files.add(await http.MultipartFile.fromPath('images', file.path));
  }
  debugPrint("REQUEST JSON => ${jsonEncode(requestData)}");

  debugPrint("REQUEST FILE COUNT => ${request.files.length}");

  debugPrint("REQUEST FIELDS => ${request.fields}");
  final response = await request.send();

  final responseBody = await response.stream.bytesToString();

  debugPrint("Response Status => ${response.statusCode}");

  debugPrint("Response Body => $responseBody");

  if (response.statusCode != 200) {
    throw Exception("Update Failed : $responseBody");
  }
}
