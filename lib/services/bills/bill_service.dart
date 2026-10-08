import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
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

 MediaType _getMediaType(String path) {
  final extension = path.split('.').last.toLowerCase();

  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return MediaType('image', 'jpeg');

    case 'png':
      return MediaType('image', 'png');

    case 'webp':
      return MediaType('image', 'webp');

    case 'heic':
      return MediaType('image', 'heic');

    case 'heif':
      return MediaType('image', 'heif');

    case 'pdf':
      return MediaType('application', 'pdf');

    case 'svg':
      return MediaType('image', 'svg+xml');

    default:
      return MediaType('application', 'octet-stream');
  }
}


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
  debugPrint("🔥🔥🔥 ADD BILL SERVICE RUNNING 🔥🔥🔥");

  final formData = FormData();

  final billPayload = request.toJson();

  billPayload["billItems"] =
      request.items?.map((e) => e.toJson()).toList() ?? [];


  debugPrint("========== BILL PAYLOAD ==========");
     debugPrint(jsonEncode(billPayload));
  debugPrint("==================================");

formData.files.add(
  MapEntry(
    "payload",
    MultipartFile.fromString(
      jsonEncode(billPayload),
      filename: "blob",
      contentType: MediaType(
        "application",
        "json",
      ),
    ),
  ),
);
debugPrint("========== BILL IMAGES ==========");
debugPrint("Number of images: ${images.length}");

for (final image in images) {
  final file = File(image.path);

  debugPrint("========== BILL IMAGE DEBUG ==========");
  debugPrint("IMAGE PATH: ${image.path}");
  debugPrint("IMAGE EXISTS: ${await file.exists()}");

  if (await file.exists()) {
    debugPrint("IMAGE SIZE: ${await file.length()} bytes");
  }

  debugPrint(
    "IMAGE EXTENSION: ${image.path.split('.').last.toLowerCase()}",
  );
  debugPrint("======================================");

  if (!await file.exists()) {
    debugPrint("❌ iOS IMAGE FILE DOES NOT EXIST");
    continue;
  }

  final fileName = image.path.split(RegExp(r'[/\\\\]')).last;

  formData.files.add(
    MapEntry(
      "images",
      await MultipartFile.fromFile(
        image.path,
        filename: fileName,
        contentType: _getMediaType(image.path),
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
    final billPayload = request.toJson();

    billPayload["billItems"] =
        request.items?.map((e) => e.toJson()).toList() ?? [];

    billPayload["existingImageKeys"] = existingImageKeys;

    final formData = FormData();

formData.files.add(
  MapEntry(
    "payload",
    MultipartFile.fromString(
      jsonEncode(billPayload),
      filename: "blob",
      contentType: MediaType(
        "application",
        "json",
      ),
    ),
  ),
);

debugPrint("========== UPDATE BILL IMAGES ==========");
debugPrint("Number of images: ${images.length}");

for (final image in images) {
  final file = File(image.path);

  debugPrint("========== UPDATE BILL IMAGE DEBUG ==========");
  debugPrint("IMAGE PATH: ${image.path}");
  debugPrint("IMAGE EXISTS: ${await file.exists()}");

  if (await file.exists()) {
    debugPrint("IMAGE SIZE: ${await file.length()} bytes");
  }

  final extension = image.path.split('.').last.toLowerCase();

  debugPrint("IMAGE EXTENSION: $extension");
  debugPrint("IMAGE MIME TYPE: ${_getMediaType(image.path)}");
  debugPrint("============================================");

  if (!await file.exists()) {
    debugPrint("❌ iOS IMAGE FILE DOES NOT EXIST");
    continue;
  }

  final fileName =
      image.path.split(RegExp(r'[/\\\\]')).last;

  final multipartFile = await MultipartFile.fromFile(
    image.path,
    filename: fileName,
    contentType: _getMediaType(image.path),
  );

  debugPrint("MULTIPART FILE NAME: $fileName");
  debugPrint(
    "MULTIPART CONTENT TYPE: ${multipartFile.contentType}",
  );

  formData.files.add(
    MapEntry(
      "images",
      multipartFile,
    ),
  );
}

debugPrint(
  "TOTAL FORM DATA FILES: ${formData.files.length}",
);

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
