import 'package:dio/dio.dart';

class ResponseResult<T> {
  /// Data returned from API
  final T? data;

  /// HTTP Status Code
  final int? statusCode;

  /// Error Message
  final String? errorMessage;

  /// Dio Error Type
  final DioExceptionType? dioErrorType;

  const ResponseResult._({
    this.data,
    this.statusCode,
    this.errorMessage,
    this.dioErrorType,
  });

  /// Success Factory
  factory ResponseResult.success(
      T? data,
      int? statusCode,
      ) {
    return ResponseResult._(
      data: data,
      statusCode: statusCode,
    );
  }

  /// Error Factory
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

  /// Convenience Getter
  // bool get isSuccess =>
  //     statusCode != null &&
  //         statusCode! >= 200 &&
  //         statusCode! < 300;
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





































// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';
//
// class ResponseResult<T> extends Equatable {
//   final T? data;
//   final String? errorMessage;
//   final DioExceptionType? dioErrorType;
//   final int? statusCode;
//
//   const ResponseResult.success(
//       this.data,
//       this.statusCode,
//       )   : errorMessage = null,
//         dioErrorType = null;
//
//   const ResponseResult.error({
//     required this.errorMessage,
//     this.dioErrorType,
//     this.statusCode,
//   }) : data = null;
//
//   bool get isSuccess =>
//       errorMessage == null &&
//           statusCode != null &&
//           statusCode! >= 200 &&
//           statusCode! < 300;
//
//   @override
//   List<Object?> get props => [
//     data,
//     errorMessage,
//     dioErrorType,
//     statusCode,
//   ];
// }