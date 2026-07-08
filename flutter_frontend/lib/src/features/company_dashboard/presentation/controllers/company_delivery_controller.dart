import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/shared/domain/company/delivery_option.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/delivery_option_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

const int _kPageSize = 12;

class CompanyDeliveryState {
  const CompanyDeliveryState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isSaving = false,
    this.error,
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
  });

  final bool isLoading;
  final bool isLoadingMore;
  final bool isSaving;
  final String? error;
  final List<DeliveryOption> items;
  final int page;
  final bool hasMore;

  CompanyDeliveryState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSaving,
    Object? error = _sentinel,
    List<DeliveryOption>? items,
    int? page,
    bool? hasMore,
  }) {
    return CompanyDeliveryState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSaving: isSaving ?? this.isSaving,
      error: error == _sentinel ? this.error : error as String?,
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

const _sentinel = Object();

/// Unlike the older Contacts/Categories controllers (which fetch page 1
/// only and never page further, or fetch-all with no pagination at all),
/// this controller implements real infinite-scroll pagination: 12 items
/// per page (matching the backend's `page_size=12` default and the
/// project's pagination convention), loading the next page when
/// [fetchNextPage] is called (wired to a scroll-near-bottom listener in
/// the screen). "Has more" is inferred from whether the last page returned
/// a full page of items, since the backend's native Ninja pagination here
/// doesn't include a `has_next` flag in its response.
class CompanyDeliveryController extends Notifier<CompanyDeliveryState> {
  late final CompanyManagementRepository _repository;

  @override
  CompanyDeliveryState build() {
    _repository = getIt<CompanyManagementRepository>();
    return const CompanyDeliveryState();
  }

  Future<void> fetchFirstPage(int companyId) async {
    state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    try {
      final items = await _repository.listDeliveryOptions(companyId, page: 1, pageSize: _kPageSize);
      state = state.copyWith(isLoading: false, items: items, page: 1, hasMore: items.length >= _kPageSize);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage(int companyId) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final nextPage = state.page + 1;
      final items = await _repository.listDeliveryOptions(companyId, page: nextPage, pageSize: _kPageSize);
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...items],
        page: nextPage,
        hasMore: items.length >= _kPageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> createOption(int companyId, DeliveryOptionFormModel payload) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final created = await _repository.createDeliveryOption(companyId, payload);
      state = state.copyWith(isSaving: false, items: [created, ...state.items]);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteOption(int companyId, int optionId) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.deleteDeliveryOption(companyId, optionId);
      state = state.copyWith(isSaving: false, items: state.items.where((item) => item.id != optionId).toList());
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}

final companyDeliveryProvider = NotifierProvider<CompanyDeliveryController, CompanyDeliveryState>(
  CompanyDeliveryController.new,
);
