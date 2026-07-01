import 'dart:convert';
import 'dart:io';
import 'package:hisabio/model_classes/entries_customer_model.dart';
import 'package:hisabio/model_classes/entries_supplier.dart';
import 'package:hisabio/model_classes/get_transportname_id_model.dart';
import 'package:hisabio/shared_preferences/login_token.dart';
import 'package:http/http.dart' as http;

import '../../model_classes/add_newsupplier.dart';
import '../../model_classes/get_staff_entry.dart';

class EntriesApi {
  Future<List<EntriesModel>> getEntrySupplier() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/suppliers/get/all");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final  List<dynamic>data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data
            .map((e) => EntriesModel.fromJson(e))
            .toList();
      } else {
        throw Exception( "Failed to fetch suppliers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<List<EntriesCustomerModel>> getEntryCustomer() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/customers/get/all");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final  List<dynamic>data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data
            .map((e) => EntriesCustomerModel.fromJson(e))
            .toList();
      } else {
        throw Exception( "Failed to fetch customers");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<List<GetTransportnameIdModel>> getTransporters() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/transports/getAll");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final  List<dynamic>data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data
            .map((e) => GetTransportnameIdModel.fromJson(e))
            .toList();
      } else {
        throw Exception( "Failed to fetch transport");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<AddNewsupplier> addNewCreditEntry(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/credit/entry/add");
      final token = await AppStorage.getToken();
      final response = await http.post(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AddNewsupplier.fromJson(data);
      } else {
        throw Exception(data['message'] ?? "Failed to add credit entry");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<String?> addBillEntry({
    required Map<String, dynamic> payload,
    required List<File> images,
  }) async {
    final url = Uri.parse(
      "http://192.168.1.100:8087/csm/api/v1/bill/entry/add",
    );

    final token = await AppStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromString(
        'payload',
        jsonEncode(payload),
        contentType: http.MediaType('application', 'json'),
      ),
    );

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    print(response.statusCode);
    print(body);

    final data = jsonDecode(body);
    print(jsonEncode(payload));
    print("Images count = ${images.length}");

    if (response.statusCode == 200) {
      return data["message"] ?? "Bill saved successfully";
    } else {
      throw Exception(data["message"] ?? "Failed to save bill");
    }
  }
  Future<List<GetStaffEntry>> getStaffEntry() async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/staffs/get/all");
      final token = await AppStorage.getToken();
      final response = await http.get(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},);
      final  List<dynamic>data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data
            .map((e) => GetStaffEntry.fromJson(e))
            .toList();
      } else {
        throw Exception( "Failed to fetch staff");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
  Future<String?> addPurchaseEntry({
    required Map<String, dynamic> payload,
    required List<File> images,
  }) async {
    final url = Uri.parse(
      "http://192.168.1.100:8087/csm/api/v1/purchase/entry/add",
    );

    final token = await AppStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      http.MultipartFile.fromString(
        'payload',
        jsonEncode(payload),
        contentType: http.MediaType('application', 'json'),
      ),
    );

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
        ),
      );
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    print(response.statusCode);
    print(body);

    final data = jsonDecode(body);
    print(jsonEncode(payload));
    print("Images count = ${images.length}");

    if (response.statusCode == 200) {
      return data["message"] ?? "Purchase saved successfully";
    } else {
      throw Exception(data["message"] ?? "Failed to save purchase");
    }
  }
  Future<String?> addNewRetailEntry(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse(
          "http://192.168.1.100:8087/csm/api/v1/retail/create");
      final token = await AppStorage.getToken();
      final response = await http.post(
        url, headers: { "Content-Type": "application/json",
        "Authorization": "Bearer $token"},
        body: jsonEncode(body),);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return (data);
      } else {
        throw Exception(data['message'] ?? "Failed to add retail entry");
      }
    } catch (e) {
      throw Exception("Error $e");
    }
  }
}
