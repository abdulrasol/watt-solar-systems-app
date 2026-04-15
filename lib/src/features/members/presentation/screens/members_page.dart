import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/pre_scaffold.dart';
import 'package:solar_hub/src/features/admin/presentation/widgets/admin_widgets.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/members/domain/entities/company_member.dart';
import 'package:solar_hub/src/features/members/domain/entities/member_role.dart';
import 'package:solar_hub/src/features/members/presentation/providers/members_provider.dart';
import 'package:solar_hub/src/features/members/presentation/widgets/add_member_sheet.dart';
import 'package:solar_hub/src/features/members/presentation/widgets/member_card.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class MembersPage extends ConsumerStatefulWidget {
  const MembersPage({super.key});

  @override
  ConsumerState<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends ConsumerState<MembersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final companyId = ref.read(authProvider).company?.id;
      if (companyId != null) {
        ref
            .read(membersProvider.notifier)
            .fetchMembers(companyId, isRefresh: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final membersState = ref.watch(membersProvider);
    final company = authState.company;
    final l10n = AppLocalizations.of(context)!;
    final companyId = company?.id;
    final currentRole = MemberRole.fromValue(company?.memberRole);
    final canManageMembers =
        currentRole == MemberRole.admin || currentRole == MemberRole.manager;

    return PreScaffold(
      title: l10n.members,
      actions: [
        if (canManageMembers && companyId != null)
          IconButton(
            tooltip: l10n.members_add_member,
            onPressed: () => _openAddMemberSheet(context, companyId),
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
      ],
      child: Builder(
        builder: (context) {
          if (companyId == null) {
            return AdminEmptyState(
              icon: Icons.business_outlined,
              title: l10n.members,
              subtitle: l10n.members_company_required,
            );
          }

          if (membersState.isLoading && membersState.members.isEmpty) {
            return const AdminLoadingState(
              icon: Icons.group_outlined,
              message: 'Loading members...',
            );
          }

          if (membersState.error != null && membersState.members.isEmpty) {
            return AdminErrorState(
              error: membersState.error!,
              onRetry: () => ref
                  .read(membersProvider.notifier)
                  .fetchMembers(companyId, isRefresh: true),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref
                .read(membersProvider.notifier)
                .fetchMembers(companyId, isRefresh: true),
            child: membersState.members.isEmpty
                ? ListView(
                    children: [
                      SizedBox(height: 100.h),
                      AdminEmptyState(
                        icon: Icons.group_outlined,
                        title: l10n.members_empty_title,
                        subtitle: l10n.members_empty_subtitle,
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: membersState.members.length + 1,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _MembersHeader(
                          membersCount: membersState.members.length,
                          canManageMembers: canManageMembers,
                          onAddPressed: canManageMembers
                              ? () => _openAddMemberSheet(context, companyId)
                              : null,
                        );
                      }

                      final member = membersState.members[index - 1];
                      final canRemove = _canRemoveMember(
                        currentRole: currentRole,
                        currentUserId: authState.user?.id,
                        member: member,
                      );

                      return MemberCard(
                        member: member,
                        canRemove: canRemove,
                        isRemoving: membersState.removingIds.contains(
                          member.id,
                        ),
                        onRemove: () => _confirmDelete(
                          context,
                          companyId: companyId,
                          member: member,
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  bool _canRemoveMember({
    required MemberRole currentRole,
    required dynamic currentUserId,
    required CompanyMember member,
  }) {
    final memberRole = member.role;
    if (currentUserId != null && member.id == currentUserId) {
      return false;
    }
    if (currentRole == MemberRole.admin) {
      return true;
    }
    if (currentRole == MemberRole.manager) {
      return memberRole != MemberRole.admin;
    }
    return false;
  }

  void _openAddMemberSheet(BuildContext context, int companyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddMemberSheet(companyId: companyId),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context, {
    required int companyId,
    required CompanyMember member,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.members_remove_member),
        content: Text(
          l10n.members_remove_confirmation(
            member.username.isEmpty ? member.email : member.username,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;
    final success = await ref
        .read(membersProvider.notifier)
        .deleteMember(companyId, member.id);

    if (!context.mounted) return;
    if (success) {
      ToastService.success(context, l10n.members, l10n.members_remove_success);
    } else {
      ToastService.error(
        context,
        l10n.error,
        ref.read(membersProvider).error ?? l10n.members_remove_failed,
      );
    }
  }
}

class _MembersHeader extends StatelessWidget {
  const _MembersHeader({
    required this.membersCount,
    required this.canManageMembers,
    required this.onAddPressed,
  });

  final int membersCount;
  final bool canManageMembers;
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.members_team_overview,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  l10n.members_count_summary(membersCount),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (canManageMembers)
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(l10n.members_add_member),
            ),
        ],
      ),
    );
  }
}
