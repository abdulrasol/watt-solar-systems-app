import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/admin/domain/entities/notification.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/notification_repository.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final DioService _dioService;

  NotificationRepositoryImpl(this._dioService);

  @override
  Future<Either<Failure, NotificationStats>> getStatistics() async {
    try {
      final response = await _dioService.get(AppUrls.notificationStatistics);
      if (response.status == 200 && !response.error) {
        return Right(
          NotificationStats.fromJson(
            Map<String, dynamic>.from(response.body ?? const {}),
          ),
        );
      }

      return Left(
        _responseFailure(response, 'Failed to load notification statistics'),
      );
    } on DioException catch (e) {
      return Left(
        _mapDioFailure(e, fallback: 'Failed to load notification statistics'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationResponse>> sendBroadcastNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dioService.post(
        AppUrls.notificationSendBroadcast,
        data: {'title': title, 'body': body, 'data': data ?? {}},
      );
      return _parseSendResponse(response);
    } on DioException catch (e) {
      return Left(
        _mapDioFailure(e, fallback: 'Failed to send broadcast notification'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationResponse>> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dioService.post(
        AppUrls.notificationSendTopic,
        data: {'title': title, 'body': body, 'data': data ?? {}},
        queryParameters: {'topic': topic},
      );
      return _parseSendResponse(response);
    } on DioException catch (e) {
      return Left(
        _mapDioFailure(e, fallback: 'Failed to send topic notification'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Either<Failure, NotificationResponse> _parseSendResponse(dynamic response) {
    if (response.status == 200 && !response.error) {
      final body = Map<String, dynamic>.from(response.body ?? const {});
      return Right(
        NotificationResponse(
          success: true,
          message: response.message.isNotEmpty
              ? response.message
              : 'Notification sent successfully',
          successCount: body['success_count'] ?? 0,
          failureCount: body['failure_count'] ?? 0,
        ),
      );
    }

    return Left(_responseFailure(response, 'Notification request failed'));
  }

  Failure _responseFailure(dynamic response, String fallback) {
    return ServerFailure(
      response.messageUser.isNotEmpty
          ? response.messageUser
          : (response.message.isNotEmpty ? response.message : fallback),
    );
  }

  Failure _mapDioFailure(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return ServerFailure(
        (data['message_user'] ?? data['message'] ?? fallback).toString(),
      );
    }
    return NetworkFailure(e.message ?? fallback);
  }
}
