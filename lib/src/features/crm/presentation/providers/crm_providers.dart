import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/crm/domain/entities/crm_models.dart';
import 'package:solar_hub/src/features/crm/domain/repositories/crm_repository.dart';
import 'package:solar_hub/src/features/orders_core/domain/entities/order_models.dart';

class CrmState<T> {
  final bool isLoading;
  final String? error;
  final List<T> items;
  final PaginationMeta pagination;

  const CrmState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.pagination = PaginationMeta.empty,
  });

  CrmState<T> copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<T>? items,
    PaginationMeta? pagination,
  }) {
    return CrmState<T>(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
    );
  }
}

class CustomersController extends StateNotifier<CrmState<CustomerRecord>> {
  final int companyId;
  final CrmRepository _repository;

  CustomersController(this.companyId, this._repository)
    : super(const CrmState<CustomerRecord>(isLoading: true)) {
    fetch();
  }

  Future<void> fetch([CustomerQuery query = const CustomerQuery()]) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.listCustomers(companyId, query: query);
      state = state.copyWith(
        isLoading: false,
        items: response.items,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final customersProvider =
    StateNotifierProvider.family<
      CustomersController,
      CrmState<CustomerRecord>,
      int
    >(
      (ref, companyId) =>
          CustomersController(companyId, getIt<CrmRepository>()),
    );

class SuppliersController extends StateNotifier<CrmState<SupplierRecord>> {
  final int companyId;
  final CrmRepository _repository;

  SuppliersController(this.companyId, this._repository)
    : super(const CrmState<SupplierRecord>(isLoading: true)) {
    fetch();
  }

  Future<void> fetch([SupplierQuery query = const SupplierQuery()]) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _repository.listSuppliers(companyId, query: query);
      state = state.copyWith(
        isLoading: false,
        items: response.items,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final suppliersProvider =
    StateNotifierProvider.family<
      SuppliersController,
      CrmState<SupplierRecord>,
      int
    >(
      (ref, companyId) =>
          SuppliersController(companyId, getIt<CrmRepository>()),
    );
