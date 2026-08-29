import 'dart:developer';

import '../../../../model_classes/common/paginated_response.dart';
import '../../../../network/api_service.dart';
import '../../../../network/response_result.dart';
import '../../model_classes/Transport/add_transport_request.dart';
import '../../model_classes/common/api_response.dart';
import '../../model_classes/Transport/transport.dart';
import '../../model_classes/transport/transport_details.dart';

class TransportService {
  final ApiService _api;

  TransportService(this._api);

 // static const String _transport = "/transport";
  static const String _transports = "/transports";

  // GET TRANSPORTS

  Future<ResponseResult<PaginatedResponse<Transport>>> getTransports({
    required int page,
    required int size,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_transports/get/all",
      queryParameters: {
        "page": page,
        "size": size,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final transports = PaginatedResponse<Transport>.fromJson(
      result.data!,
      Transport.fromJson,
    );

    return ResponseResult.success(
      transports,
      result.statusCode,
    );
  }

  // SEARCH TRANSPORTS

  Future<ResponseResult<PaginatedResponse<Transport>>> searchTransports({
    required String keyword,
    required int page,
    required int size,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_transports/search",
      queryParameters: {
        "keyword": keyword,
        "page": page,
        "size": size,
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

    final transports = PaginatedResponse<Transport>.fromJson(
      result.data!,
      Transport.fromJson,
    );

    return ResponseResult.success(
      transports,
      result.statusCode,
    );
  }

  // GET TRANSPORT DETAILS

  Future<ResponseResult<TransportDetails>> getTransportById(int id) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_transports/$id",
    );

    log("GET TRANSPORT DETAILS RESPONSE:");

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final json = result.data!;
    final transportJson =
    json["data"] is Map<String, dynamic>
        ? json["data"] as Map<String, dynamic>
        : json;

    return ResponseResult.success(
      TransportDetails.fromJson(transportJson),
      result.statusCode,
    );
  }

  // ADD TRANSPORT

  Future<ResponseResult<ApiResponse>> addTransport(
      AddTransportRequest request,
      ) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_transports/add",
      data: request.toJson(),
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

  // UPDATE TRANSPORT

  Future<ResponseResult<ApiResponse>> updateTransport({
    required int id,
    required AddTransportRequest request,
  }) async {
    log("UPDATE REQUEST");
    log(request.toJson().toString());
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_transports/update/$id",
      data: request.toJson(),
    );
    log("UPDATE RESPONSE");
    log(request.toJson().toString());
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

  // DELETE TRANSPORT

  Future<ResponseResult<ApiResponse>> deleteTransport(int id) async {
    final result = await _api.delete<Map<String, dynamic>>(
      path: "$_transports/delete/$id",
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