import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../model_classes/common/paginated_response.dart';
import '../../../../network/api_service.dart';
import '../../../../network/response_result.dart';
import '../../model_classes/bills/add_bill_request.dart';
import '../../model_classes/bills/bill.dart';
import '../../model_classes/bills/bill_details.dart';
import '../../model_classes/common/api_response.dart';

class BillService {
  final ApiService _api;

  BillService(this._api);

  static const String _bill = "/bill";
  static const String _billEntry = "/bill/entry";
  static const String _billEntries = "/bill/entries";

  //==========================================================
  // GET BILLS
  //==========================================================

  Future<ResponseResult<PaginatedResponse<Bill>>> getBills({
    required int page,
    required int size,
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_billEntries/search",
      queryParameters: {
        "page": page,
        "size": size,
        if (fromDate != null && fromDate.isNotEmpty)
          "fromDate": fromDate,
        if (toDate != null && toDate.isNotEmpty)
          "toDate": toDate,
        if (supplierId != null)
          "supplierId": supplierId,
        if (customerId != null)
          "customerId": customerId,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    if (result.data?["code"] != null) {
      return ResponseResult.error(
        errorMessage: result.data?["message"] ?? "Failed to fetch bills",
        statusCode: result.statusCode,
      );
    }

    final bills = PaginatedResponse<Bill>.fromJson(
      result.data!,
      Bill.fromJson,
    );

    return ResponseResult.success(
      bills,
      result.statusCode,
    );
  }
  //==========================================================
  // SEARCH BILLS
  //==========================================================

  Future<ResponseResult<PaginatedResponse<Bill>>> searchBills({
    required String keyword,
    required int page,
    required int size,
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_billEntries/search",
      queryParameters: {
        "keyword": keyword,
        "page": page,
        "size": size,
        if (fromDate != null && fromDate.isNotEmpty)
          "fromDate": fromDate,
        if (toDate != null && toDate.isNotEmpty)
          "toDate": toDate,
        if (supplierId != null)
          "supplierId": supplierId,
        if (customerId != null)
          "customerId": customerId,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    if (result.data?["code"] != null) {
      return ResponseResult.error(
        errorMessage: result.data?["message"] ?? "Search failed",
        statusCode: result.statusCode,
      );
    }

    final bills = PaginatedResponse<Bill>.fromJson(
      result.data!,
      Bill.fromJson,
    );

    return ResponseResult.success(
      bills,
      result.statusCode,
    );
  }

  //==========================================================
  // GET BILL DETAILS
  //==========================================================

  Future<ResponseResult<BillDetails>> getBillById(
      String billNumber,
      ) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_bill/$billNumber",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    if (result.data?["code"] != null) {
      return ResponseResult.error(
        errorMessage: result.data?["message"] ?? "Failed to fetch bill details",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      BillDetails.fromJson(result.data!),
      result.statusCode,
    );
  }
  //==========================================================
  // ADD BILL
  //==========================================================

  Future<ResponseResult<ApiResponse>> addBill({
    required AddBillRequest request,
    List<File> images = const [],
  }) async {
    final payload = request.toJson();

    payload["billItems"] =
        request.items?.map((e) => e.toJson()).toList() ?? [];

    final formData = FormData();

    formData.fields.add(
      MapEntry(
        "payload",
        jsonEncode(payload),
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

    final result = await _api.post<Map<String, dynamic>>(
      path: "$_billEntry/add",
      data: formData,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
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
  //==========================================================
  // UPDATE BILL
  //==========================================================

  Future<ResponseResult<ApiResponse>> updateBill({
    required int id,
    required AddBillRequest request,
    List<String> existingImageKeys = const [],
    List<File> images = const [],
  }) async {
    final payload = request.toJson();

    payload["billItems"] =
        request.items?.map((e) => e.toJson()).toList() ?? [];

    payload["existingImageKeys"] = existingImageKeys;

    final formData = FormData();

    formData.fields.add(
      MapEntry(
        "payload",
        jsonEncode(payload),
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

    final result = await _api.patch<Map<String, dynamic>>(
      path: "$_billEntry/update/$id",
      data: formData,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
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

  //==========================================================
  // DELETE BILL
  //==========================================================

  Future<ResponseResult<ApiResponse>> deleteBill(
      String billNumber,
      ) async {
    final result = await _api.delete<Map<String, dynamic>>(
      path: "$_billEntry/delete/$billNumber",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
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
}















// import 'dart:convert';
// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import '../../../model_classes/common/paginated_response.dart';
// import '../../../network/api_service.dart';
// import '../../../network/response_result.dart';
// import '../../model_classes/bills/add_bill_request.dart';
// import '../../model_classes/bills/bill.dart';
// import '../../model_classes/bills/bill_details.dart';
//
// class BillService {
//   final ApiService _apiService;
//
//   BillService(this._apiService);
//
//   // FETCH BILLS
//
//
//   Future<PaginatedResponse<Bill>> fetchBills({
//     int page = 0,
//     int size = 20,
//     String? fromDate,
//     String? toDate,
//     num? supplierId,
//     num? customerId,
//   }) async {
//     final query = <String, dynamic>{
//       "page": page,
//       "size": size,
//       if (fromDate != null && fromDate.isNotEmpty)
//         "fromDate": fromDate,
//       if (toDate != null && toDate.isNotEmpty)
//         "toDate": toDate,
//       if (supplierId != null)
//         "supplierId": supplierId,
//       if (customerId != null)
//         "customerId": customerId,
//     };
//
//     final ResponseResult result = await _apiService.get(
//       path: "/bill/entries/search",
//       queryParameters: query,
//     );
//
//     if (!result.isSuccess || result.data == null) {
//       throw Exception(
//         result.errorMessage ?? "Failed to fetch bills",
//       );
//     }
//
//     return PaginatedResponse<Bill>.fromJson(
//       result.data,
//           (json) => Bill.fromJson(json),
//     );
//   }
//
//   // SEARCH BILLS
//
//
//   Future<PaginatedResponse<Bill>> searchBills({
//     int page = 0,
//     int size = 20,
//     String? keyword,
//     String? fromDate,
//     String? toDate,
//     num? supplierId,
//     num? customerId,
//   }) async {
//     final query = <String, dynamic>{
//       "page": page,
//       "size": size,
//       if (keyword != null && keyword.isNotEmpty)
//         "keyword": keyword,
//       if (fromDate != null && fromDate.isNotEmpty)
//         "fromDate": fromDate,
//       if (toDate != null && toDate.isNotEmpty)
//         "toDate": toDate,
//       if (supplierId != null)
//         "supplierId": supplierId,
//       if (customerId != null)
//         "customerId": customerId,
//     };
//
//     final ResponseResult result = await _apiService.get(
//       path: "/bill/entries/search",
//       queryParameters: query,
//     );
//
//     if (!result.isSuccess || result.data == null) {
//       throw Exception(
//         result.errorMessage ?? "Failed to search bills",
//       );
//     }
//
//     return PaginatedResponse<Bill>.fromJson(
//       result.data,
//           (json) => Bill.fromJson(json),
//     );
//   }
//
//   // FETCH BILL DETAILS
//
//
//   Future<BillDetails> fetchBillDetails(String billNumber) async {
//     final ResponseResult result = await _apiService.get(
//       path: "/bill/$billNumber",
//     );
//
//     if (!result.isSuccess || result.data == null) {
//       throw Exception(
//         result.errorMessage ?? "Failed to fetch bill details",
//       );
//     }
//
//     return BillDetails.fromJson(
//       result.data as Map<String, dynamic>,
//     );
//   }
//
//   // DELETE BILL
//
//
//   Future<bool> deleteBill(String billNumber) async {
//     final ResponseResult result = await _apiService.delete(
//       path: "/bill/entry/delete/$billNumber",
//     );
//
//     if (!result.isSuccess) {
//       throw Exception(
//         result.errorMessage ?? "Failed to delete bill",
//       );
//     }
//
//     return true;
//   }
//
//   // ADD BILL
//
//
//   Future<bool> addBill({
//     required AddBillRequest request,
//     List<File> images = const [],
//   }) async {
//     final Map<String, dynamic> payload = request.toJson();
//
//     payload["billItems"] =
//         request.items?.map((e) => e.toJson()).toList() ?? [];
//
//     final formData = FormData();
//
//     formData.fields.add(
//       MapEntry(
//         "payload",
//         jsonEncode(payload),
//       ),
//     );
//
//     for (final image in images) {
//       formData.files.add(
//         MapEntry(
//           "images",
//           await MultipartFile.fromFile(
//             image.path,
//             filename: image.path
//                 .split('/')
//                 .last,
//           ),
//         ),
//       );
//     }
//
//     final ResponseResult result = await _apiService.post(
//       path: "/bill/entry/add",
//       data: formData,
//     );
//
//     if (!result.isSuccess) {
//       throw Exception(
//         result.errorMessage ?? "Failed to add bill",
//       );
//     }
//
//     return true;
//   }
//
//   // UPDATE BILL
//
//
//   Future<bool> updateBill({
//     required num id,
//     required AddBillRequest request,
//     List<String> existingImageKeys = const [],
//     List<File> images = const [],
//   }) async {
//     final Map<String, dynamic> payload = request.toJson();
//
//     payload["billItems"] =
//         request.items?.map((e) => e.toJson()).toList() ?? [];
//
//     payload["existingImageKeys"] = existingImageKeys;
//
//     final formData = FormData();
//
//     formData.fields.add(
//       MapEntry(
//         "payload",
//         jsonEncode(payload),
//       ),
//     );
//
//     for (final image in images) {
//       formData.files.add(
//         MapEntry(
//           "images",
//           await MultipartFile.fromFile(
//             image.path,
//             filename: image.path.split('/').last,
//           ),
//         ),
//       );
//     }
//
//     final ResponseResult result = await _apiService.patch(
//       path: "/bill/entry/update/$id",
//       data: formData,
//     );
//
//     if (!result.isSuccess) {
//       throw Exception(
//         result.errorMessage ?? "Failed to update bill",
//       );
//     }
//
//     return true;
//   }
// }