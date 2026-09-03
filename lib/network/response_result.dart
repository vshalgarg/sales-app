import 'package:dio/dio.dart';

class ResponseResult<T> {
  // Data returned from API
  final T? data;

  final int? statusCode;

  final String? errorMessage;

  final DioExceptionType? dioErrorType;

  const ResponseResult._({
    this.data,
    this.statusCode,
    this.errorMessage,
    this.dioErrorType,
  });

  factory ResponseResult.success(
      T? data,
      int? statusCode,
      ) {
    return ResponseResult._(
      data: data,
      statusCode: statusCode,
    );
  }

  factory ResponseResult.error({
    required String errorMessage,
    DioExceptionType? dioErrorType,
    int? statusCode,
  }) {
    return ResponseResult._(
      errorMessage: errorMessage,
      dioErrorType: dioErrorType,
      statusCode: statusCode,
    );
  }

  bool get isSuccess => errorMessage == null;
  bool get isFailure => !isSuccess;

  @override
  String toString() {
    return '''
ResponseResult(
  statusCode: $statusCode,
  isSuccess: $isSuccess,
  data: $data,
  errorMessage: $errorMessage
)
''';
  }
}