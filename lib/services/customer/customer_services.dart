import 'dart:developer';
import '../../../../model_classes/common/paginated_response.dart';
import '../../../../network/api_service.dart';
import '../../../../network/response_result.dart';
import '../../model_classes/common/api_response.dart';
import '../../model_classes/customer/add_customer_request.dart';
import '../../model_classes/customer/customer.dart';
import '../../model_classes/customer/customer_details.dart';

class CustomerService {
  final ApiService _api;

  CustomerService(this._api);

  static const String _customer = "/customer";
  static const String _customers = "/customers";

  Future<ResponseResult<PaginatedResponse<Customer>>> getCustomers({
    required int page,
    required int size,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_customers/get",
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

    final customers = PaginatedResponse<Customer>.fromJson(
      result.data!,
      Customer.fromJson,
    );

    return ResponseResult.success(
      customers,
      result.statusCode,
    );
  }

  Future<ResponseResult<PaginatedResponse<Customer>>> searchCustomers({
    required String keyword,
    required int page,
    required int size,
  }) async {

    final result = await _api.get<Map<String, dynamic>>(
      path: "$_customers/search",
      queryParameters: {
        "keyword": keyword,
        "page": page,
        "size": size,
        "sortBy": "customerName",
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

    final customers = PaginatedResponse<Customer>.fromJson(
      result.data!,
      Customer.fromJson,
    );

    return ResponseResult.success(
      customers,
      result.statusCode,
    );
  }

  Future<ResponseResult<CustomerDetailsResponse>> getCustomerById(
      int id) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_customers/get/id/$id",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      CustomerDetailsResponse.fromJson(result.data!),
      result.statusCode,
    );
  }
  Future<ResponseResult<ApiResponse>> addCustomer(
      AddCustomerRequest request) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_customer/add",
      data: request.toJson(),
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }
    final json = result.data!;
    if (json["code"] != null) {
      return ResponseResult.error(
        errorMessage: json["message"] ?? "Unable to add customer",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse(
        success: true,
        message: json["message"] ?? "Customer added successfully",
        data: json["data"],
      ),
      result.statusCode,
    );
  }

  Future<ResponseResult<ApiResponse>> updateCustomer({
    required int id,
    required AddCustomerRequest request,
  }) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_customers/update/id/$id",
      data: request.toUpdateJson(),
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

  Future<ResponseResult<ApiResponse>> deleteCustomer(String code) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_customer/delete",
      data: {
        "customerCode": code,
      },
    );
    log("ERROR: ${result.errorMessage}");


    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final json = result.data!;

    if (json["code"] != null) {
      return ResponseResult.error(
        errorMessage: json["message"] ?? "Delete failed",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse(
        success: true,
        message: json["message"] ?? "Customer deleted successfully",
      ),
      result.statusCode,
    );
  }
}