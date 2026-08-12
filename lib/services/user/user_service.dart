import 'package:hisabio/model_classes/common/api_response.dart';
import 'package:hisabio/model_classes/user/add_user_request.dart';
import 'package:hisabio/model_classes/user/user.dart';
import 'package:hisabio/network/api_service.dart';
import 'package:hisabio/network/response_result.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  static const String _user = "/user";
  static const String _users = "/users";

  // GET USERS

  Future<ResponseResult<List<User>>> getUsers() async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_users/get",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final List<User> users =
    (result.data!["users"] as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();
    for (final user in users) {
      print("${user.username} -> ${user.role}");
    }
    return ResponseResult.success(
      users,
      result.statusCode,
    );
  }

  // SEARCH USERS

  Future<ResponseResult<List<User>>> searchUsers({
    required String keyword,
  }) async {
    final result = await _api.get<List<dynamic>>(
      path: "$_users/search",
      queryParameters: {
        "keyword": keyword,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Something went wrong",
        statusCode: result.statusCode,
      );
    }

    final List<User> users = result.data!
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();

    return ResponseResult.success(
      users,
      result.statusCode,
    );
  }

  // ADD USER

  Future<ResponseResult<ApiResponse>> addUser(
      AddUserRequest request,
      ) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_user/add",
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

  // UPDATE PASSWORD

  Future<ResponseResult<ApiResponse>> updatePassword({
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.put<Map<String, dynamic>>(
      path: "/admin/change/password",
      data: body,
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

  // DELETE USER

  Future<ResponseResult<ApiResponse>> deleteUser(int id) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_user/delete/$id",
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