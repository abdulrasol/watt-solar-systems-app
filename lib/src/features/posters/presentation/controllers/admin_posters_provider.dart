import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart' as api;
import 'package:solar_hub/src/features/posters/data/data_sources/poster_remote_data_source.dart';
import 'package:solar_hub/src/features/posters/data/models/poster_model.dart';
import 'package:solar_hub/src/features/posters/domain/entities/poster_entity.dart';

class AdminPostersState {
  final bool isLoading;
  final String? error;
  final List<PosterEntity> items;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? statusFilter;
  final String? searchQuery;
  final String? validityFilter;

  const AdminPostersState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.statusFilter,
    this.searchQuery,
    this.validityFilter,
  });

  AdminPostersState copyWith({
    bool? isLoading,
    String? error,
    List<PosterEntity>? items,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? statusFilter,
    String? searchQuery,
    String? validityFilter,
  }) {
    return AdminPostersState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      validityFilter: validityFilter ?? this.validityFilter,
    );
  }
}

class AdminPostersController extends Notifier<AdminPostersState> {
  late final PosterRemoteDataSource _dataSource;

  @override
  AdminPostersState build() {
    _dataSource = getIt<PosterRemoteDataSource>();
    Future.microtask(() => fetchPosters(refresh: true));
    return const AdminPostersState(isLoading: true);
  }

  Future<void> fetchPosters({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null, currentPage: 1, hasMore: true, items: []);
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dataSource.fetchAdminPosters(
        page: 1,
        status: state.statusFilter,
        search: state.searchQuery,
        validity: state.validityFilter,
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

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final response = await _dataSource.fetchAdminPosters(
        page: nextPage,
        status: state.statusFilter,
        search: state.searchQuery,
        validity: state.validityFilter,
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

  void setStatusFilter(String? status) {
    state = AdminPostersState(
      isLoading: state.isLoading, items: [], hasMore: true, currentPage: 1,
      statusFilter: status, searchQuery: state.searchQuery, validityFilter: state.validityFilter,
    );
    fetchPosters();
  }

  void setValidityFilter(String? validity) {
    state = AdminPostersState(
      isLoading: state.isLoading, items: [], hasMore: true, currentPage: 1,
      statusFilter: state.statusFilter, searchQuery: state.searchQuery, validityFilter: validity,
    );
    fetchPosters();
  }

  void setSearchQuery(String? query) {
    state = AdminPostersState(
      isLoading: state.isLoading, items: [], hasMore: true, currentPage: 1,
      statusFilter: state.statusFilter, searchQuery: query, validityFilter: state.validityFilter,
    );
    fetchPosters();
  }

  Future<String?> reviewPoster(int posterId, String status, {int durationDays = 7}) async {
    try {
      final updated = await _dataSource.reviewPoster(
        posterId: posterId,
        status: status,
        durationDays: durationDays,
      );
      state = state.copyWith(
        items: state.items.map((p) => p.id == posterId ? updated.toEntity() : p).toList(),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> extendPoster(int posterId, String expiresAt) async {
    try {
      final updated = await _dataSource.extendPoster(posterId: posterId, expiresAt: expiresAt);
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

final adminPostersProvider = NotifierProvider<AdminPostersController, AdminPostersState>(
  AdminPostersController.new,
);
