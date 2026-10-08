import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../config/env.dart';
import '../main.dart';
import '../screens/login_screen.dart';
import '../shared_preferences/login_token.dart';

class ApiProvider {

  late final Dio _dio;

 ApiProvider() {
  _dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        "Accept": "application/json",
      },
    ),
  );
debugPrint("========== DIO CREATED ==========");
debugPrint("DIO INSTANCE: ${_dio.hashCode}");
debugPrint("DIO DEFAULT HEADERS: ${_dio.options.headers}");
debugPrint("DIO DEFAULT CONTENT TYPE: ${_dio.options.contentType}");
  _initializeInterceptors();
}
  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          debugPrint("========== ON REQUEST ==========");
debugPrint("DIO REQUEST URI: ${options.uri}");
debugPrint("DIO REQUEST DATA TYPE: ${options.data.runtimeType}");
debugPrint("DIO REQUEST HEADERS: ${options.headers}");
debugPrint("DIO REQUEST CONTENT TYPE: ${options.contentType}");
  final token = await AppStorage.getToken();

  if (token != null && token.isNotEmpty) {
    options.headers["Authorization"] = "Bearer $token";
  }

  if (options.data is FormData) {
    // Remove any inherited JSON content type.
    options.headers.remove("Content-Type");
    options.headers.remove("content-type");

    // Force multipart for FormData.
    options.contentType = Headers.multipartFormDataContentType;

    debugPrint("====================================");
    debugPrint("FORM DATA REQUEST");
    debugPrint("CONTENT TYPE: ${options.contentType}");
    debugPrint("DATA TYPE: ${options.data.runtimeType}");
    debugPrint("====================================");
  }

  handler.next(options);
},
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await AppStorage.logout();

            final navigator = navigatorKey.currentState;

            if (navigator != null) {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            }
          }

          handler.next(error);
        },
      ),
    );
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  Dio getClient() => _dio;
}