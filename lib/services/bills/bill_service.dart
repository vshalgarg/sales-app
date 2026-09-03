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