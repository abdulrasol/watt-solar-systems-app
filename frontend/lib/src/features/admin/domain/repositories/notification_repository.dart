import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';

import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, NotificationStats>> getStatistics();

  Future<Either<Failure, NotificationResponse>> sendBroadcastNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  Future<Either<Failure, NotificationResponse>> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  /// [groupType] is one of 'company', 'followers', or 'custom'. [groupId]
  /// is a company id, a post id (for 'followers'), or — for 'custom' — a
  /// `List<int>` of user ids (matches the backend's `Any`-typed
  /// `group_id` field on `GroupNotificationSchema`).
  Future<Either<Failure, NotificationResponse>> sendToGroup({
    required String groupType,
    required dynamic groupId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  Future<Either<Failure, NotificationResponse>> sendToUser({
    required int userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
}
