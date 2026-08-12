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
        if (fromDate != null && fromDate.isNotEmpty) "fromDate": fromDate,
        if (toDate != null && toDate.isNotEmpty) "toDate": toDate,
        if (customerId != null) "customerId": customerId,
        if (staffId != null) "staffId": staffId,
        if (supplierId != null) "supplierId": supplierId,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      PaginatedResponse<Retail>.fromJson(
        result.data!["data"],
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
      AddDepositModel request) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: _retailSupplierDeposits,
      data: request.toJson(),
    );
    if (result.isFailure) {
      return ResponseResult.error(
          errorMessage: result.errorMessage ?? "Something went wrong",
          statusCode: result.statusCode);
    }
    return ResponseResult.success(
        ApiResponse.fromJson(result.data!), result.statusCode);
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











// import '../../../../model_classes/common/paginated_response.dart';
// import '../../../../network/api_service.dart';
// import '../../../../network/response_result.dart';
// import '../model_classes/common/api_response.dart';
// import '../model_classes/retailers/add_retail_request.dart';
// import '../model_classes/retailers/retail_model.dart';
//
// class RetailService {
//   final ApiService _api;
//
//   RetailService(this._api);
//
//   static const String _retail = "/retail";
//   static const String _retailSuppliers = "/retail-suppliers";
//   static const String _retailSupplierDeposits =
//       "/retail-supplier-deposits";
//
//   // SEARCH RETAILS
//
//   Future<ResponseResult<PaginatedResponse<Retail>>> searchRetails({
//     String? fromDate,
//     String? toDate,
//     int? customerId,
//     int? staffId,
//     int? supplierId,
//     required int page,
//     required int size,
//   }) async {
//     final result = await _api.get<Map<String, dynamic>>(
//       path: "$_retail/search",
//       queryParameters: {
//         "page": page,
//         "size": size,
//         if (fromDate != null && fromDate.isNotEmpty) "fromDate": fromDate,
//         if (toDate != null && toDate.isNotEmpty) "toDate": toDate,
//         if (customerId != null) "customerId": customerId,
//         if (staffId != null) "staffId": staffId,
//         if (supplierId != null) "supplierId": supplierId,
//       },
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final retails = PaginatedResponse<Retail>.fromJson(
//       result.data!,
//       Retail.fromJson,
//     );
//
//     return ResponseResult.success(
//       retails,
//       result.statusCode,
//     );
//   }
//
//   // GET RETAIL DETAILS
//
//   Future<ResponseResult<RetailDetails>> getRetailDetails(
//       int retailId) async {
//     final result = await _api.get<Map<String, dynamic>>(
//       path: "$_retail/get/$retailId",
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       RetailDetails.fromJson(result.data!),
//       result.statusCode,
//     );
//   }
//
//   // CREATE RETAIL
//
//   Future<ResponseResult<ApiResponse>> createRetail(
//       AddRetailRequest request,
//       ) async {
//     final result = await _api.post<Map<String, dynamic>>(
//       path: "$_retail/create",
//       data: request.toJson(),
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final response = ApiResponse.fromJson(result.data!);
//
//     if (!response.success) {
//       return ResponseResult.error(
//         errorMessage: response.message,
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       response,
//       result.statusCode,
//     );
//   }
//
//   // UPDATE RETAIL
//
//   Future<ResponseResult<ApiResponse>> updateRetail({
//     required int retailId,
//     required UpdateRetailRequest request,
//   }) async {
//     final result = await _api.put<Map<String, dynamic>>(
//       path: "$_retail/$retailId",
//       data: request.toJson(),
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final response = ApiResponse.fromJson(result.data!);
//
//     if (!response.success) {
//       return ResponseResult.error(
//         errorMessage: response.message,
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       response,
//       result.statusCode,
//     );
//   }
//
//   // DELETE RETAIL
//
//   Future<ResponseResult<ApiResponse>> deleteRetail(
//       int retailId,
//       ) async {
//     final result = await _api.delete<Map<String, dynamic>>(
//       path: "$_retail/$retailId",
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final response = ApiResponse.fromJson(result.data!);
//
//     if (!response.success) {
//       return ResponseResult.error(
//         errorMessage: response.message,
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       response,
//       result.statusCode,
//     );
//   }
//   // ADD RETAIL SUPPLIER
//
//   Future<ResponseResult<ApiResponse>> addRetailSupplier(
//       AddSupplierRequest request,
//       ) async {
//     final result = await _api.post<Map<String, dynamic>>(
//       path: _retailSuppliers,
//       data: request.toJson(),
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final response = ApiResponse.fromJson(result.data!);
//
//     if (!response.success) {
//       return ResponseResult.error(
//         errorMessage: response.message,
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       response,
//       result.statusCode,
//     );
//   }
//
//   // UPDATE RETAIL SUPPLIER
//
//   Future<ResponseResult<ApiResponse>> updateRetailSupplier({
//     required int retailSupplierId,
//     required UpdateSupplierRequest request,
//   }) async {
//     final result = await _api.put<Map<String, dynamic>>(
//       path: "$_retailSuppliers/$retailSupplierId",
//       data: request.toJson(),
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final response = ApiResponse.fromJson(result.data!);
//
//     if (!response.success) {
//       return ResponseResult.error(
//         errorMessage: response.message,
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       response,
//       result.statusCode,
//     );
//   }
//
//   // DELETE RETAIL SUPPLIER
//
//   Future<ResponseResult<ApiResponse>> deleteRetailSupplier(
//       int retailSupplierId,
//       ) async {
//     final result = await _api.delete<Map<String, dynamic>>(
//       path: "$_retailSuppliers/$retailSupplierId",
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final response = ApiResponse.fromJson(result.data!);
//
//     if (!response.success) {
//       return ResponseResult.error(
//         errorMessage: response.message,
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       response,
//       result.statusCode,
//     );
//   }
//
//   // ADD DEPOSIT
//
//   Future<ResponseResult<ApiResponse>> addDeposit(
//       AddDepositRequest request,
//       ) async {
//     final result = await _api.post<Map<String, dynamic>>(
//       path: _retailSupplierDeposits,
//       data: request.toJson(),
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final response = ApiResponse.fromJson(result.data!);
//
//     if (!response.success) {
//       return ResponseResult.error(
//         errorMessage: response.message,
//         statusCode: result.statusCode,
//       );
//     }
//
//     return ResponseResult.success(
//       response,
//       result.statusCode,
//     );
//   }
//
//   // GET DEPOSIT HISTORY
//
//   Future<ResponseResult<List<DepositHistory>>> getDepositHistory(
//       int retailId,
//       ) async {
//     final result = await _api.get<List<dynamic>>(
//       path: "$_retail/$retailId/deposits",
//     );
//
//     if (result.isFailure) {
//       return ResponseResult.error(
//         errorMessage: result.errorMessage ?? "Something went wrong",
//         statusCode: result.statusCode,
//       );
//     }
//
//     final history = result.data!
//         .map((e) => DepositHistory.fromJson(e))
//         .toList();
//
//     return ResponseResult.success(
//       history,
//       result.statusCode,
//     );
//   }
// }