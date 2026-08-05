import '../../../../model_classes/common/paginated_response.dart';
import '../../../../network/api_service.dart';
import '../../../../network/response_result.dart';
import '../../model_classes/supplier/add_supplier_request.dart';
import '../../model_classes/supplier/supplier.dart';
import '../../model_classes/supplier/supplier_details.dart';
import '../../model_classes/common/api_response.dart';

class SupplierService {
  final ApiService _api;

  SupplierService(this._api);

  static const String _supplier = "/supplier";
  static const String _suppliers = "/suppliers";


  // GET SUPPLIERS

  Future<ResponseResult<PaginatedResponse<Supplier>>> getSuppliers({
    required int page,
    required int size,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_suppliers/get",
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

    final suppliers = PaginatedResponse<Supplier>.fromJson(
      result.data!,
      Supplier.fromJson,
    );

    return ResponseResult.success(
      suppliers,
      result.statusCode,
    );
  }


  // SEARCH SUPPLIERS

  Future<ResponseResult<PaginatedResponse<Supplier>>> searchSuppliers({
    required String keyword,
    required int page,
    required int size,
  }) async {
    print("Searching: $keyword");
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_suppliers/search/v2",
      queryParameters: {
        "keyword": keyword,          // instead of "search"
        "page": page,
        "size": size,
        "sortBy": "supplierName",
        "sortDir": "asc",
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

    final suppliers = PaginatedResponse<Supplier>.fromJson(
      result.data!,
      Supplier.fromJson,
    );
    // final result = await _api.get<Map<String, dynamic>>(
    //   path: "$_suppliers/search/v2",
    //   queryParameters: {
    //     "search": keyword,
    //     "page": page,
    //     "size": size,
    //   },
    // );
    //
    // if (result.isFailure) {
    //   return ResponseResult.error(
    //     errorMessage: result.errorMessage ?? "Something went wrong",
    //     statusCode: result.statusCode,
    //   );
    // }
    //
    // final suppliers = PaginatedResponse<Supplier>.fromJson(
    //   result.data!,
    //   Supplier.fromJson,
    // );

    return ResponseResult.success(
      suppliers,
      result.statusCode,
    );
  }


  // GET SUPPLIER DETAILS

  Future<ResponseResult<SupplierDetailsResponse>> getSupplierById(
      int id) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_suppliers/get/id/$id",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      SupplierDetailsResponse.fromJson(result.data!),
      result.statusCode,
    );
  }


  // ADD SUPPLIER
  Future<ResponseResult<ApiResponse>> addSupplier(
      AddSupplierRequest request) async {

    final result = await _api.post<Map<String, dynamic>>(
      path: "$_supplier/add",
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


  // UPDATE SUPPLIER

  Future<ResponseResult<ApiResponse>> updateSupplier({
    required int id,
    required AddSupplierRequest request,
  }) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_suppliers/update/id/$id",
      data: request.toJson(),
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }


  // DELETE SUPPLIER

  Future<ResponseResult<ApiResponse>> deleteSupplier(String code) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_supplier/delete",
      data: {
        "code": code,
      },
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