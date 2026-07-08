import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/models/response.dart' as api;
import 'package:watt/src/features/posters/data/data_sources/poster_remote_data_source.dart';
import 'package:watt/src/features/posters/data/models/poster_model.dart';
import 'package:watt/src/features/posters/domain/entities/poster_entity.dart';

class CompanyPostersState {
  final bool isLoading;
  final String? error;
  final List<PosterEntity> items;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? statusFilter;

  const CompanyPostersState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.statusFilter,
  });

  CompanyPostersState copyWith({
    bool? isLoading,
    String? error,
    List<PosterEntity>? items,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? statusFilter,
  }) {
    return CompanyPostersState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class CompanyPostersController extends Notifier<CompanyPostersState> {
  late final PosterRemoteDataSource _dataSource;

  @override
  CompanyPostersState build() {
    _dataSource = getIt<PosterRemoteDataSource>();
    return const CompanyPostersState();
  }

  Future<void> fetchPosters(int companyId, {bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1, hasMore: true, items: []);
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dataSource.fetchCompanyPosters(
        companyId: companyId,
        page: 1,
        status: state.statusFilter,
      );
      final items = _parseItems(response);
      state = state.copyWith(
        isLoading: false,
        items: items,
        currentPage: 1,
        hasMore: _hasMore(response),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore(int companyId) async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await _dataSource.fetchCompanyPosters(
        companyId: companyId,
        page: nextPage,
        status: state.statusFilter,
      );
      final newItems = _parseItems(response);
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...newItems],
        currentPage: nextPage,
        hasMore: _hasMore(response),
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void setStatusFilter(int companyId, String? status) {
    state = CompanyPostersState(
      isLoading: state.isLoading, items: [], hasMore: true, currentPage: 1,
      statusFilter: status,
    );
    fetchPosters(companyId);
  }

  Future<String?> deletePoster(int companyId, int posterId) async {
    try {
      await _dataSource.deletePoster(companyId: companyId, posterId: posterId);
      state = state.copyWith(
        items: state.items.where((p) => p.id != posterId).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleActive(int companyId, int posterId) async {
    try {
      final updated = await _dataSource.togglePosterActive(companyId: companyId, posterId: posterId);
      state = state.copyWith(
        items: state.items.map((p) => p.id == posterId ? updated.toEntity() : p).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  List<PosterEntity> _parseItems(api.PaginationResponse response) {
    final list = response.body as List;
    return list.map((e) => PosterModel.fromJson(Map<String, dynamic>.from(e)).toEntity()).toList();
  }

  bool _hasMore(api.PaginationResponse response) {
    final totalPages = (response.count ?? 0) ~/ 12 + 1;
    return state.currentPage < totalPages;
  }
}

final companyPostersProvider = NotifierProvider<CompanyPostersController, CompanyPostersState>(
  CompanyPostersController.new,
);
