import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/notifications/domain/entities/app_notification.dart';
import 'package:solar_hub/src/features/notifications/domain/repositories/notification_history_repository.dart';

const _notificationHistoryUnset = Object();

class NotificationHistoryState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<AppNotificationItem> items;
  final int page;
  final int totalCount;

  const NotificationHistoryState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.items = const [],
    this.page = 1,
    this.totalCount = 0,
  });

  NotificationHistoryState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    Object? error = _notificationHistoryUnset,
    List<AppNotificationItem>? items,
    int? page,
    int? totalCount,
  }) {
    return NotificationHistoryState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: identical(error, _notificationHistoryUnset)
          ? this.error
          : error as String?,
      items: items ?? this.items,
      page: page ?? this.page,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class NotificationHistoryController extends Notifier<NotificationHistoryState> {
  NotificationHistoryRepository get _repository =>
      getIt<NotificationHistoryRepository>();

  Timer? _pollingTimer;

  @override
  NotificationHistoryState build() {
    final isSigned = ref.watch(authProvider.select((value) => value.isSigned));
    if (isSigned) {
      Future.microtask(() => fetchHistory(isRefresh: true));
      _startPolling();
    } else {
      _stopPolling();
    }

    ref.onDispose(() {
      _stopPolling();
    });

    return const NotificationHistoryState();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      fetchHistory(isRefresh: true);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchHistory({bool isRefresh = false}) async {
    if (!ref.read(authProvider).isSigned) {
      state = const NotificationHistoryState(items: [], totalCount: 0);
      return;
    }

    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        items: [],
        totalCount: 0,
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final historyPage = await _repository.fetchHistory(
        page: state.page,
        pageSize: 12,
      );
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        items: isRefresh
            ? historyPage.items
            : [...state.items, ...historyPage.items],
        totalCount: historyPage.totalCount,
        hasMore:
            (isRefresh
                ? historyPage.items.length
                : state.items.length + historyPage.items.length) <
            historyPage.totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchHistory();
  }
}

final notificationHistoryProvider =
    NotifierProvider<NotificationHistoryController, NotificationHistoryState>(
      NotificationHistoryController.new,
    );
