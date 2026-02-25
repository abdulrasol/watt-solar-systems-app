import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/utils/app_urls.dart';
import 'package:solar_hub/core/models/response.dart' as local;

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
          final token = await getIt<CasheInterface>().token();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  @override
  Future<local.Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    Response response = await _dio.get(url, queryParameters: queryParameters);
    return local.Response.fromJson(response.data);
  }

  @override
  Future<local.Response> post(String url, {Map<String, dynamic>? data, Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.post(url, data: data, queryParameters: queryParameters);
    debugPrint(response.data.toString());
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
  Future multipartRequest(
    String url, {
    required FormData file,
    void Function(int, int)? onSendProgress,
    Map<String, dynamic>? queryParameters,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Map<String, dynamic>? headers,
  }) {
    // TODO: implement multipartRequest
    throw UnimplementedError();
  }
}
