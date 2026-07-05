import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import '../../../feedback/domain/entities/feedback_entity.dart';
import '../../../feedback/domain/repositories/feedback_repository.dart';

class AdminState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<FeedbackEntity> feedbacks;
  final int unreadCount;
  final int page;
  final DateTime? lastRefreshed;

  AdminState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.feedbacks = const [],
    this.unreadCount = 0,
    this.page = 1,
    this.lastRefreshed,
  });

  AdminState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<FeedbackEntity>? feedbacks,
    int? unreadCount,
    int? page,
    DateTime? lastRefreshed,
  }) {
    final newFeedbacks = feedbacks ?? this.feedbacks;
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      feedbacks: newFeedbacks,
      unreadCount: unreadCount ?? newFeedbacks.where((f) => !f.isRead).length,
      page: page ?? this.page,
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

  Future<void> fetchFeedbacks({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        feedbacks: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final feedbacks = await _feedbackRepository.getAllFeedbacks(
        page: state.page,
        pageSize: 12,
      );
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        feedbacks: isRefresh ? feedbacks : [...state.feedbacks, ...feedbacks],
        hasMore: feedbacks.length >= 12,
        lastRefreshed: isRefresh ? DateTime.now() : state.lastRefreshed,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        error: 'Failed to load feedbacks: ${e.toString()}',
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchFeedbacks();
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
