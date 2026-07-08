import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/notifications/domain/entities/app_notification.dart';
import 'package:watt/src/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/utils/helper_methods.dart';

class NotificationHistoryRepositoryImpl
    implements NotificationHistoryRepository {
  final DioService _dioService;

  NotificationHistoryRepositoryImpl(this._dioService);

  @override
  Future<NotificationHistoryPage> fetchHistory({
    int page = 1,
    int pageSize = 12,
  }) async {
    final response = await _dioService.get(
      AppUrls.notificationHistory,
      queryParameters: {'page': page, 'page_size': pageSize},
    );

    if (response.status != 200 || response.error) {
      throw Exception(
        response.messageUser.isNotEmpty
            ? response.messageUser
            : response.message,
      );
    }

    final body = Map<String, dynamic>.from(response.body ?? const {});
    final notifications = body['notifications'];
    if (notifications is! List) {
      return NotificationHistoryPage(
        items: const [],
        totalCount: int.tryParse(body['count']?.toString() ?? '') ?? 0,
      );
    }

    return NotificationHistoryPage(
      items: notifications
          .whereType<Map>()
          .map(
            (item) =>
                AppNotificationItem.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      totalCount:
          int.tryParse(body['count']?.toString() ?? '') ?? notifications.length,
    );
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await _dioService.post(
        '${AppUrls.notificationHistory}/read',
      );
      if (response.status != 200 || response.error) {
        throw Exception(
          response.messageUser.isNotEmpty
              ? response.messageUser
              : response.message,
        );
      }
    } catch (e) {
      dPrint('Failed to mark notifications as read on server: $e', tag: 'NotificationRepository');
    }
  }
}
