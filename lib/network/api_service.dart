import 'dart:typed_data';

import 'package:dio/dio.dart';

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
  }) async {
    return _request<T>(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      responseType: responseType,
    );
  }

  // POST
  Future<ResponseResult<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool useFormData = false,
  }) async {
    return _request<T>(
      method: 'POST',
      path: path,
      data: useFormData && data is Map<String, dynamic>
          ? FormData.fromMap(data)
          : data,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  //PUT

  Future<ResponseResult<T>> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      method: 'PUT',
      path: path,
      data: data,
      headers: headers,
    );
  }

  //PATCH

  Future<ResponseResult<T>> patch<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      method: 'PATCH',
      path: path,
      data: data,
      headers: headers,
    );
  }

  //DELETE

  Future<ResponseResult<T>> delete<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return _request<T>(
      method: 'DELETE',
      path: path,
      data: data,
      headers: headers,
    );
  }

  //DOWNLOAD ----------------

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
  }) async {
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
    }
  }
}







// import 'dart:convert';
//
// import 'package:dio/dio.dart';
//
// import 'api_provider.dart';
// import 'dio_exception.dart';
// import 'response_result.dart';
//
// class ApiService {
//   final ApiProvider apiProvider;
//
//   ApiService(this.apiProvider);
//
//   //  GET
//
//   Future<ResponseResult<T>> get<T>({
//     required String path,
//     Map<String, dynamic>? queryParameters,
//     Map<String, String>? headers,
//     ResponseType responseType = ResponseType.json,
//   }) async {
//     try {
//       final dio = apiProvider.getClient();
//
//       print("=========== GET REQUEST ===========");
//       print("URL: ${dio.options.baseUrl}$path");
//       print("Query Params: $queryParameters");
//
//       final response = await dio.get(
//         path,
//         queryParameters: queryParameters,
//         options: Options(
//           headers: headers,
//           responseType: responseType,
//         ),
//       );
//
//       print("=========== GET RESPONSE ===========");
//       print("Status Code: ${response.statusCode}");
//       print("Response: ${response.data}");
//       // final response = await apiProvider.getClient().get(
//       //   path,
//       //   queryParameters: queryParameters,
//       //   options: Options(
//       //     headers: headers,
//       //     responseType: responseType,
//       //   ),
//       // );
//
//       return ResponseResult.success(
//         response.data,
//         response.statusCode,
//       );
//     } on DioException catch (e) {
//       return ResponseResult.error(
//         errorMessage:
//         DioExceptions.fromDioError(dioError: e).errorMessage(),
//         dioErrorType: e.type,
//         statusCode: e.response?.statusCode,
//       );
//     }
//   }
//
//   //  POST
//
//   Future<ResponseResult<T>> post<T>({
//     required String path,
//     dynamic data,
//     Map<String, dynamic>? queryParameters,
//     Map<String, String>? headers,
//     bool useFormData = false,
//   }) async {
//     try {
//       dynamic body = data;
//
//       if (useFormData && data is Map<String, dynamic>) {
//         body = FormData.fromMap(data);
//       }
//       final dio = apiProvider.getClient();
//
//       print("=========== POST REQUEST ===========");
//       print("URL: ${dio.options.baseUrl}$path");
//       print("Query Params: $queryParameters");
//       print("Request Body: ${jsonEncode(data)}");
//       final response = await dio.post(
//         path,
//         data: body,
//         queryParameters: queryParameters,
//         options: Options(headers: headers),
//       );
//
//       print("=========== POST RESPONSE ===========");
//       print("Status Code: ${response.statusCode}");
//       print("Response: ${response.data}");
//       // final response = await apiProvider.getClient().post(
//       //   path,
//       //   data: body,
//       //   queryParameters: queryParameters,
//       //   options: Options(headers: headers),
//       // );
//
//       return ResponseResult.success(
//         response.data,
//         response.statusCode,
//       );
//     } on DioException catch (e) {
//       return ResponseResult.error(
//         errorMessage:
//         DioExceptions.fromDioError(dioError: e).errorMessage(),
//         dioErrorType: e.type,
//         statusCode: e.response?.statusCode,
//       );
//     }
//   }
//
//   //  PUT
//
//   Future<ResponseResult<T>> put<T>({
//     required String path,
//     dynamic data,
//     Map<String, String>? headers,
//   }) async {
//     try {
//       final response = await apiProvider.getClient().put(
//         path,
//         data: data,
//         options: Options(headers: headers),
//       );
//
//       return ResponseResult.success(
//         response.data,
//         response.statusCode,
//       );
//     } on DioException catch (e) {
//       return ResponseResult.error(
//         errorMessage:
//         DioExceptions.fromDioError(dioError: e).errorMessage(),
//         dioErrorType: e.type,
//         statusCode: e.response?.statusCode,
//       );
//     }
//   }
//
//   //  PATCH
//
//   Future<ResponseResult<T>> patch<T>({
//     required String path,
//     dynamic data,
//     Map<String, String>? headers,
//   }) async {
//     try {
//       final response = await apiProvider.getClient().patch(
//         path,
//         data: data,
//         options: Options(headers: headers),
//       );
//
//       return ResponseResult.success(
//         response.data,
//         response.statusCode,
//       );
//     } on DioException catch (e) {
//       return ResponseResult.error(
//         errorMessage:
//         DioExceptions.fromDioError(dioError: e).errorMessage(),
//         dioErrorType: e.type,
//         statusCode: e.response?.statusCode,
//       );
//     }
//   }
//
//   //  DELETE
//
//   Future<ResponseResult<T>> delete<T>({
//     required String path,
//     Map<String, String>? headers,
//   }) async {
//     try {
//       final response = await apiProvider.getClient().delete(
//         path,
//         options: Options(headers: headers),
//       );
//
//       return ResponseResult.success(
//         response.data,
//         response.statusCode,
//       );
//     } on DioException catch (e) {
//       return ResponseResult.error(
//         errorMessage:
//         DioExceptions.fromDioError(dioError: e).errorMessage(),
//         dioErrorType: e.type,
//         statusCode: e.response?.statusCode,
//       );
//     }
//   }
// }