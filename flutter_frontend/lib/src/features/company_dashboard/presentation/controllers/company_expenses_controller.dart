import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/shared/domain/company/company_expense.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_expense_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

const int _kPageSize = 12;

class CompanyExpensesState {
  const CompanyExpensesState({
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
  final List<CompanyExpense> items;
  final int page;
  final bool hasMore;

  double get totalAmount => items.fold<double>(0, (sum, item) => sum + item.amount);

  CompanyExpensesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isSaving,
    Object? error = _sentinel,
    List<CompanyExpense>? items,
    int? page,
    bool? hasMore,
  }) {
    return CompanyExpensesState(
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

class CompanyExpensesController extends Notifier<CompanyExpensesState> {
  late final CompanyManagementRepository _repository;

  @override
  CompanyExpensesState build() {
    _repository = getIt<CompanyManagementRepository>();
    return const CompanyExpensesState();
  }

  Future<void> fetchFirstPage(int companyId) async {
    state = state.copyWith(isLoading: true, error: null, page: 1, hasMore: true);
    try {
      final items = await _repository.listExpenses(companyId, page: 1, pageSize: _kPageSize);
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
      final items = await _repository.listExpenses(companyId, page: nextPage, pageSize: _kPageSize);
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

  Future<void> createExpense(int companyId, CompanyExpenseFormModel payload) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final created = await _repository.createExpense(companyId, payload);
      state = state.copyWith(isSaving: false, items: [created, ...state.items]);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteExpense(int companyId, int expenseId) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.deleteExpense(companyId, expenseId);
      state = state.copyWith(isSaving: false, items: state.items.where((item) => item.id != expenseId).toList());
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}

final companyExpensesProvider = NotifierProvider<CompanyExpensesController, CompanyExpensesState>(
  CompanyExpensesController.new,
);
