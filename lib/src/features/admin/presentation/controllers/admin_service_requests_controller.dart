import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';

class AdminServiceRequestsState {
  final bool isLoading;
  final String? error;
  final List<ServiceRequest> requests;

  AdminServiceRequestsState({
    this.isLoading = false,
    this.error,
    this.requests = const [],
  });

  AdminServiceRequestsState copyWith({
    bool? isLoading,
    String? error,
    List<ServiceRequest>? requests,
  }) {
    return AdminServiceRequestsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      requests: requests ?? this.requests,
    );
  }
}

class AdminServiceRequestsController extends Notifier<AdminServiceRequestsState> {
  late AdminRepository _repository;

  @override
  AdminServiceRequestsState build() {
    _repository = getIt<AdminRepository>();
    return AdminServiceRequestsState();
  }

  Future<void> fetchServiceRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests = await _repository.listServiceRequests();
      state = state.copyWith(isLoading: false, requests: requests);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> reviewRequest(int companyId, String serviceCode, Map<String, dynamic> data) async {
    try {
      await _repository.reviewServiceRequest(companyId, serviceCode, data);
      await fetchServiceRequests();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final adminServiceRequestsProvider = NotifierProvider<AdminServiceRequestsController, AdminServiceRequestsState>(() {
  return AdminServiceRequestsController();
});
