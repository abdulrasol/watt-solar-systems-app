import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company_details.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/utils/helper_methods.dart' show dPrint;

class AdminCompanyDetailsState {
  final bool isLoading;
  final String? error;
  final AdminCompanyDetails? details;

  AdminCompanyDetailsState({this.isLoading = false, this.error, this.details});

  AdminCompanyDetailsState copyWith({bool? isLoading, String? error, AdminCompanyDetails? details}) {
    return AdminCompanyDetailsState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, details: details ?? this.details);
  }
}

class AdminCompanyDetailsController extends Notifier<AdminCompanyDetailsState> {
  late AdminRepository _repository;
  late int _companyId;

  @override
  AdminCompanyDetailsState build() {
    _repository = getIt<AdminRepository>();
    return AdminCompanyDetailsState();
  }

  void setCompanyId(int companyId) {
    _companyId = companyId;
  }

  Future<void> fetchDetails() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final details = await _repository.getCompanyDetails(_companyId);
      // dPrint(details);
      state = state.copyWith(isLoading: false, details: details);
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateCompanyStatus(_companyId, status);
      await fetchDetails();
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleService(String serviceCode, Map<String, dynamic> data) async {
    try {
      await _repository.toggleCompanyService(_companyId, serviceCode, data);
      // Refresh details to show updated service status
      await fetchDetails();
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminCompanyDetailsProvider = NotifierProvider<AdminCompanyDetailsController, AdminCompanyDetailsState>(() {
  return AdminCompanyDetailsController();
});
