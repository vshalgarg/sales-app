import '../../../../../model_classes/common/paginated_response.dart';
import '../../../../../network/api_service.dart';
import '../../../../../network/response_result.dart';
import '../../../model_classes/common/api_response.dart';
import '../../model_classes/credits/add_credit_request.dart';
import '../../model_classes/credits/credit.dart';

class CreditService {
  final ApiService _api;

  CreditService(this._api);

  static const String _creditEntry = "/credit/entry";
  static const String _creditEntries = "/credit/entries";

  Future<ResponseResult<PaginatedResponse<Credit>>> getCredits({
    required int page,
    required int size,
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_creditEntries/search",
      queryParameters: {
        "page": page,
        "size": size,
        if (fromDate != null && fromDate.isNotEmpty)
          "fromDate": fromDate,
        if (toDate != null && toDate.isNotEmpty)
          "toDate": toDate,
        "supplierId": ?supplierId,
        "customerId": ?customerId,
      }
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    if (result.data?["code"] != null) {
      return ResponseResult.error(
        errorMessage:
        result.data?["message"] ?? "Failed to fetch credits",
        statusCode: result.statusCode,
      );
    }

    final credits = PaginatedResponse<Credit>.fromJson(
      result.data!,
      Credit.fromJson,
    );

    return ResponseResult.success(
      credits,
      result.statusCode,
    );
  }

Future<ResponseResult<PaginatedResponse<Credit>>> searchCredits({
  required String keyword,
  required int page,
  required int size,
  String? fromDate,
  String? toDate,
  int? supplierId,
  int? customerId,
}) async {
  final result = await _api.get<Map<String, dynamic>>(
    path: "$_creditEntries/search",
    queryParameters: {
      "keyword": keyword,
      "page": page,
      "size": size,
      if (fromDate != null && fromDate.isNotEmpty)
        "fromDate": fromDate,
      if (toDate != null && toDate.isNotEmpty)
        "toDate": toDate,
      "supplierId": ?supplierId,
      "customerId": ?customerId,
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
      errorMessage:
      result.data?["message"] ?? "Search failed",
      statusCode: result.statusCode,
    );
  }

  final credits = PaginatedResponse<Credit>.fromJson(
    result.data!,
    Credit.fromJson,
  );

  return ResponseResult.success(
    credits,
    result.statusCode,
  );
}

  Future<ResponseResult<ApiResponse>> updateCredit({
    required int id,
    required AddCreditRequest request,
  }) async {
    final result = await _api.patch<Map<String, dynamic>>(
      path: "$_creditEntry/update/$id",
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

  Future<ResponseResult<ApiResponse>> addCredit({
    required AddCreditRequest request,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_creditEntry/add",
      data: request.toJson(),
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage:
        result.errorMessage ?? "Something went wrong",
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

Future<ResponseResult<ApiResponse>> deleteCredit(
    int id,
    ) async {
  final result = await _api.delete<Map<String, dynamic>>(
    path: "$_creditEntry/delete/$id",
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