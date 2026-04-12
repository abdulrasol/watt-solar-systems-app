import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class AdminCompaniesState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<Company> companies;
  final String? statusFilter;
  final int page;

  AdminCompaniesState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.companies = const [],
    this.statusFilter,
    this.page = 1,
  });

  AdminCompaniesState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<Company>? companies,
    Object? statusFilter = _sentinel,
    int? page,
  }) {
    return AdminCompaniesState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      companies: companies ?? this.companies,
      statusFilter: statusFilter == _sentinel ? this.statusFilter : statusFilter as String?,
      page: page ?? this.page,
    );
  }
}

const _sentinel = Object();

class AdminCompaniesController extends Notifier<AdminCompaniesState> {
  late AdminRepository _repository;

  @override
  AdminCompaniesState build() {
    _repository = getIt<AdminRepository>();
    return AdminCompaniesState();
  }

  Future<void> fetchCompanies({String? status, bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        statusFilter: status,
        companies: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final companies = await _repository.listCompanies(
        status: status ?? state.statusFilter,
        page: state.page,
        pageSize: 20,
      );
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        companies: isRefresh ? companies : [...state.companies, ...companies],
        hasMore: companies.length >= 20,
      );
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchCompanies();
  }

  Future<void> updateCompanyStatus(int companyId, String status) async {
    try {
      await _repository.updateCompanyStatus(companyId, status);

      // Update the list locally instead of re-fetching everything
      final updatedCompanies = state.companies.map((c) {
        if (c.id == companyId) {
          return c.copyWith(status: status);
        }
        return c;
      }).toList();

      state = state.copyWith(companies: updatedCompanies);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminCompaniesProvider = NotifierProvider<AdminCompaniesController, AdminCompaniesState>(() {
  return AdminCompaniesController();
});
