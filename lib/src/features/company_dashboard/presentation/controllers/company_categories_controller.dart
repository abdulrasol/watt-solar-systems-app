import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/shared/domain/company/company_category.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_category_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_management_repository.dart';

class CompanyCategoriesState {
  const CompanyCategoriesState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.categories = const [],
  });

  final bool isLoading;
  final bool isSaving;
  final String? error;
  final List<CompanyCategory> categories;

  CompanyCategoriesState copyWith({
    bool? isLoading,
    bool? isSaving,
    Object? error = _categoriesSentinel,
    List<CompanyCategory>? categories,
  }) {
    return CompanyCategoriesState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error == _categoriesSentinel ? this.error : error as String?,
      categories: categories ?? this.categories,
    );
  }
}

const _categoriesSentinel = Object();

class CompanyCategoriesController extends Notifier<CompanyCategoriesState> {
  late final CompanyManagementRepository _repository;

  @override
  CompanyCategoriesState build() {
    _repository = getIt<CompanyManagementRepository>();
    return const CompanyCategoriesState();
  }

  Future<void> fetchCategories(int companyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final categories = await _repository.listCategories(companyId);
      state = state.copyWith(isLoading: false, categories: categories);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCategory(
    int companyId,
    CompanyCategoryFormModel payload,
  ) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final category = await _repository.createCategory(companyId, payload);
      state = state.copyWith(
        isSaving: false,
        categories: [...state.categories, category],
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteCategory(int companyId, int categoryId) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repository.deleteCategory(companyId, categoryId);
      state = state.copyWith(
        isSaving: false,
        categories: state.categories
            .where((item) => item.id != categoryId)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }
}

final companyCategoriesProvider =
    NotifierProvider<CompanyCategoriesController, CompanyCategoriesState>(
      CompanyCategoriesController.new,
    );
