import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/notifications/domain/entities/app_notification.dart';
import 'package:solar_hub/src/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

class NotificationHistoryRepositoryImpl
    implements NotificationHistoryRepository {
  final DioService _dioService;

  NotificationHistoryRepositoryImpl(this._dioService);

  @override
  Future<List<AppNotificationItem>> fetchHistory({int limit = 50}) async {
    final response = await _dioService.get(
      AppUrls.notificationHistory,
      queryParameters: {'limit': limit},
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
      return const [];
    }

    return notifications
        .whereType<Map>()
        .map(
          (item) =>
              AppNotificationItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
