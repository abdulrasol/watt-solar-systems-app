import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/members/domain/entities/company_member.dart';
import 'package:solar_hub/src/features/members/domain/entities/member_role.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.member,
    required this.canRemove,
    required this.isRemoving,
    required this.onRemove,
  });

  final CompanyMember member;
  final bool canRemove;
  final bool isRemoving;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
            child: Text(
              _initials(member.username, member.email),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.username.isEmpty ? member.email : member.username,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  member.email,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _MemberBadge(
                      label: _roleLabel(l10n, member.role),
                      color: _roleColor(member.role),
                    ),
                    if (member.joinedAt != null)
                      _MemberBadge(
                        label: l10n.members_joined_on(
                          DateFormat.yMMMd().format(member.joinedAt!.toLocal()),
                        ),
                        color: Colors.blueGrey,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (canRemove)
            IconButton(
              tooltip: l10n.members_remove_member,
              onPressed: isRemoving ? null : onRemove,
              icon: isRemoving
                  ? SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }

  String _initials(String username, String email) {
    final source = username.isNotEmpty ? username : email;
    return source.substring(0, 1).toUpperCase();
  }

  Color _roleColor(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return AppTheme.primaryColor;
      case MemberRole.manager:
        return Colors.orange;
      case MemberRole.staff:
        return Colors.blue;
      case MemberRole.accountant:
        return Colors.teal;
      case MemberRole.delivery:
        return Colors.indigo;
      case MemberRole.installer:
        return Colors.green;
      case MemberRole.inventory:
        return Colors.brown;
      case MemberRole.sales:
        return Colors.pink;
    }
  }

  String _roleLabel(AppLocalizations l10n, MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return l10n.members_role_admin;
      case MemberRole.manager:
        return l10n.members_role_manager;
      case MemberRole.staff:
        return l10n.members_role_staff;
      case MemberRole.accountant:
        return l10n.members_role_accountant;
      case MemberRole.delivery:
        return l10n.members_role_delivery;
      case MemberRole.installer:
        return l10n.members_role_installer;
      case MemberRole.inventory:
        return l10n.members_role_inventory;
      case MemberRole.sales:
        return l10n.members_role_sales;
    }
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
