import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;

import '../../core/styles/style.dart';
import '../../core/utilities/utilities.dart';
import '../../routes/app_pages.dart';
import 'dio_custom_interceptor.dart';

enum ApiMethod { get, post, put, delete, patch }

class ApiClient {
  factory ApiClient() => _instance;

  ApiClient._internal();
  static const methodData = {
    ApiMethod.get: 'get',
    ApiMethod.post: 'post',
    ApiMethod.put: 'put',
    ApiMethod.delete: 'delete',
    ApiMethod.patch: 'patch',
  };
  static const Duration connectTimeOut = Duration(seconds: 30);
  static const Duration receiveTimeOut = Duration(seconds: 30);
  static final ApiClient _instance = ApiClient._internal();
  static final dio = Dio()
    ..options.connectTimeout = connectTimeOut
    ..options.receiveTimeout = receiveTimeOut
    ..interceptors.add(CustomInterceptors());
  static void setBaseUrl(String url) => dio.options.baseUrl = url;
  // static BaseOptions exportOption() {
  //   final token = Application.pref.get(Application.token);
  //   baseOptions.headers["Content-Type"] = "application/x-www-form-urlencoded";
  //   baseOptions.headers["Authorization"] = '$token';
  //   return baseOptions;
  // }
  static String getBaseUrl() => dio.options.baseUrl;
  static Options options(String? method, String? token) {
    return Options(
      method: method,
      responseType: ResponseType.json,
      contentType: 'application/x-www-form-urlencoded',
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  static Future<Response> connect(
    String path, {
    ApiMethod method = ApiMethod.get,
    Map<String, dynamic>? query,
    dynamic data,
    Map<String, dynamic>? headers,
    bool cache = false,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      Map<String, dynamic>? map;
      if (query != null) {
        map = query;
      } else if (data != null && data is Map) {
        map = data as Map<String, dynamic>;
      } else {
        map = Uri.parse(path).queryParameters;
      }

      final requestHeaders = <String, dynamic>{
        'Accept': 'application/json',
        ...(headers ?? {})
      };

      if (Preferences.getString(StringUtils.token)?.isNotEmpty ?? false) {
        requestHeaders['Authorization'] =
            'Bearer ${Preferences.getString(StringUtils.token)}';
      }
      if (map.containsKey('lat') && map.containsKey('long')) {
        requestHeaders.addAll(
          {
            'lat': map['lat'].toString(),
            'long': map['long'].toString(),
          },
        );
      }
      options ??= Options(
        method: methodData[method],
        responseType: ResponseType.json,
        contentType: 'application/json',
        headers: requestHeaders,
      );
      final request = await dio.request(
        path,
        options: options,
        data: data,
        queryParameters: query,
        cancelToken: cancelToken,
      );
      debugPrint(
          '$path\nmethod: ${options.method}\nheader: ${options.headers}\ndata: $data\nrequest:$request');
      return request;
    } on DioException catch (error) {
      debugPrint('$path -- ${error.response?.data}');
      throw createErrorEntity(error);
    }
  }
}

ErrorEntity createErrorEntity(DioException error) {
  switch (error.type) {
    case DioExceptionType.cancel:
      return ErrorEntity(code: -1, message: 'Request cancellation');

    case DioExceptionType.connectionTimeout:
      return ErrorEntity(code: -1, message: 'Connection timed out');

    case DioExceptionType.sendTimeout:
      return ErrorEntity(code: -1, message: 'Request timed out');

    case DioExceptionType.receiveTimeout:
      return ErrorEntity(code: -1, message: 'Response timeout');

    default:
      try {
        final errData = error.response?.data;
        final errCode = error.response?.statusCode;
        if (errCode == null) {
          return ErrorEntity(code: -2, message: error.message);
        } else if (errCode == 401) {
          Preferences.clear();
          if (getx.Get.currentRoute != Routes.login) {
            getx.Get.offAndToNamed(Routes.login);
          }
        }
        if (errData != null &&
            errData is! String &&
            errData['errors'] != null &&
            errData['errors'] is List) {
          var errors = errData['errors'] as List;
          if (errors.isNotEmpty) {
            return ErrorEntity(
              code: errCode,
              message: errors.first['message'],
            );
          }
        }
        switch (errCode) {
          case 400:
            return ErrorEntity(code: errCode, message: 'Bad Request');

          case 401:
            return ErrorEntity(code: errCode, message: 'Unauthorized');

          case 403:
            return ErrorEntity(code: errCode, message: 'Forbidden');

          case 404:
            return ErrorEntity(code: errCode, message: 'Not Found');

          case 405:
            return ErrorEntity(code: errCode, message: 'Method Not Allowed');

          case 500:
            return ErrorEntity(code: errCode, message: 'Internal Server Error');

          case 502:
            return ErrorEntity(code: errCode, message: 'Bad Gateway');

          case 503:
            return ErrorEntity(code: errCode, message: 'Service Unavailable');

          case 505:
            return ErrorEntity(code: errCode, message: 'HTTP  Not Supported');

          default:
            return ErrorEntity(
              code: errCode,
              message: error.response?.data?['message'] ??
                  'Something Went Wrong, Please Try Again Later?',
            );
        }
      } on Exception catch (error) {
        return ErrorEntity(code: -1, message: error.toString());
      }
  }
}

class ErrorEntity implements Exception {
  int code;
  String? message;
  ErrorEntity({required this.code, this.message});

  @override
  String toString() {
    if (message == null) return 'Exception';

    return '$message';
  }
}
