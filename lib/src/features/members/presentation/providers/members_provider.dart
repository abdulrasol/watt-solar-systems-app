import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/members/domain/entities/company_member.dart';
import 'package:solar_hub/src/features/members/domain/entities/member_role.dart';
import 'package:solar_hub/src/features/members/domain/repositories/members_repository.dart';

class MembersFallbackState {
  final bool requiresRegistration;
  final String? email;
  final MemberRole? role;
  final String? message;

  const MembersFallbackState({
    this.requiresRegistration = false,
    this.email,
    this.role,
    this.message,
  });

  MembersFallbackState copyWith({
    bool? requiresRegistration,
    String? email,
    MemberRole? role,
    String? message,
  }) {
    return MembersFallbackState(
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      email: email ?? this.email,
      role: role ?? this.role,
      message: message ?? this.message,
    );
  }

  static const empty = MembersFallbackState();
}

class MembersState {
  final List<CompanyMember> members;
  final bool isLoading;
  final bool isSubmitting;
  final Set<int> removingIds;
  final String? error;
  final MembersFallbackState inviteFallback;

  const MembersState({
    this.members = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.removingIds = const {},
    this.error,
    this.inviteFallback = MembersFallbackState.empty,
  });

  MembersState copyWith({
    List<CompanyMember>? members,
    bool? isLoading,
    bool? isSubmitting,
    Set<int>? removingIds,
    String? error,
    bool clearError = false,
    MembersFallbackState? inviteFallback,
  }) {
    return MembersState(
      members: members ?? this.members,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      removingIds: removingIds ?? this.removingIds,
      error: clearError ? null : (error ?? this.error),
      inviteFallback: inviteFallback ?? this.inviteFallback,
    );
  }
}

class MembersNotifier extends Notifier<MembersState> {
  final MembersRepository _repository = getIt<MembersRepository>();

  @override
  MembersState build() {
    return const MembersState();
  }

  Future<void> fetchMembers(int companyId, {bool isRefresh = false}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      inviteFallback: MembersFallbackState.empty,
    );

    try {
      final members = await _repository.getMembers(companyId);
      state = state.copyWith(
        isLoading: false,
        members: members,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<MemberInviteSubmitResult> inviteMember(
    int companyId, {
    required String email,
    required MemberRole role,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      inviteFallback: MembersFallbackState.empty,
    );

    try {
      final result = await _repository.inviteMember(companyId, {
        'email': email,
        'role': role.value,
      });

      if (result.requiresRegistration) {
        final fallback = MembersFallbackState(
          requiresRegistration: true,
          email: email,
          role: role,
          message: result.messageUser.isNotEmpty
              ? result.messageUser
              : result.message,
        );
        state = state.copyWith(isSubmitting: false, inviteFallback: fallback);
        return MemberInviteSubmitResult.requiresRegistration(fallback.message);
      }

      await fetchMembers(companyId, isRefresh: true);
      state = state.copyWith(
        isSubmitting: false,
        inviteFallback: MembersFallbackState.empty,
      );
      return MemberInviteSubmitResult.success(
        result.messageUser.isNotEmpty ? result.messageUser : result.message,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return MemberInviteSubmitResult.failure(e.toString());
    }
  }

  Future<MemberCreateSubmitResult> createMember(
    int companyId, {
    required String email,
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required MemberRole role,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.createMember(companyId, {
        'email': email,
        'username': username,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'role': role.value,
      });

      await fetchMembers(companyId, isRefresh: true);
      state = state.copyWith(
        isSubmitting: false,
        inviteFallback: MembersFallbackState.empty,
      );
      return const MemberCreateSubmitResult.success();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return MemberCreateSubmitResult.failure(e.toString());
    }
  }

  Future<bool> deleteMember(int companyId, int memberId) async {
    final removingIds = {...state.removingIds, memberId};
    state = state.copyWith(removingIds: removingIds, clearError: true);

    try {
      await _repository.deleteMember(companyId, memberId);
      state = state.copyWith(
        members: state.members
            .where((member) => member.id != memberId)
            .toList(),
        removingIds: {...state.removingIds}..remove(memberId),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        removingIds: {...state.removingIds}..remove(memberId),
        error: e.toString(),
      );
      return false;
    }
  }

  void clearFallback() {
    state = state.copyWith(inviteFallback: MembersFallbackState.empty);
  }
}

class MemberInviteSubmitResult {
  final bool isSuccess;
  final bool requiresRegistration;
  final String? message;

  const MemberInviteSubmitResult._({
    required this.isSuccess,
    required this.requiresRegistration,
    this.message,
  });

  const MemberInviteSubmitResult.success(String? message)
    : this._(isSuccess: true, requiresRegistration: false, message: message);

  const MemberInviteSubmitResult.requiresRegistration(String? message)
    : this._(isSuccess: false, requiresRegistration: true, message: message);

  const MemberInviteSubmitResult.failure(String? message)
    : this._(isSuccess: false, requiresRegistration: false, message: message);
}

class MemberCreateSubmitResult {
  final bool isSuccess;
  final String? message;

  const MemberCreateSubmitResult._({required this.isSuccess, this.message});

  const MemberCreateSubmitResult.success() : this._(isSuccess: true);

  const MemberCreateSubmitResult.failure(String? message)
    : this._(isSuccess: false, message: message);
}

final membersProvider = NotifierProvider<MembersNotifier, MembersState>(
  MembersNotifier.new,
);
