import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/members/domain/entities/member_role.dart';
import 'package:solar_hub/src/features/members/presentation/providers/members_provider.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AddMemberSheet extends ConsumerStatefulWidget {
  const AddMemberSheet({super.key, required this.companyId});

  final int companyId;

  @override
  ConsumerState<AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends ConsumerState<AddMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  MemberRole _role = MemberRole.staff;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final fallback = ref.read(membersProvider).inviteFallback;
    if (fallback.requiresRegistration) {
      _emailController.text = fallback.email ?? '';
      _role = fallback.role ?? MemberRole.staff;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(membersProvider);
    final l10n = AppLocalizations.of(context)!;
    final requiresRegistration = state.inviteFallback.requiresRegistration;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  requiresRegistration
                      ? l10n.members_create_title
                      : l10n.members_add_member,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  requiresRegistration
                      ? (state.inviteFallback.message?.isNotEmpty == true
                            ? state.inviteFallback.message!
                            : l10n.members_create_description)
                      : l10n.members_invite_description,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildTextField(
                  controller: _emailController,
                  label: l10n.members_email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.members_email_required;
                    }
                    if (!value.contains('@')) {
                      return l10n.members_email_invalid;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                _buildRoleDropdown(l10n),
                if (requiresRegistration) ...[
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: _usernameController,
                    label: l10n.members_username,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.members_username_required;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: _passwordController,
                    label: l10n.members_password,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.members_password_required;
                      }
                      if (value.length < 6) {
                        return l10n.members_password_too_short;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: _firstNameController,
                    label: l10n.members_first_name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.members_first_name_required;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  _buildTextField(
                    controller: _lastNameController,
                    label: l10n.members_last_name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.members_last_name_required;
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 22.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.isSubmitting ? null : _submit,
                    child: state.isSubmitting
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            requiresRegistration
                                ? l10n.members_create_member
                                : l10n.members_invite_member,
                          ),
                  ),
                ),
                if (requiresRegistration) ...[
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              ref
                                  .read(membersProvider.notifier)
                                  .clearFallback();
                              setState(() {});
                            },
                      child: Text(l10n.members_back_to_invite),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(membersProvider.notifier);
    final state = ref.read(membersProvider);

    if (state.inviteFallback.requiresRegistration) {
      final result = await notifier.createMember(
        widget.companyId,
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _role,
      );

      if (!mounted) return;
      if (result.isSuccess) {
        ToastService.success(
          context,
          l10n.members,
          l10n.members_create_success,
        );
        Navigator.of(context).pop();
      } else {
        ToastService.error(
          context,
          l10n.error,
          result.message ?? l10n.members_create_failed,
        );
      }
      return;
    }

    final result = await notifier.inviteMember(
      widget.companyId,
      email: _emailController.text.trim(),
      role: _role,
    );

    if (!mounted) return;
    if (result.isSuccess) {
      ToastService.success(
        context,
        l10n.members,
        result.message ?? l10n.members_invite_success,
      );
      Navigator.of(context).pop();
      return;
    }

    if (result.requiresRegistration) {
      ToastService.info(
        context,
        l10n.members,
        result.message ?? l10n.members_requires_registration,
      );
      setState(() {});
      return;
    }

    ToastService.error(
      context,
      l10n.error,
      result.message ?? l10n.members_invite_failed,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
    );
  }

  Widget _buildRoleDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<MemberRole>(
      initialValue: _role,
      decoration: InputDecoration(
        labelText: l10n.members_role,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
      items: MemberRole.values
          .map(
            (role) => DropdownMenuItem<MemberRole>(
              value: role,
              child: Text(_roleLabel(l10n, role)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _role = value);
      },
    );
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
