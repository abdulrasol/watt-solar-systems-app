import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/entities/notification.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/notification_repository.dart';

const _notificationUnset = Object();

class NotificationState {
  final bool isLoadingStats;
  final bool isSending;
  final String? error;
  final String? successMessage;
  final NotificationStats stats;

  const NotificationState({
    this.isLoadingStats = false,
    this.isSending = false,
    this.error,
    this.successMessage,
    this.stats = const NotificationStats.empty(),
  });

  NotificationState copyWith({
    bool? isLoadingStats,
    bool? isSending,
    Object? error = _notificationUnset,
    Object? successMessage = _notificationUnset,
    NotificationStats? stats,
  }) {
    return NotificationState(
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      isSending: isSending ?? this.isSending,
      error: identical(error, _notificationUnset)
          ? this.error
          : error as String?,
      successMessage: identical(successMessage, _notificationUnset)
          ? this.successMessage
          : successMessage as String?,
      stats: stats ?? this.stats,
    );
  }
}

class NotificationController extends Notifier<NotificationState> {
  NotificationRepository get _repository => getIt<NotificationRepository>();

  @override
  NotificationState build() {
    return const NotificationState();
  }

  Future<void> fetchStatistics() async {
    state = state.copyWith(isLoadingStats: true, error: null);
    final result = await _repository.getStatistics();
    result.fold(
      (failure) {
        state = state.copyWith(isLoadingStats: false, error: failure.message);
      },
      (stats) {
        state = state.copyWith(isLoadingStats: false, stats: stats);
      },
    );
  }

  Future<void> sendBroadcastNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    state = state.copyWith(isSending: true, error: null, successMessage: null);
    final result = await _repository.sendBroadcastNotification(
      title: title,
      body: body,
      data: data,
    );
    result.fold(
      (failure) {
        state = state.copyWith(isSending: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isSending: false,
          successMessage:
              '${response.message} Success: ${response.successCount}, Failed: ${response.failureCount}',
        );
      },
    );
    await fetchStatistics();
  }

  Future<void> sendTopicNotification({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    state = state.copyWith(isSending: true, error: null, successMessage: null);
    final result = await _repository.sendToTopic(
      topic: topic,
      title: title,
      body: body,
      data: data,
    );
    result.fold(
      (failure) {
        state = state.copyWith(isSending: false, error: failure.message);
      },
      (response) {
        state = state.copyWith(
          isSending: false,
          successMessage:
              '${response.message} Success: ${response.successCount}, Failed: ${response.failureCount}',
        );
      },
    );
    await fetchStatistics();
  }

  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final notificationProvider =
    NotifierProvider<NotificationController, NotificationState>(
      NotificationController.new,
    );
