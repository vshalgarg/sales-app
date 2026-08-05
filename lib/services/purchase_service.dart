import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../../model_classes/common/api_response.dart';
import '../../model_classes/common/paginated_response.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../network/api_service.dart';
import '../../network/response_result.dart';
import '../model_classes/purchases/add_purchase_request.dart';
import '../model_classes/purchases/get_purchase_model.dart';
import '../model_classes/purchases/purchase.dart';

class PurchaseService {
  final ApiService _api;

  PurchaseService(this._api);

  static const String _purchase = "/purchase";

  ///---------------------------------------------------------------
  /// SEARCH PURCHASES
  ///---------------------------------------------------------------

  Future<ResponseResult<PaginatedResponse<Purchase>>> searchPurchases({
    String? fromDate,
    String? toDate,
    num? supplierId,
    num? customerId,
    num? staffId,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String, dynamic>{
      if (fromDate != null && fromDate.isNotEmpty)
        "fromDate": fromDate,
      if (toDate != null && toDate.isNotEmpty)
        "toDate": toDate,
      if (supplierId != null)
        "supplierId": supplierId,
      if (customerId != null)
        "customerId": customerId,
      if (staffId != null)
        "staffId": staffId,
      "page": page,
      "size": size,
    };

    final result = await _api.get<Map<String, dynamic>>(
      path: "$_purchase/entries/search",
      queryParameters: query,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to fetch purchases",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      PaginatedResponse<Purchase>.fromJson(
        result.data!,
            (json) => Purchase.fromJson(json),
      ),
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// PURCHASE DETAILS
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> getPurchaseDetails(
      num id,
      ) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_purchase/get/details/$id",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ??
            "Failed to fetch purchase details",
        statusCode: result.statusCode,
      );
    }

    final response = ApiResponse.fromJson(result.data!);

    return ResponseResult.success(
      ApiResponse(
        success: response.success,
        message: response.message,
        data: response.data != null
            ? PurchaseDetails.fromJson(
          response.data as Map<String, dynamic>,
        )
            : null,
      ),
      result.statusCode,
    );
  }
  ///---------------------------------------------------------------
  /// ADD PURCHASE
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> addPurchase({
    required AddPurchaseRequest request,
    required List<List<PlatformFile>> uploadedFiles,
    required List<EntriesModel?> selectedSuppliers,
  }) async {
    final formData = FormData();

    // JSON Payload
    formData.files.add(
      MapEntry(
        "payload",
        MultipartFile.fromBytes(
          utf8.encode(jsonEncode(request.toJson())),
          filename: "payload.json",
          contentType: DioMediaType(
            "application",
            "json",
          ),
        ),
      ),
    );

    // Images
    for (int i = 0; i < uploadedFiles.length; i++) {
      for (final file in uploadedFiles[i]) {
        if (file.path == null) continue;

        formData.files.add(
          MapEntry(
            "supplierImages",
            await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          ),
        );
      }
    }

    print("========== ADD PURCHASE ==========");
    print("Payload : ${jsonEncode(request.toJson())}");

    final result = await _api.post<Map<String, dynamic>>(
      path: "$_purchase/entry/add",
      data: formData,
    );

    print("Status : ${result.statusCode}");
    print("Response : ${result.data}");
    print("Error : ${result.errorMessage}");

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to add purchase",
        statusCode: result.statusCode,
      );
    }

    final response = ApiResponse.fromJson(result.data!);

    return ResponseResult.success(
      response,
      result.statusCode,
    );
  }
  ///---------------------------------------------------------------
  /// UPDATE PURCHASE
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> updatePurchase({
    required num id,
    required String date,
    required num customerId,
    required num supplierId,
    required num staffId,
    required String remarks,
    required List<String> existingImageKeys,
    required List<File> supplierImages,
  }) async {
    final formData = FormData();

    final payload = {
      "date": date,
      "staffId": staffId,
      "customerId": customerId,
      "supplierId": supplierId,
      "remarks": remarks,
      "existingImageKeys": existingImageKeys,
    };

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

    for (final image in supplierImages) {
      formData.files.add(
        MapEntry(
          "supplier_${supplierId}_images",
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    print("========== UPDATE PURCHASE ==========");
    print(jsonEncode(payload));

    final result = await _api.patch<Map<String, dynamic>>(
      path: "$_purchase/entry/update/$id",
      data: formData,
    );

    print("Status : ${result.statusCode}");
    print("Response : ${result.data}");
    print("Error : ${result.errorMessage}");

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to update purchase",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  ///---------------------------------------------------------------
  /// DELETE PURCHASE
  ///---------------------------------------------------------------

  Future<ResponseResult<ApiResponse>> deletePurchase(
      num id,
      ) async {
    final result = await _api.delete<Map<String, dynamic>>(
      path: "$_purchase/entry/delete/$id",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Failed to delete purchase",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }
}