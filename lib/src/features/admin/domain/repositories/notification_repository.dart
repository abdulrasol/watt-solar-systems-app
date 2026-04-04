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
}
