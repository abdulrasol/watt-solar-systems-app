import 'package:dio/dio.dart';
import 'package:watt/src/core/cashe/cashe_interface.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/models/response.dart' as local;
import 'package:watt/src/core/navigation/app_navigation.dart';
import 'package:watt/src/core/services/network_status_service.dart';
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/utils/helper_methods.dart';

import 'package:watt/src/services/toast_service.dart';

abstract class ApiServicesInterface {
  Future get(String url);
  Future post(String url, {Map<String, dynamic>? data});
  Future put(String url, {Map<String, dynamic>? data});
  Future delete(String url);
  Future patch(String url, {Map<String, dynamic>? data});
  Future<Map<String, dynamic>> getRawMap(String url, {Map<String, dynamic>? queryParameters});
  Future multipartRequest(
    String url, {
    required FormData file,
    void Function(int, int)? onSendProgress,
    Map<String, dynamic>? queryParameters,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
    bool isPut = false,
  });
}

class DioService implements ApiServicesInterface {
  final Dio _dio = Dio();
  final NetworkStatusService _networkStatus = getIt<NetworkStatusService>();

  DioService() {
    _dio.options.baseUrl = AppUrls.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          dPrint(options.path, tag: options.method);
          final token = getIt<CasheInterface>().token();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            dPrint('Authorized request', tag: options.method);
          }
          if (options.data != null) {
            if (options.data is FormData) {
              dPrint(options.data.files, tag: 'body');
              dPrint(options.data.fields, tag: 'body');
            } else {
              dPrint(options.data.toString(), tag: 'body');
            }
          }
          if (options.queryParameters.isNotEmpty) {
            dPrint(options.queryParameters, tag: 'query');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _networkStatus.markOnline();
          return handler.next(response);
        },

        onError: (error, handler) {
          final isConnectivityIssue = _networkStatus.isConnectivityError(error);
          if (isConnectivityIssue) {
            _networkStatus.markOffline('Remote data is unavailable while your device is offline.');
            dPrint(error.response?.data.toString(), tag: 'error', stackTrace: error.stackTrace);
            return handler.next(error);
          }
          String message = 'An unexpected error occurred';
          String title = 'Server Error';
          dynamic detail = error.response?.data; // Don't use error.message which contains the huge generic Dio text

          if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
            title = 'Connection Timeout';
            message = 'The server is taking too long to respond. Please check your internet connection.';
          } else if (error.type == DioExceptionType.connectionError) {
            title = 'Connection Error';
            message = 'Could not connect to the server. Please check your internet connection.';
          } else if (error.response?.statusCode == 401) {
            title = 'Unauthorized';
            message = 'Your session has expired. Please login again.';
          } else if (error.response?.data != null) {
            final data = error.response?.data;
            if (data is Map) {
              if (data.containsKey('message') && data['message'] != null) {
                message = data['message'].toString();
              } else if (data.containsKey('detail') && data['detail'] != null) {
                final d = data['detail'];
                if (d is String) {
                  message = d;
                } else if (d is List && d.isNotEmpty) {
                  final first = d.first;
                  if (first is Map && first.containsKey('msg')) {
                    message = first['msg'].toString();
                  } else if (first is Map && first.containsKey('type')) {
                    message = 'Validation Error: ${first['type']}';
                  }
                }
              }
            } else if (data is String && data.isNotEmpty && data.length < 100) {
              message = data;
            }
          }

          // If detail is a string and it's HTML, don't show it
          if (detail is String && detail.trim().startsWith('<')) {
            detail = null;
          }

          final isServiceUnavailable = isServiceUnavailableForCompanyType(message);

          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            // Don't spam the user with toasts for features that are simply
            // not enabled for their company type; those surfaces now render
            // a friendly "service unavailable" state instead.
            if (!isServiceUnavailable) {
              ToastService.showErrorWithDetail(context, title: title, message: message, detail: detail);
            }
          }

          dPrint(error.response?.data.toString(), tag: 'error', stackTrace: isServiceUnavailable ? null : error.stackTrace);
          handler.next(error);
        },
      ),
    );
  }

  @override
  Future<local.BaseResponse> get(String url, {Map<String, dynamic>? queryParameters, bool isPagination = false, bool isList = false}) async {
    Response response = await _dio.get(url, queryParameters: queryParameters);

    if (isList) {
      return local.ListResponse.fromList(response.data as List);
    } else if (isPagination) {
      return local.PaginationResponse.fromJson(response.data);
    } else {
      return local.Response.fromJson(response.data);
    }
  }

  @override
  Future<local.Response> post(String url, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.post(url, data: data, queryParameters: queryParameters);
    return local.Response.fromJson(response.data);
  }

  @override
  Future<local.Response> put(String url, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    Response response = await _dio.put(url, data: data, queryParameters: queryParameters);
    return local.Response.fromJson(response.data);
  }

  @override
  Future<local.Response> delete(String url, {Map<String, dynamic>? queryParameters}) async {
    Response response = await _dio.delete(url, queryParameters: queryParameters);
    return local.Response.fromJson(response.data);
  }

  @override
  Future<local.Response> patch(String url, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    Response response = await _dio.patch(url, data: data, queryParameters: queryParameters);
    return local.Response.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> getRawMap(String url, {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(url, queryParameters: queryParameters);
    return Map<String, dynamic>.from(response.data as Map);
  }

  @override
  Future<local.Response> multipartRequest(
    String url, {
    required FormData file,
    void Function(int, int)? onSendProgress,
    Map<String, dynamic>? queryParameters,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
    bool isPut = false,
  }) async {
    final options = Options(headers: headers, sendTimeout: sendTimeout, receiveTimeout: receiveTimeout);
    final response = isPut
        ? await _dio.put(url, data: file, onSendProgress: onSendProgress, queryParameters: queryParameters, options: options)
        : await _dio.post(url, data: file, onSendProgress: onSendProgress, queryParameters: queryParameters, options: options);
    return local.Response.fromJson(response.data);
  }
}
