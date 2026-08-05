import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../model_classes/Transport/transport.dart';
import '../../../model_classes/common/api_response.dart';
import '../../../model_classes/entries/add_newsupplier.dart';
import '../../../model_classes/entries/entries_customer_model.dart';
import '../../../model_classes/entries/entries_supplier.dart';
import '../../../model_classes/entries/get_staff_entry.dart';
import '../../../network/api_service.dart';
import '../../../network/response_result.dart';

class EntriesService {
  final ApiService _api;

  EntriesService(this._api);

  static const String _suppliers = "/suppliers";
  static const String _customers = "/customers";
  static const String _transports = "/transports";
  static const String _staffs = "/staffs";
  static const String _credit = "/credit";
  static const String _bill = "/bill";
  static const String _purchase = "/purchase";
  static const String _retail = "/retail";

  ///---------------------------------------------------------------
  /// FETCH SUPPLIERS
  ///---------------------------------------------------------------

  Future<ResponseResult<List<EntriesModel>>> fetchSuppliers() async {
    final result = await _api.get<List<dynamic>>(
      path: "$_suppliers/get/all",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch suppliers",
        statusCode: result.statusCode,
      );
    }

    final suppliers = (result.data ?? [])
        .map((e) => EntriesModel.fromJson(e))
        .toList();

