import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart' as local;
import 'package:solar_hub/src/core/navigation/app_navigation.dart';
import 'package:solar_hub/src/core/services/network_status_service.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';
import 'package:solar_hub/src/services/toast_service.dart';

/// Cache interceptor for GET requests to reduce redundant API calls
class CacheInterceptor extends Interceptor {
  final CasheInterface _cache;
  final Duration cacheDuration;

  CacheInterceptor({required CasheInterface cache, this.cacheDuration = const Duration(minutes: 5)}) : _cache = cache;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Only cache GET requests
    if (options.method != 'GET') {
      return handler.next(options);
    }

    final cacheKey = _getCacheKey(options);
    final cachedData = _cache.getCache(cacheKey);

    if (cachedData != null) {
      final cached = jsonDecode(cachedData);
      final timestamp = cached['timestamp'] as int;
      final isExpired = DateTime.now().millisecondsSinceEpoch - timestamp > cacheDuration.inMilliseconds;

      if (!isExpired) {
        dPrint('Cache hit for: ${options.path}', tag: 'Cache');
        return handler.resolve(Response(requestOptions: options, data: cached['data'], statusCode: 200));
      }
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;

    // Only cache GET requests with 200 status
    if (options.method == 'GET' && response.statusCode == 200) {
      final cacheKey = _getCacheKey(options);
      final cacheData = jsonEncode({'data': response.data, 'timestamp': DateTime.now().millisecondsSinceEpoch});
      _cache.setCache(cacheKey, cacheData);
      dPrint('Cached response for: ${options.path}', tag: 'Cache');
    }

    return handler.next(response);
  }

  String _getCacheKey(RequestOptions options) {
    final queryString = options.queryParameters.isNotEmpty ? '&${options.queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&')}' : '';
    return 'http_cache:${options.path}$queryString';
  }
}

extension _CacheExtension on CasheInterface {
  static const _cachePrefix = '_http_cache_';

  void setCache(String key, String value) {
    save('$_cachePrefix$key', value);
  }

  String? getCache(String key) {
    final value = get('$_cachePrefix$key');
    return value as String?;
  }
}

abstract class ApiServicesInterface {
  Future get(String url);
  Future post(String url, {Map<String, dynamic>? data});
  Future put(String url, {Map<String, dynamic>? data});
  Future delete(String url);
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
  late final CacheInterceptor _cacheInterceptor;

  DioService() {
    _dio.options.baseUrl = AppUrls.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _cacheInterceptor = CacheInterceptor(cache: getIt<CasheInterface>());
    _dio.interceptors.add(_cacheInterceptor);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          dPrint(options.path, tag: options.method);
          final token = getIt<CasheInterface>().token();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            dPrint('Authorized request', tag: options.method);
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
          }
          final context = rootNavigatorKey.currentContext;
          if (context != null) {
            String title = 'Server Error';
            String message = 'An unexpected error occurred';
            dynamic detail = error.response?.data ?? error.message;

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
              }
            }

            ToastService.showErrorWithDetail(context, title: title, message: message, detail: detail);
          }

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
