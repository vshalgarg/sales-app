import 'dart:convert';
import 'dart:io';

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
    final payload = {
      'id': request.id,
      'billNumber': request.billNumber,
      'date': request.date,
      'receivedDate': request.receivedDate,
      'order': request.order,
      'supplierId': request.supplierId,
      'customerId': request.customerId,
      'transport': request.transport,
      'lrNumber': request.lrNumber,
      'remarks': request.remarks,
      'billAmount': request.billAmount,
      'taxableValue': request.taxableValue,
      'billItems': request.items?.map((e) => e.toJson()).toList() ?? [],
    };

    MediaType getMediaType(String path) {
      final extension = path.split('.').last.toLowerCase();

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          return MediaType('image', 'jpeg');

        case 'png':
          return MediaType('image', 'png');

        case 'webp':
          return MediaType('image', 'webp');

        case 'pdf':
          return MediaType('application', 'pdf');

        case 'svg':
          return MediaType('image', 'svg+xml');

        default:
          return MediaType('application', 'octet-stream');
      }
    }

    final formData = FormData();

    // JSON payload
    formData.files.add(
      MapEntry(
        "payload",
        MultipartFile.fromString(
          jsonEncode(payload),
          filename: "payload.json",
          contentType: MediaType("application", "json"),
        ),
      ),
    );

    // Attachments
    for (final image in images) {
      final extension = image.path.split('.').last.toLowerCase();

      MediaType contentType;

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = MediaType('image', 'jpeg');
          break;

        case 'png':
          contentType = MediaType('image', 'png');
          break;

        case 'webp':
          contentType = MediaType('image', 'webp');
          break;

        case 'pdf':
          contentType = MediaType('application', 'pdf');
          break;

        case 'svg':
          contentType = MediaType('image', 'svg+xml');
          break;

        default:
          contentType = MediaType('application', 'octet-stream');
      }

      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
            contentType: contentType,
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
    final payload = {
      'date': request.date,
      'receivedDate': request.receivedDate,
      'order': request.order,
      'supplierId': request.supplierId,
      'customerId': request.customerId,
      'transport': request.transport,
      'lrNumber': request.lrNumber,
      'remarks': request.remarks,
      'taxableValue': request.taxableValue,
      'billAmount': request.billAmount,

      'billItems': request.items?.map((item) {
        return {
          'pieces': item.pieces,
          'discountPercent': item.discountPercent,
          'gstPercent': item.gstPercent,
          'grossAmount': item.grossAmount,
          'discountAmount': item.discountAmount,
          'addOnAmount': item.addOnAmount,
          'ecrAmount': item.ecrAmount,
          'gstAmount': item.gstAmount,
        };
      }).toList() ?? [],

      'existingImageKeys': existingImageKeys,
    };

    final formData = FormData();

    formData.files.add(
      MapEntry(
        'data',
        MultipartFile.fromString(
          jsonEncode(payload),
          filename: 'blob',
          contentType: DioMediaType(
            'application',
            'json',
          ),
        ),
      ),
    );

    for (final image in images) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    print('========== UPDATE BILL ==========');
    print(jsonEncode(payload));
    print('Image count: ${images.length}');

    final result = await _api.patch<Map<String, dynamic>>(
      path: '$_billEntry/update/$id',
      data: formData,
    );

    print('Status : ${result.statusCode}');
    print('Response : ${result.data}');
    print('Error : ${result.errorMessage}');

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? 'Failed to update bill',
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
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