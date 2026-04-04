import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/notifications/domain/entities/app_notification.dart';
import 'package:solar_hub/src/features/notifications/domain/repositories/notification_history_repository.dart';

const _notificationHistoryUnset = Object();

class NotificationHistoryState {
  final bool isLoading;
  final String? error;
  final List<AppNotificationItem> items;

  const NotificationHistoryState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  NotificationHistoryState copyWith({
    bool? isLoading,
    Object? error = _notificationHistoryUnset,
    List<AppNotificationItem>? items,
  }) {
    return NotificationHistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _notificationHistoryUnset)
          ? this.error
          : error as String?,
      items: items ?? this.items,
    );
  }
}

class NotificationHistoryController extends Notifier<NotificationHistoryState> {
  NotificationHistoryRepository get _repository =>
      getIt<NotificationHistoryRepository>();

  @override
  NotificationHistoryState build() {
    final isSigned = ref.watch(authProvider.select((value) => value.isSigned));
    if (isSigned) {
      Future.microtask(fetchHistory);
    }
    return const NotificationHistoryState();
  }

  Future<void> fetchHistory() async {
    if (!ref.read(authProvider).isSigned) {
      state = const NotificationHistoryState(items: []);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.fetchHistory();
      state = state.copyWith(isLoading: false, error: null, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final notificationHistoryProvider =
    NotifierProvider<NotificationHistoryController, NotificationHistoryState>(
      NotificationHistoryController.new,
    );
