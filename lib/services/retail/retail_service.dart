import '../../../../../model_classes/common/paginated_response.dart';
import '../../../../../network/api_service.dart';
import '../../../../../network/response_result.dart';
import '../../model_classes/common/api_response.dart';
import '../../model_classes/retailers/add_deposit_model.dart';
import '../../model_classes/retailers/retail_deposit_history_model.dart';
import '../../model_classes/retailers/retail_details.dart';
import '../../model_classes/retailers/retail_model.dart';

class RetailService {
  final ApiService _api;

  RetailService(this._api);

  static const String _retail = "/retail";
  static const String _retailSuppliers = "/retail-suppliers";
  static const String _retailSupplierDeposits =
      "/retail-supplier-deposits";

  Future<ResponseResult<PaginatedResponse<Retail>>> searchRetails({
    String? fromDate,
    String? toDate,
    int? customerId,
    int? staffId,
    int? supplierId,
    required int page,
    required int size,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_retail/search",
      queryParameters: {
        "page": page,
        "size": size,

        if (fromDate != null && fromDate.isNotEmpty)
          "fromDate": fromDate,

        if (toDate != null && toDate.isNotEmpty)
          "toDate": toDate,

        if (customerId != null)
          "customerId": customerId,

        if (staffId != null)
          "staffId": staffId,

        if (supplierId != null)
          "supplierId": supplierId,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final response = result.data;

    if (response == null) {
      return ResponseResult.error(
        errorMessage: "Retail response is empty",
        statusCode: result.statusCode,
      );
    }

// API can return HTTP 200 with an application-level error.
    if (response["code"] != null && response["code"] != 200) {
      return ResponseResult.error(
        errorMessage:
        response["message"]?.toString() ?? "Failed to load retails",
        statusCode: response["code"] as int?,
      );
    }

    if (response["data"] == null) {
      return ResponseResult.error(
        errorMessage: "Retail data is missing",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      PaginatedResponse<Retail>.fromJson(
        response["data"],
        Retail.fromJson,
      ),
      result.statusCode,
    );
  }

  Future<ResponseResult<RetailDetails>> getRetailDetails(int retailId) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_retail/get/$retailId",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      RetailDetails.fromJson(result.data!["data"]),
      result.statusCode,
    );
  }

  Future<ResponseResult<ApiResponse>> createRetail(
      Map<String, dynamic> body) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_retail/create",
      data: body,
    );
    if (result.isFailure) {
      return ResponseResult.error(
          errorMessage: result.errorMessage ?? "Something went wrong",
          statusCode: result.statusCode);
    }
    return ResponseResult.success(
        ApiResponse.fromJson(result.data!), result.statusCode);
  }

  Future<ResponseResult<ApiResponse>> updateRetail({
    required int retailId,
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_retail/$retailId",
      data: body,
    );
    if (result.isFailure) {
      return ResponseResult.error(
          errorMessage: result.errorMessage ?? "Something went wrong",
          statusCode: result.statusCode);
    }
    return ResponseResult.success(
        ApiResponse.fromJson(result.data!), result.statusCode);
  }

  Future<ResponseResult<ApiResponse>> deleteRetail(int retailId) async {
    final result = await _api.delete<Map<String, dynamic>>(
      path: "$_retail/$retailId",
    );
    if (result.isFailure) {
      return ResponseResult.error(
          errorMessage: result.errorMessage ?? "Something went wrong",
          statusCode: result.statusCode);
    }
    return ResponseResult.success(
        ApiResponse.fromJson(result.data!), result.statusCode);
  }

  Future<ResponseResult<ApiResponse>> addRetailSupplier(
      Map<String, dynamic> body) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: _retailSuppliers,
      data: body,
    );
    if (result.isFailure) {
      return ResponseResult.error(
          errorMessage: result.errorMessage ?? "Something went wrong",
          statusCode: result.statusCode);
    }
    return ResponseResult.success(
        ApiResponse.fromJson(result.data!), result.statusCode);
  }

  Future<ResponseResult<ApiResponse>> updateRetailSupplier({
    required int retailSupplierId,
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_retailSuppliers/$retailSupplierId",
      data: body,
    );
    if (result.isFailure) {
      return ResponseResult.error(
          errorMessage: result.errorMessage ?? "Something went wrong",
          statusCode: result.statusCode);
    }
    return ResponseResult.success(
        ApiResponse.fromJson(result.data!), result.statusCode);
  }

  Future<ResponseResult<ApiResponse>> deleteRetailSupplier(
      int retailSupplierId) async {
    final result = await _api.delete<Map<String, dynamic>>(
      path: "$_retailSuppliers/$retailSupplierId",
    );
    if (result.isFailure) {
      return ResponseResult.error(
          errorMessage: result.errorMessage ?? "Something went wrong",
          statusCode: result.statusCode);
    }
    return ResponseResult.success(
        ApiResponse.fromJson(result.data!), result.statusCode);
  }

  Future<ResponseResult<ApiResponse>> addDeposit(
      AddDepositModel request,
      ) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: _retailSupplierDeposits,
      data: request.toJson(),
      showLoader: false,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final response = result.data;

    if (response == null) {
      return ResponseResult.error(
        errorMessage: "Deposit response is empty",
        statusCode: result.statusCode,
      );
    }

    if (response["code"] != null && response["code"] != 200) {
      return ResponseResult.error(
        errorMessage:
        response["message"]?.toString() ?? "Failed to add deposit",
        statusCode: response["code"] as int?,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(response),
      result.statusCode,
    );
  }

  Future<ResponseResult<List<RetailDepositHistoryModel>>> getDepositHistory(
      int retailId,
      ) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_retail/$retailId/deposits",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final history = (result.data!["data"] as List)
        .map(
          (e) => RetailDepositHistoryModel.fromJson(
        e as Map<String, dynamic>,
      ),
    )
        .toList();

    return ResponseResult.success(
      history,
      result.statusCode,
    );
  }
}