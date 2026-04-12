import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/shared/domain/company/company_contact.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_contact_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

class CompanyContactsState {
  const CompanyContactsState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.contacts = const [],
  });

  final bool isLoading;
  final bool isSaving;
  final String? error;
  final List<CompanyContact> contacts;

  CompanyContactsState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? error = _sentinel,
    List<CompanyContact>? contacts,
  }) {
    return CompanyContactsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error == _sentinel ? this.error : error as String?,
      contacts: contacts ?? this.contacts,
    );
  }
}

const _sentinel = Object();

class CompanyContactsController extends Notifier<CompanyContactsState> {
  late final CompanyManagementRepository _repository;

  @override
  CompanyContactsState build() {
    _repository = getIt<CompanyManagementRepository>();
    return const CompanyContactsState();
  }

  Future<void> fetchContacts(int companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final contacts = await _repository.listContacts(companyId, page: 1);
      state = state.copyWith(isLoading: false, contacts: contacts);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createContact(
    int companyId,
    CompanyContactFormModel payload,
  ) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final contact = await _repository.createContact(companyId, payload);
      state = state.copyWith(
        isSaving: false,
        contacts: [...state.contacts, contact],
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteContact(int companyId, int contactId) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.deleteContact(companyId, contactId);
      state = state.copyWith(
        isSaving: false,
        contacts: state.contacts.where((item) => item.id != contactId).toList(),
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}

final companyContactsProvider =
    NotifierProvider<CompanyContactsController, CompanyContactsState>(
      CompanyContactsController.new,
    );
