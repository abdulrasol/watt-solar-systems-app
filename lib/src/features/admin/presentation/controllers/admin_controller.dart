import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import '../../../feedback/domain/entities/feedback_entity.dart';
import '../../../feedback/domain/repositories/feedback_repository.dart';

class AdminState {
  final bool isLoading;
  final String? error;
  final List<FeedbackEntity> feedbacks;
  final int unreadCount;
  final DateTime? lastRefreshed;

  AdminState({this.isLoading = false, this.error, this.feedbacks = const [], this.unreadCount = 0, this.lastRefreshed});

  AdminState copyWith({bool? isLoading, String? error, List<FeedbackEntity>? feedbacks, int? unreadCount, DateTime? lastRefreshed}) {
    final newFeedbacks = feedbacks ?? this.feedbacks;
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      feedbacks: newFeedbacks,
      unreadCount: unreadCount ?? newFeedbacks.where((f) => !f.isRead).length,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

class AdminController extends Notifier<AdminState> {
  late FeedbackRepository _feedbackRepository;

  @override
  AdminState build() {
    _feedbackRepository = getIt<FeedbackRepository>();
    return AdminState();
  }

  Future<void> fetchFeedbacks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final feedbacks = await _feedbackRepository.getAllFeedbacks();
      state = state.copyWith(isLoading: false, feedbacks: feedbacks, lastRefreshed: DateTime.now());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load feedbacks: ${e.toString()}');
    }
  }

  Future<void> toggleFeedbackReadStatus(String id, bool isRead) async {
    try {
      await _feedbackRepository.updateFeedbackReadStatus(id, isRead);
      final updatedFeedbacks = state.feedbacks.map((f) {
        if (f.id == id) {
          return f.copyWith(isRead: isRead);
        }
        return f;
      }).toList();

      state = state.copyWith(feedbacks: updatedFeedbacks);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update status: $e');
    }
  }

  Future<void> deleteFeedback(String id) async {
    try {
      await _feedbackRepository.deleteFeedback(id);
      final updatedFeedbacks = state.feedbacks.where((f) => f.id != id).toList();
      state = state.copyWith(feedbacks: updatedFeedbacks);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete feedback: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminProvider = NotifierProvider<AdminController, AdminState>(() {
  return AdminController();
});
