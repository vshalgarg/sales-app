import 'dart:io';

import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  final DioException dioError;

  DioExceptions({required this.dioError});

  factory DioExceptions.fromDioError({
    required DioException dioError,
  }) {
    return DioExceptions(dioError: dioError);
  }

  String errorMessage() {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout. Please try again.";

      case DioExceptionType.sendTimeout:
        return "Request timeout. Please try again.";

      case DioExceptionType.receiveTimeout:
        return "Server took too long to respond.";

      case DioExceptionType.badCertificate:
        return "SSL certificate error.";

      case DioExceptionType.connectionError:
        if (dioError.error is SocketException) {
          return "No internet connection.";
        }
        return "Connection error.";

      case DioExceptionType.cancel:
        return "Request cancelled.";

      case DioExceptionType.badResponse:
        return _handleStatusCode(
          dioError.response?.statusCode,
          dioError.response?.data,
        );

      case DioExceptionType.unknown:
        if (dioError.error is SocketException) {
          return "No internet connection.";
        }
        return "Something went wrong.";
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _handleStatusCode(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        return data?["message"] ?? "Bad request.";

      case 401:
        return "Unauthorized.";

      case 403:
        return "Access denied.";

      case 404:
        return "Resource not found.";

      case 409:
        return data?["message"] ?? "Conflict.";

      case 422:
        return data?["message"] ?? "Validation failed.";

      case 500:
        return "Internal server error.";

      case 502:
        return "Bad gateway.";

      case 503:
        return "Service unavailable.";

      default:
        return data?["message"] ??
            "Something went wrong.";
    }
  }
}

// import 'dart:io';
//
// import 'package:dio/dio.dart';
//
// class DioExceptions {
//   final DioException dioError;
//
//   DioExceptions({
//     required this.dioError,
//   });
//
//   factory DioExceptions.fromDioError({
//     required DioException dioError,
//   }) {
//     return DioExceptions(dioError: dioError);
//   }
//
//   String errorMessage() {
//     switch (dioError.type) {
//       case DioExceptionType.connectionTimeout:
//         return "Connection timeout";
//
//       case DioExceptionType.sendTimeout:
//         return "Send timeout";
//
//       case DioExceptionType.receiveTimeout:
//         return "Receive timeout";
//
//       case DioExceptionType.badCertificate:
//         return "Bad certificate";
//
//       case DioExceptionType.cancel:
//         return "Request cancelled";
//
//       case DioExceptionType.connectionError:
//         return "No internet connection";
//
//       case DioExceptionType.badResponse:
//         return _handleStatusCode(
//           dioError.response?.statusCode,
//           dioError.response?.data,
//         );
//
//       case DioExceptionType.unknown:
//         if (dioError.error is SocketException) {
//           return "No internet connection";
//         }
//         return "Something went wrong";
//       case DioExceptionType.transformTimeout:
//         // TODO: Handle this case.
//         throw UnimplementedError();
//     }
//   }
//
//   String _handleStatusCode(
//       int? statusCode,
//       dynamic response,
//       ) {
//     switch (statusCode) {
//       case 400:
//         return _message(response) ?? "Bad Request";
//
//       case 401:
//         return _message(response) ?? "Unauthorized";
//
//       case 403:
//         return _message(response) ?? "Forbidden";
//
//       case 404:
//         return _message(response) ?? "Not Found";
//
//       case 409:
//         return _message(response) ?? "Conflict";
//
//       case 422:
//         return _message(response) ?? "Validation Error";
//
//       case 500:
//         return _message(response) ?? "Internal Server Error";
//
//       default:
//         return _message(response) ??
//             "Something went wrong";
//     }
//   }
//
//   String? _message(dynamic response) {
//     if (response is Map<String, dynamic>) {
//       return response["message"]?.toString();
//     }
//
//     return null;
//   }
// }