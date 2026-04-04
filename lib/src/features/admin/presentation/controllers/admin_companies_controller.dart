import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';

class AdminCompaniesState {
  final bool isLoading;
  final String? error;
  final List<AdminCompany> companies;
  final String? statusFilter;

  AdminCompaniesState({
    this.isLoading = false,
    this.error,
    this.companies = const [],
    this.statusFilter,
  });

  AdminCompaniesState copyWith({
    bool? isLoading,
    String? error,
    List<AdminCompany>? companies,
    String? statusFilter,
  }) {
    return AdminCompaniesState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      companies: companies ?? this.companies,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class AdminCompaniesController extends Notifier<AdminCompaniesState> {
  late AdminRepository _repository;

  @override
  AdminCompaniesState build() {
    _repository = getIt<AdminRepository>();
    return AdminCompaniesState();
  }

  Future<void> fetchCompanies({String? status}) async {
    state = state.copyWith(isLoading: true, error: null, statusFilter: status);
    try {
      final companies = await _repository.listCompanies(status: status);
      state = state.copyWith(isLoading: false, companies: companies);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateCompanyStatus(int companyId, String status) async {
    try {
      await _repository.updateCompanyStatus(companyId, status);
      // Refresh the list after update
      await fetchCompanies(status: state.statusFilter);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final adminCompaniesProvider = NotifierProvider<AdminCompaniesController, AdminCompaniesState>(() {
  return AdminCompaniesController();
});
