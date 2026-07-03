import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

enum NetworkStatus { unknown, online, offline }

class NetworkStatusService extends ChangeNotifier {
  NetworkStatus _status = NetworkStatus.unknown;
  DateTime? _lastTransitionAt;
  String? _lastMessage;

  NetworkStatus get status => _status;
  DateTime? get lastTransitionAt => _lastTransitionAt;
  String? get lastMessage => _lastMessage;
  bool get isOffline => _status == NetworkStatus.offline;
  bool get isOnline => _status == NetworkStatus.online;

  void markOnline([String? message]) {
    _setStatus(NetworkStatus.online, message);
  }

  void markOffline([String? message]) {
    _setStatus(NetworkStatus.offline, message);
  }

  void _setStatus(NetworkStatus next, String? message) {
    if (_status == next && _lastMessage == message) {
      return;
    }
    _status = next;
    _lastMessage = message;
    _lastTransitionAt = DateTime.now();
    notifyListeners();
  }

  bool isConnectivityError(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout;
    }
    return false;
  }

  String userMessageFor(
    Object error, {
    String fallback = 'Something went wrong.',
  }) {
    if (error is DioException) {
      if (isConnectivityError(error)) {
        return 'You appear to be offline. Check your internet connection and try again.';
      }
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'] ?? responseData['detail'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!;
      }
    }

    final text = error.toString().trim();
    if (text.isEmpty) {
      return fallback;
    }
    return text;
  }
}
