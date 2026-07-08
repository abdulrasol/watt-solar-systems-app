import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/features/admin/domain/models/admin_subscription_plan.dart';
import 'package:watt/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:watt/src/utils/helper_methods.dart';

class AdminSubscriptionsState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<AdminSubscriptionPlan> plans;
  final int page;

  AdminSubscriptionsState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.plans = const [],
    this.page = 1,
  });

  AdminSubscriptionsState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<AdminSubscriptionPlan>? plans,
    int? page,
  }) {
    return AdminSubscriptionsState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      plans: plans ?? this.plans,
      page: page ?? this.page,
    );
  }
}

class AdminSubscriptionsController extends Notifier<AdminSubscriptionsState> {
  late AdminRepository _repository;

  @override
  AdminSubscriptionsState build() {
    _repository = getIt<AdminRepository>();
    return AdminSubscriptionsState();
  }

  Future<void> fetchPlans({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        plans: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final plans = await _repository.listSubscriptionPlans(
        page: state.page,
        pageSize: 12,
      );
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        plans: isRefresh ? plans : [...state.plans, ...plans],
        hasMore: plans.length >= 12,
      );
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchPlans();
  }

  Future<void> createPlan(Map<String, dynamic> data) async {
    try {
      final newPlan = await _repository.createSubscriptionPlan(data);
      state = state.copyWith(plans: [newPlan, ...state.plans]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> updatePlan(int id, Map<String, dynamic> data) async {
    try {
      final updatedPlan = await _repository.updateSubscriptionPlan(id, data);
      state = state.copyWith(
        plans: state.plans.map((p) => p.id == id ? updatedPlan : p).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePlan(int id) async {
    try {
      await _repository.deleteSubscriptionPlan(id);
      state = state.copyWith(
        plans: state.plans.where((p) => p.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminSubscriptionsProvider = NotifierProvider<AdminSubscriptionsController, AdminSubscriptionsState>(() {
  return AdminSubscriptionsController();
});
