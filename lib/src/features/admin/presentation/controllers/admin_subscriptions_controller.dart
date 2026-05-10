import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_subscription_plan.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';

class AdminSubscriptionsController extends Notifier<AsyncValue<List<AdminSubscriptionPlan>>> {
  late AdminRepository _repository;

  @override
  AsyncValue<List<AdminSubscriptionPlan>> build() {
    _repository = getIt<AdminRepository>();
    // Initial load
    Future.microtask(() => loadPlans());
    return const AsyncValue.loading();
  }

  Future<void> loadPlans() async {
    state = const AsyncValue.loading();
    try {
      final plans = await _repository.listSubscriptionPlans();
      state = AsyncValue.data(plans);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPlan(Map<String, dynamic> data) async {
    try {
      await _repository.createSubscriptionPlan(data);
      await loadPlans();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePlan(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateSubscriptionPlan(id, data);
      await loadPlans();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePlan(int id) async {
    try {
      await _repository.deleteSubscriptionPlan(id);
      await loadPlans();
    } catch (e) {
      rethrow;
    }
  }
}

final adminSubscriptionsProvider = NotifierProvider<AdminSubscriptionsController, AsyncValue<List<AdminSubscriptionPlan>>>(() {
  return AdminSubscriptionsController();
});
