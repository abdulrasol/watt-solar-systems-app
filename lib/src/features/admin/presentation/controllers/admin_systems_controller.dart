import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/data/data_sources/admin_remote_data_source.dart';
import 'package:solar_hub/src/features/calculations/domain/entities/system_model.dart';

class AdminSystemsState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<SystemModel> systems;
  final int page;

  AdminSystemsState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.systems = const [],
    this.page = 1,
  });

  AdminSystemsState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<SystemModel>? systems,
    int? page,
  }) {
    return AdminSystemsState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      systems: systems ?? this.systems,
      page: page ?? this.page,
    );
  }
}

class AdminSystemsController extends Notifier<AdminSystemsState> {
  late AdminRemoteDataSource _adminDataSource;

  @override
  AdminSystemsState build() {
    _adminDataSource = getIt<AdminRemoteDataSource>();
    return AdminSystemsState();
  }

  Future<void> fetchSystems({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        systems: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final response = await _adminDataSource.listAdminSystems(
        page: state.page,
        pageSize: 12,
      );
      final systemsList = (response.body as List)
          .map((e) => SystemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        systems: isRefresh ? systemsList : [...state.systems, ...systemsList],
        hasMore: systemsList.length >= 12,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        error: 'Failed to load systems: ${e.toString()}',
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchSystems();
  }
}

final adminSystemsProvider =
    NotifierProvider<AdminSystemsController, AdminSystemsState>(() {
  return AdminSystemsController();
});
