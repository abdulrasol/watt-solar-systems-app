import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_user.dart';
import 'package:solar_hub/src/features/admin/domain/repositories/admin_repository.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class AdminUsersState {
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? error;
  final List<AdminUser> users;
  final int page;

  AdminUsersState({
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
    this.users = const [],
    this.page = 1,
  });

  AdminUsersState copyWith({
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    List<AdminUser>? users,
    int? page,
  }) {
    return AdminUsersState(
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      users: users ?? this.users,
      page: page ?? this.page,
    );
  }
}

class AdminUsersController extends Notifier<AdminUsersState> {
  late AdminRepository _repository;

  @override
  AdminUsersState build() {
    _repository = getIt<AdminRepository>();
    return AdminUsersState();
  }

  Future<void> fetchUsers({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        hasMore: true,
        page: 1,
        error: null,
        users: [],
      );
    } else {
      if (state.isMoreLoading || !state.hasMore) return;
      state = state.copyWith(isMoreLoading: true, error: null);
    }

    try {
      final users = await _repository.listUsers(
        page: state.page,
        pageSize: 12,
      );
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        users: isRefresh ? users : [...state.users, ...users],
        hasMore: users.length >= 12,
      );
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      state = state.copyWith(isLoading: false, isMoreLoading: false, error: e.toString());
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isMoreLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await fetchUsers();
  }

  Future<void> promoteUser(String username, bool promote) async {
    try {
      await _repository.promoteUser(username, promote);
      state = state.copyWith(
        users: state.users.map((u) => u.username == username ? u.copyWith(isSuperuser: promote) : u).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final adminUsersProvider = NotifierProvider<AdminUsersController, AdminUsersState>(() {
  return AdminUsersController();
});
