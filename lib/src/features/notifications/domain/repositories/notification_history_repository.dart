import 'package:solar_hub/src/features/notifications/domain/entities/app_notification.dart';

class NotificationHistoryPage {
  final List<AppNotificationItem> items;
  final int totalCount;

  const NotificationHistoryPage({
    required this.items,
    required this.totalCount,
  });
}

abstract class NotificationHistoryRepository {
  Future<NotificationHistoryPage> fetchHistory({
    int page = 1,
    int pageSize = 12,
  });
  Future<void> markAllAsRead();
}
