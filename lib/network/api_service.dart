import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../utils/loading_service.dart';
import 'api_provider.dart';
import 'dio_exception.dart';
import 'response_result.dart';

class ApiService {
  final Dio _dio;

  ApiService(ApiProvider provider) : _dio = provider.getClient();

  // GET
  Future<ResponseResult<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool showLoader = false,
  }) async {
    return _request<T>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      responseType: responseType,
      showLoader: showLoader,
    );
  }

  // POST
  Future<ResponseResult<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool useFormData = false,
    bool showLoader = true,
  }) async {
    return _request<T>(
      method: 'POST',
      path: path,
      data: useFormData && data is Map<String, dynamic>
          ? FormData.fromMap(data)
          : data,
      queryParameters: queryParameters,
      headers: headers,
      showLoader: showLoader,
    );
  }

  //PUT

  Future<ResponseResult<T>> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool showLoader = true,
  }) async {
    return _request<T>(
      method: 'PUT',
      path: path,
      data: data,
      headers: headers,
      showLoader: showLoader,
    );
  }

  //PATCH

  Future<ResponseResult<T>> patch<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool showLoader = true,
  }) async {
    return _request<T>(
      method: 'PATCH',
      path: path,
      data: data,
      headers: headers,
      showLoader: showLoader,
    );
  }

  //DELETE

  Future<ResponseResult<T>> delete<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
    bool showLoader = true,
  }) async {
    return _request<T>(
      method: 'DELETE',
      path: path,
      data: data,
      headers: headers,
      showLoader: showLoader,
    );
  }

  //DOWNLOAD

  Future<ResponseResult<Uint8List>> downloadBytes({
    required String path,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        queryParameters: queryParameters,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      return ResponseResult.success(
        Uint8List.fromList(response.data!),
        response.statusCode,
      );
    } on DioException catch (e) {
      return ResponseResult.error(
        errorMessage:
        DioExceptions.fromDioError(dioError: e).errorMessage(),
        dioErrorType: e.type,
        statusCode: e.response?.statusCode,
      );
    }
  }

  //COMMON REQUEST

  Future<ResponseResult<T>> _request<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    ResponseType responseType = ResponseType.json,
    bool showLoader = false,
  }) async {
    if (showLoader) {
      LoadingService.show();
    }

    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: headers,
          responseType: responseType,
        ),
      );

      return ResponseResult.success(
        response.data,
        response.statusCode,
      );
    } on DioException catch (e) {
      return ResponseResult.error(
        errorMessage:
        DioExceptions.fromDioError(dioError: e).errorMessage(),
        dioErrorType: e.type,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ResponseResult.error(
        errorMessage: e.toString(),
      );
    } finally {
      if (showLoader) {
        LoadingService.hide();
      }
    }
  }
}