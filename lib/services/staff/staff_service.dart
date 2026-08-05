import 'package:hisabio/model_classes/staff/add_staff_request.dart';
import '../../../../model_classes/common/paginated_response.dart';
import '../../../../network/api_service.dart';
import '../../../../network/response_result.dart';

import '../../model_classes/common/api_response.dart';
import '../../model_classes/staff/staff.dart';
import '../../model_classes/staff/staff_details.dart';

class StaffService {
  final ApiService _api;

  StaffService(this._api);

  static const String _staff = "/staff";
  static const String _staffs = "/staffs";


  // GET STAFFS


  Future<ResponseResult<PaginatedResponse<Staff>>> getStaffs({
    required int page,
    required int size,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_staffs/get",
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

    final staffs = PaginatedResponse<Staff>.fromJson(
      result.data!,
      Staff.fromJson,
    );

    return ResponseResult.success(
      staffs,
      result.statusCode,
    );
  }


  // SEARCH STAFF


  Future<ResponseResult<PaginatedResponse<Staff>>> searchStaffs({
    required String keyword,
    required int page,
    required int size,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_staffs/search",
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

    final staffs = PaginatedResponse<Staff>.fromJson(
      result.data!,
      Staff.fromJson,
    );

    return ResponseResult.success(
      staffs,
      result.statusCode,
    );
  }


  // GET STAFF DETAILS


  Future<ResponseResult<StaffDetails>> getStaffById(
      int id) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_staff/$id",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      StaffDetails.fromJson(result.data!),
      result.statusCode,
    );
  }


  // ADD STAFF


  Future<ResponseResult<ApiResponse>> addStaff(
      AddStaffRequest request) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_staff/add",
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


  // UPDATE STAFF


  Future<ResponseResult<ApiResponse>> updateStaff({
    required int id,
    required AddStaffRequest request,
  }) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_staff/$id",
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


  // DELETE STAFF


  Future<ResponseResult<ApiResponse>> deleteStaff(
      int id) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "$_staff/delete",
      data: {
        "staffId": id,
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