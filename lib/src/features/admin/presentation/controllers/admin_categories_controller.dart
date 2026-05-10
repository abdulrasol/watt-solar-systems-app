import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_global_category.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class AdminCategoriesState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<AdminGlobalCategory> categories;
  final int page;

  AdminCategoriesState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.categories = const [],
    this.page = 1,
  });

  AdminCategoriesState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<AdminGlobalCategory>? categories,
    int? page,
  }) {
    return AdminCategoriesState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      categories: categories ?? this.categories,
      page: page ?? this.page,
    );
  }
}

class AdminCategoriesController extends Notifier<AdminCategoriesState> {
  late AdminRepository _repository;

  @override
  AdminCategoriesState build() {
    _repository = getIt<AdminRepository>();
    return AdminCategoriesState();
  }

  Future<void> fetchCategories({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        categories: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final categories = await _repository.listGlobalCategories(
        page: state.page,
        pageSize: 12,
      );
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        categories: isRefresh ? categories : [...state.categories, ...categories],
        hasMore: categories.length >= 12,
      );
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchCategories();
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    try {
      final newCategory = await _repository.createGlobalCategory(data);
      state = state.copyWith(categories: [newCategory, ...state.categories]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final updatedCategory = await _repository.updateGlobalCategory(id, data);
      state = state.copyWith(
        categories: state.categories.map((c) => c.id == id ? updatedCategory : c).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _repository.deleteGlobalCategory(id);
      state = state.copyWith(
        categories: state.categories.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminCategoriesProvider = NotifierProvider<AdminCategoriesController, AdminCategoriesState>(() {
  return AdminCategoriesController();
});
