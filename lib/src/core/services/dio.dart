import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart' as local;
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class ApiServicesInterface {
  Future get(String url);
  Future post(String url, {Map<String, dynamic>? data});
  Future put(String url, {Map<String, dynamic>? data});
  Future delete(String url);
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
            if (options.data != null) dPrint(options.data.toString(), tag: 'body');
            if (options.queryParameters.isNotEmpty) dPrint(options.queryParameters, tag: 'query');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },

        onError: (error, handler) {
          dPrint(error.response?.data.toString(), tag: 'error', stackTrace: error.stackTrace);
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
