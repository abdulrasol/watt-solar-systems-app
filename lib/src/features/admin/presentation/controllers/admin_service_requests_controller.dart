import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';

class AdminServiceRequestsState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<ServiceRequest> requests;
  final int page;

  AdminServiceRequestsState({this.isLoading = false, this.isMoreLoading = false, this.hasMore = true, this.error, this.requests = const [], this.page = 1});

  AdminServiceRequestsState copyWith({bool? isLoading, bool? isMoreLoading, bool? hasMore, String? error, List<ServiceRequest>? requests, int? page}) {
    return AdminServiceRequestsState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      requests: requests ?? this.requests,
      page: page ?? this.page,
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

  Future<void> fetchServiceRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isLoading: true, hasMore: true, page: 1, error: null);
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final requests = await _repository.listServiceRequests(page: state.page, pageSize: 20);
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        requests: isRefresh ? requests : [...state.requests, ...requests],
        hasMore: requests.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchServiceRequests();
  }

  Future<void> reviewRequest(int companyId, String serviceCode, Map<String, dynamic> data) async {
    try {
      await _repository.reviewServiceRequest(companyId, serviceCode, data);

      // Locally update the request status
      final updatedRequests = state.requests.map((r) {
        if (r.companyId == companyId && r.serviceCode == serviceCode) {
          return r.copyWith(status: data['status'] ?? r.status);
        }
        return r;
      }).toList();

      state = state.copyWith(requests: updatedRequests);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminServiceRequestsProvider = NotifierProvider<AdminServiceRequestsController, AdminServiceRequestsState>(() {
  return AdminServiceRequestsController();
});