    return ResponseResult.success(
      suppliers,
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// FETCH CUSTOMERS
  ///---------------------------------------------------------------

  Future<ResponseResult<List<EntriesCustomerModel>>> fetchCustomers() async {
    final result = await _api.get<List<dynamic>>(
      path: "$_customers/get/all",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch customers",
        statusCode: result.statusCode,
      );
    }

    final customers = (result.data ?? [])
        .map((e) => EntriesCustomerModel.fromJson(e))
        .toList();

    return ResponseResult.success(
      customers,
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// FETCH TRANSPORTS
  ///---------------------------------------------------------------

  Future<ResponseResult<List<Transport>>> fetchTransports() async {
    final result = await _api.get<List<dynamic>>(
      path: "$_transports/getAll",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch transports",
        statusCode: result.statusCode,
      );
    }

    final transports = (result.data ?? [])
        .map((e) => Transport.fromJson(e))
        .toList();

    return ResponseResult.success(
      transports,
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// FETCH STAFF
  ///---------------------------------------------------------------

  Future<ResponseResult<List<GetStaffEntry>>> fetchStaff() async {
    final result = await _api.get<List<dynamic>>(
      path: "$_staffs/get/all",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch staff",
        statusCode: result.statusCode,
      );
    }

    final staff = (result.data ?? [])
        .map((e) => GetStaffEntry.fromJson(e))
        .toList();

    return ResponseResult.success(
      staff,
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// ADD SUPPLIER
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> addSupplier({
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "/retail-suppliers",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add supplier",
        statusCode: result.statusCode,
      );
    }

    final response = ApiResponse.fromJson(result.data!);

    if (!response.success) {
      return ResponseResult.error(
        errorMessage: response.message,
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      response,
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// ADD CREDIT ENTRY
  ///---------------------------------------------------------------

  Future<ResponseResult<AddNewsupplier>> addCreditEntry({
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_credit/entry/add",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to add credit entry",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      AddNewsupplier.fromJson(result.data!),
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// ADD RETAIL ENTRY
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> addRetailEntry({
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_retail/create",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to add retail entry",
        statusCode: result.statusCode,
      );
    }

    final response = ApiResponse.fromJson(result.data!);

    if (!response.success) {
      return ResponseResult.error(
        errorMessage: response.message,
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      response,
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// ADD BILL
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> addBill({
    required Map<String, dynamic> payload,
    List<File> images = const [],
  }) async {
    final formData = FormData();

    formData.files.add(
      MapEntry(
        "payload",
        MultipartFile.fromString(
          jsonEncode(payload),
          filename: "payload.json",
          contentType: DioMediaType(
            "application",
            "json",
          ),
        ),
      ),
    );

    for (final image in images) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    print("=========== BILL PAYLOAD ===========");
    print(jsonEncode(payload));

    final result = await _api.post<Map<String, dynamic>>(
      path: "$_bill/entry/add",
      data: formData,
    );

    print(result.data);

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add bill",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// UPDATE BILL
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> updateBill({
    required int id,
    required Map<String, dynamic> payload,
    List<File> images = const [],
  }) async {
    final formData = FormData();

    formData.files.add(
      MapEntry(
        "data",
        MultipartFile.fromBytes(
          utf8.encode(jsonEncode(payload)),
          filename: "blob",
          contentType: DioMediaType(
            "application",
            "json",
          ),
        ),
      ),
    );

    for (final image in images) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    print("========== UPDATE BILL ==========");
    print(jsonEncode(payload));

    final result = await _api.patch<Map<String, dynamic>>(
      path: "$_bill/entry/update/$id",
      data: formData,
    );

    print("Status : ${result.statusCode}");
    print("Response : ${result.data}");
    print("Error : ${result.errorMessage}");

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to update bill",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }
  ///---------------------------------------------------------------
  /// ADD PURCHASE
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> addPurchase({
    required Map<String, dynamic> payload,
    required List<List<PlatformFile>> uploadedFiles,
    required List<EntriesModel?> selectedSuppliers,
  }) async {
    final formData = FormData();

    formData.fields.add(
      MapEntry(
        "payload",
        jsonEncode(payload),
      ),
    );

    for (int i = 0; i < uploadedFiles.length; i++) {
      final supplierId = selectedSuppliers[i]?.id;

      if (supplierId == null) continue;

      for (final file in uploadedFiles[i]) {
        if (file.path == null) continue;

        formData.files.add(
          MapEntry(
            "supplier_${supplierId}_images",
            await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          ),
        );
      }
    }

    final result = await _api.post<Map<String, dynamic>>(
      path: "$_purchase/entry/add",
      data: formData,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add purchase",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// GET CREDIT DETAILS
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> getCreditDetailsById(
      int id,) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_credit/details/$id",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to fetch credit details",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// UPDATE CREDIT DETAILS
  ///---------------------------------------------------------------

  Future<ResponseResult<AddNewsupplier>> updateCreditDetails({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.patch<Map<String, dynamic>>(
      path: "$_credit/entry/update/$id",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to update credit details",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      AddNewsupplier.fromJson(result.data!),
      result.statusCode,
    );
  }
}








// import 'dart:convert';
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:hisabio/model_classes/entries/entries_customer_model.dart';
// import 'package:hisabio/model_classes/entries/entries_supplier.dart';
// import 'package:hisabio/shared_preferences/login_token.dart';
// import 'package:http/http.dart' as http;
//
// import '../../model_classes/Transport/transport.dart';
// import '../../model_classes/entries/add_newsupplier.dart';
// import '../../model_classes/credits/creditdetails_byid.dart';
// import '../../model_classes/entries/get_staff_entry.dart';
//
// class EntriesApi {
//   Future<List<EntriesModel>> getEntrySupplier() async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/suppliers/get/all",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.get(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//       final List<dynamic> data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return data.map((e) => EntriesModel.fromJson(e)).toList();
//       } else {
//         throw Exception("Failed to fetch suppliers");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
//
//   Future<List<EntriesCustomerModel>> getEntryCustomer() async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/customers/get/all",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.get(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//       final List<dynamic> data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return data.map((e) => EntriesCustomerModel.fromJson(e)).toList();
//       } else {
//         throw Exception("Failed to fetch customers");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
//
//   Future<List<Transport>> getTransporters() async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/transports/getAll",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.get(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//       final List<dynamic> data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return data.map((e) => Transport.fromJson(e)).toList();
//       } else {
//         throw Exception("Failed to fetch transport");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
//
//   Future<AddNewsupplier> addNewCreditEntry(Map<String, dynamic> body) async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/credit/entry/add",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode(body),
//       );
//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return AddNewsupplier.fromJson(data);
//       } else {
//         throw Exception(data['message'] ?? "Failed to add credit entry");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
//
//   Future<String?> addBillEntry({
//     required Map<String, dynamic> payload,
//     required List<File> images,
//   }) async {
//     final url = Uri.parse(
//       "http://192.168.1.100:8087/csm/api/v1/bill/entry/add",
//     );
//
//     final token = await AppStorage.getToken();
//
//     final request = http.MultipartRequest('POST', url);
//
//     request.headers['Authorization'] = 'Bearer $token';
//
//     request.files.add(
//       http.MultipartFile.fromString(
//         'payload',
//         jsonEncode(payload),
//         contentType: http.MediaType('application', 'json'),
//       ),
//     );
//
//     for (final image in images) {
//       request.files.add(
//         await http.MultipartFile.fromPath('images', image.path),
//       );
//     }
//
//     final response = await request.send();
//     final body = await response.stream.bytesToString();
//
//     final data = jsonDecode(body);
//
//     if (response.statusCode == 200) {
//       return data["message"] ?? "Bill saved successfully";
//     } else {
//       throw Exception(data["message"] ?? "Failed to save bill");
//     }
//   }
//
//   Future<List<GetStaffEntry>> getStaffEntry() async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/staffs/get/all",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.get(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//       final List<dynamic> data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return data.map((e) => GetStaffEntry.fromJson(e)).toList();
//       } else {
//         throw Exception("Failed to fetch staff");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
//
//   Future<String?> addPurchaseEntry({
//     required Map<String, dynamic> payload,
//     required List<List<PlatformFile>> uploadedFiles,
//     required List<EntriesModel?>selectedSuppliers,
//   }) async {
//     final url = Uri.parse(
//       "http://192.168.1.100:8087/csm/api/v1/purchase/entry/add",
//     );
//
//     final token = await AppStorage.getToken();
//
//     final request = http.MultipartRequest('POST', url);
//
//     request.headers['Authorization'] = 'Bearer $token';
//
//     request.files.add(
//       http.MultipartFile.fromString(
//         'payload',
//         jsonEncode(payload),
//         contentType: http.MediaType('application', 'json'),
//       ),
//     );
//
//     for (int i =0;i<uploadedFiles.length;i++ ){
//       final supplierId = selectedSuppliers[i]?.id;
//       if(supplierId==null) continue;
//       for(final file in uploadedFiles[i]){
//         if (file.path ==null)continue;
//
//       request.files.add(
//         await http.MultipartFile.fromPath('supplier_${supplierId}_images', file.path!),
//       );
//     }}
//
//     final response = await request.send();
//     final body = await response.stream.bytesToString();
//
//     final data = jsonDecode(body);
//
//     if (response.statusCode == 200) {
//       return data["message"] ?? "Purchase saved successfully";
//     } else {
//       throw Exception(data["message"] ?? "Failed to save purchase");
//     }
//   }
//
//   Future<String?> addNewRetailEntry(Map<String, dynamic> body) async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/retail/create",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode(body),
//       );
//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return data["message"];
//       } else {
//         throw Exception(data['message'] ?? "Failed to add retail entry");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
//
//   Future<String?> updateBillEntry({
//     required Map<String, dynamic> payload,
//     required List<File> images,
//     required int id,
//   }) async {
//     final url = Uri.parse(
//       "http://192.168.1.100:8087/csm/api/v1/bill/entry/update/$id",
//     );
//
//     final token = await AppStorage.getToken();
//
//     final request = http.MultipartRequest("PATCH", url);
//
//     request.headers.addAll({
//       "Authorization": "Bearer $token",
//       "Accept": "application/json",
//     });
//
//     request.files.add(
//       http.MultipartFile.fromString(
//         "data",
//         jsonEncode(payload),
//         contentType: http.MediaType("application", "json"),
//       ),
//     );
//
//     print(jsonEncode(payload));
//
//     for (final image in images) {
//       request.files.add(
//         await http.MultipartFile.fromPath("images", image.path),
//       );
//     }
//
//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);
//
//     final body = jsonDecode(response.body);
//
//     if (response.statusCode == 200) {
//       return body["message"] ?? "Bill updated successfully";
//     } else {
//       throw Exception(body["message"] ?? "Failed to update bill");
//     }
//   }
//
//   Future<CreditDetailsResponse> getCreditDetailsById(int id) async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/credit/details/$id",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.get(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//       );
//       final data = jsonDecode(response.body);
//       if (response.statusCode == 200) {
//         return CreditDetailsResponse.fromJson(data);
//       } else {
//         throw Exception(data['message'] ?? "Failed to fetch Credit Details");
//       }
//     } catch (e) {
//       throw Exception("Error $e");
//     }
//   }
//   Future<AddNewsupplier> updateCreditDetails({
//     required Map<String, dynamic> body,
//     required int id,
//   }) async {
//     try {
//       final url = Uri.parse(
//         "http://192.168.1.100:8087/csm/api/v1/credit/entry/update/$id",
//       );
//       final token = await AppStorage.getToken();
//       final response = await http.patch(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode(body),
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200||response.statusCode==201) {
//         return AddNewsupplier.fromJson(data);
//       } else {
//         throw Exception(data['message'] ?? "Failed to update credit details");
//       }
//     } catch (e) {
//       throw Exception("$e");
//     }
//   }
// }
