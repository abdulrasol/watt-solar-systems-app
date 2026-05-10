import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_currency.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class AdminCurrencyState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<AdminCurrency> currencies;
  final int page;

  AdminCurrencyState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.currencies = const [],
    this.page = 1,
  });

  AdminCurrencyState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<AdminCurrency>? currencies,
    int? page,
  }) {
    return AdminCurrencyState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      currencies: currencies ?? this.currencies,
      page: page ?? this.page,
    );
  }
}

class AdminCurrencyController extends Notifier<AdminCurrencyState> {
  late AdminRepository _repository;

  @override
  AdminCurrencyState build() {
    _repository = getIt<AdminRepository>();
    return AdminCurrencyState();
  }

  Future<void> fetchCurrencies({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        currencies: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final currencies = await _repository.listCurrencies(
        page: state.page,
        pageSize: 12,
      );
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        currencies: isRefresh ? currencies : [...state.currencies, ...currencies],
        hasMore: currencies.length >= 12,
      );
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchCurrencies();
  }

  Future<void> createCurrency(Map<String, dynamic> data) async {
    try {
      final newCurrency = await _repository.createCurrency(data);
      state = state.copyWith(currencies: [newCurrency, ...state.currencies]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCurrency(int id, Map<String, dynamic> data) async {
    try {
      final updatedCurrency = await _repository.updateCurrency(id, data);
      state = state.copyWith(
        currencies: state.currencies.map((c) => c.id == id ? updatedCurrency : c).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCurrency(int id) async {
    try {
      await _repository.deleteCurrency(id);
      state = state.copyWith(
        currencies: state.currencies.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminCurrencyProvider = NotifierProvider<AdminCurrencyController, AdminCurrencyState>(() {
  return AdminCurrencyController();
});
