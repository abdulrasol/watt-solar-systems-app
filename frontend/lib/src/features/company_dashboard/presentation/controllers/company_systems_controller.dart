import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_system.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

class CompanySystemsState {
  const CompanySystemsState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  final bool isLoading;
  final String? error;
  final List<CompanySystem> items;

  CompanySystemsState copyWith({
    bool? isLoading,
    Object? error = _sentinel,
    List<CompanySystem>? items,
  }) {
    return CompanySystemsState(
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
      items: items ?? this.items,
    );
  }
}

const _sentinel = Object();

/// `GET /companies/{id}/systems` has no server-side pagination at all
/// (confirmed by reading the backend router directly — no `@paginate`
/// decorator, unlike delivery/expenses/contacts), so this fetches
/// everything in one call rather than paging. If the backend adds
/// pagination later, this is the only place that needs to change.
class CompanySystemsController extends Notifier<CompanySystemsState> {
  late final CompanyManagementRepository _repository;

  @override
  CompanySystemsState build() {
    _repository = getIt<CompanyManagementRepository>();
    return const CompanySystemsState();
  }

  Future<void> fetchSystems(int companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.listCompanySystems(companyId);
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final companySystemsProvider = NotifierProvider<CompanySystemsController, CompanySystemsState>(
  CompanySystemsController.new,
);
