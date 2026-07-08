import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/members/domain/entities/company_member.dart';
import 'package:watt/src/features/members/domain/entities/member_role.dart';
import 'package:watt/src/utils/app_theme.dart';

class MemberRoleDialog extends StatefulWidget {
  final CompanyMember member;
  final Function(MemberRole) onRoleSelected;

  const MemberRoleDialog({
    super.key,
    required this.member,
    required this.onRoleSelected,
  });

  @override
  State<MemberRoleDialog> createState() => _MemberRoleDialogState();
}

class _MemberRoleDialogState extends State<MemberRoleDialog> {
  late MemberRole _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member.role;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        'Change Member Role',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 400.w,
        child: SingleChildScrollView(
          child: RadioGroup<MemberRole>(
            groupValue: _selectedRole,
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedRole = value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: MemberRole.values.map((role) {
                return RadioListTile<MemberRole>(
                  title: Text(_getRoleLabel(l10n, role)),
                  subtitle: Text(_getRoleDescription(role)),
                  value: role,
                  activeColor: AppTheme.primaryColor,
                );
              }).toList(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onRoleSelected(_selectedRole);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Update Role'),
        ),
      ],
    );
  }

  String _getRoleLabel(AppLocalizations l10n, MemberRole role) {
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

  String _getRoleDescription(MemberRole role) {
    switch (role) {
      case MemberRole.admin:
        return 'Full access to all features and settings.';
      case MemberRole.manager:
        return 'Can manage teams and view analytics.';
      case MemberRole.staff:
        return 'Standard access to daily operations.';
      case MemberRole.accountant:
        return 'Manage invoices, bills, and financial records.';
      case MemberRole.delivery:
        return 'Access to shipping and delivery management.';
      case MemberRole.installer:
        return 'Access to installation schedules and tasks.';
      case MemberRole.inventory:
        return 'Manage products and stock levels.';
      case MemberRole.sales:
        return 'Manage leads, quotes, and customers.';
    }
  }
}
