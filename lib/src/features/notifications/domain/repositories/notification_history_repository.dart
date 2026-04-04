import 'package:solar_hub/src/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationHistoryRepository {
  Future<List<AppNotificationItem>> fetchHistory({int limit = 50});
}
