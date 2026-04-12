import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/shared/domain/company/company_public_service.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_public_service_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

class CompanyPublicServicesState {
  const CompanyPublicServicesState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.services = const [],
  });

  final bool isLoading;
  final bool isSaving;
  final String? error;
  final List<CompanyPublicService> services;

  CompanyPublicServicesState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? error = _publicSentinel,
    List<CompanyPublicService>? services,
  }) {
    return CompanyPublicServicesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error == _publicSentinel ? this.error : error as String?,
      services: services ?? this.services,
    );
  }
}

const _publicSentinel = Object();

class CompanyPublicServicesController
    extends Notifier<CompanyPublicServicesState> {
  late final CompanyManagementRepository _repository;

  @override
  CompanyPublicServicesState build() {
    _repository = getIt<CompanyManagementRepository>();
    return const CompanyPublicServicesState();
  }

  Future<void> fetchPublicServices(int companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final services = await _repository.listPublicServices(companyId);
      state = state.copyWith(isLoading: false, services: services);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPublicService(
    int companyId,
    CompanyPublicServiceFormModel payload,
  ) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final service = await _repository.createPublicService(companyId, payload);
      state = state.copyWith(
        isSaving: false,
        services: [...state.services, service],
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updatePublicService(
    int companyId,
    int serviceId,
    CompanyPublicServiceFormModel payload,
  ) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final service = await _repository.updatePublicService(
        companyId,
        serviceId,
        payload,
      );
      state = state.copyWith(
        isSaving: false,
        services: [
          for (final item in state.services)
            if (item.id == serviceId) service else item,
        ],
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deletePublicService(int companyId, int serviceId) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.deletePublicService(companyId, serviceId);
      state = state.copyWith(
        isSaving: false,
        services: state.services.where((item) => item.id != serviceId).toList(),
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}

final companyPublicServicesProvider =
    NotifierProvider<
      CompanyPublicServicesController,
      CompanyPublicServicesState
    >(CompanyPublicServicesController.new);
