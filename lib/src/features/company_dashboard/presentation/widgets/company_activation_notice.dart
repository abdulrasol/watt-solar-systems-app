import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/shared/domain/company/company.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/company_subscription_plan.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/models/company_subscription_request_form_model.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/controllers/company_activation_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:solar_hub/src/utils/app_constants.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyActivationNotice extends ConsumerStatefulWidget {
  const CompanyActivationNotice({super.key, required this.company});

  final Company company;

  @override
  ConsumerState<CompanyActivationNotice> createState() => _CompanyActivationNoticeState();
}

class _CompanyActivationNoticeState extends ConsumerState<CompanyActivationNotice> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(companyActivationProvider.notifier).syncCompany(widget.company));
  }

  @override
  void didUpdateWidget(covariant CompanyActivationNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.company.id != widget.company.id || oldWidget.company.requiresSubscriptionRenewal != widget.company.requiresSubscriptionRenewal) {
      Future.microtask(() => ref.read(companyActivationProvider.notifier).syncCompany(widget.company));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyActivationProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withValues(alpha: 0.12) : const Color(0xFFFFF6E7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withValues(alpha: isDark ? 0.28 : 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: _title(l10n), message: _message(l10n, state)),
          const SizedBox(height: 16),
          if (widget.company.isPendingActivation)
            _PendingCompanyContent(company: widget.company, state: state, onSendReminder: _sendReminder)
          else if (widget.company.requiresSubscriptionRenewal)
            _SubscriptionContent(
              company: widget.company,
              state: state,
              onRetry: () => ref.read(companyActivationProvider.notifier).loadSubscriptionPlans(),
              onSelectPlan: (planId) => ref.read(companyActivationProvider.notifier).selectPlan(planId),
              onOpenRequest: (plan) => _openSubscriptionSheet(context, plan),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final channel in appAdminSupportConfig.channels)
                _ContactActionButton(channel: channel, onPressed: channel.enabled ? () => _handleChannelTap(context, channel) : null),
            ],
          ),
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    if (widget.company.isPendingActivation) {
      return l10n.company_pending_activation_title;
    }
    if (widget.company.requiresSubscriptionRenewal) {
      return l10n.company_subscription_required_title;
    }
    return l10n.company_activation_required_title;
  }

  String _message(AppLocalizations l10n, CompanyActivationState state) {
    if (widget.company.isPendingActivation) {
      if (state.reminderResponse != null) {
        final availableAt = state.reminderResponse!.activationReminderAvailableAt;
        final availableLabel = availableAt == null ? '-' : _formatDateTime(availableAt);
        return l10n.company_activation_reminder_sent_message(availableLabel);
      }
      return l10n.company_pending_activation_message;
    }
    if (widget.company.requiresSubscriptionRenewal) {
      if (state.subscriptionRequest?.isPending == true) {
        return l10n.company_subscription_request_pending_message(state.subscriptionRequest!.subscriptionPlanName);
      }
      return l10n.company_subscription_required_message;
    }
    return l10n.company_activation_required_message;
  }

  Future<void> _sendReminder() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(companyActivationProvider.notifier).sendActivationReminder(widget.company.id);
      if (!mounted) return;
      ToastService.success(context, l10n.success, l10n.company_activation_reminder_sent);
    } catch (e) {
      if (!mounted) return;
      ToastService.error(context, l10n.error, e.toString());
    }
  }

  Future<void> _openSubscriptionSheet(BuildContext context, CompanySubscriptionPlan plan) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubscriptionRequestBottomSheet(
        plan: plan,
        isSubmitting: ref.watch(companyActivationProvider).isSubmittingSubscription,
        onSubmit: (payload) async {
          final l10n = AppLocalizations.of(context)!;
          try {
            final request = await ref.read(companyActivationProvider.notifier).createSubscriptionRequest(widget.company.id, payload);
            await ref.read(companySummeryProvider.notifier).getSummery();
            if (!context.mounted) return;
            ToastService.success(
              context,
              l10n.success,
              request.isPending
                  ? l10n.company_subscription_request_submitted
                  : l10n.company_updated_successfully,
            );
          } catch (e) {
            if (!context.mounted) return;
            ToastService.error(context, l10n.error, e.toString());
            rethrow;
          }
        },
      ),
    );
  }

  Future<void> _handleChannelTap(BuildContext context, AdminSupportChannel channel) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = switch (channel.type) {
      AdminSupportChannelType.phone => Uri.parse('tel:${channel.value.replaceAll(' ', '')}'),
      AdminSupportChannelType.email => Uri(scheme: 'mailto', path: channel.value, queryParameters: <String, String>{'subject': _title(l10n)}),
      AdminSupportChannelType.chat => null,
    };

    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ToastService.error(context, l10n.error, l10n.company_contact_admin_failed);
    }
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Iconsax.warning_2_bold, color: Colors.orange),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, height: 1.5, color: Theme.of(context).hintColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PendingCompanyContent extends StatelessWidget {
  const _PendingCompanyContent({required this.company, required this.state, required this.onSendReminder});

  final Company company;
  final CompanyActivationState state;
  final Future<void> Function() onSendReminder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.reminderResponse != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(18)),
        child: Text(
          l10n.company_activation_reminder_sent,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
        ),
      );
    }

    if (!company.canSendActivationReminderNow) {
      return const SizedBox.shrink();
    }

    return FilledButton.icon(
      onPressed: state.isSendingReminder ? null : onSendReminder,
      icon: state.isSendingReminder
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Iconsax.notification_bing_bold),
      label: Text(state.isSendingReminder ? l10n.loading : l10n.company_send_activation_reminder),
    );
  }
}

class _SubscriptionContent extends StatelessWidget {
  const _SubscriptionContent({required this.company, required this.state, required this.onRetry, required this.onSelectPlan, required this.onOpenRequest});

  final Company company;
  final CompanyActivationState state;
  final VoidCallback onRetry;
  final ValueChanged<int> onSelectPlan;
  final ValueChanged<CompanySubscriptionPlan> onOpenRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (state.subscriptionRequest?.isPending == true) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            const Icon(Iconsax.clock_bold, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.company_subscription_request_pending,
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    if (state.isLoadingPlans) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.plansError != null && state.plans.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.company_subscription_plans_error,
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Iconsax.refresh_bold), label: Text(l10n.retry)),
        ],
      );
    }

    if (state.plans.isEmpty) {
      return Text(
        l10n.company_subscription_plans_empty,
        style: TextStyle(fontFamily: AppTheme.fontFamily, color: Theme.of(context).hintColor),
      );
    }

    final selectedPlan = state.selectedPlan ?? state.plans.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.company_subscription_available_plans,
          style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final plan in state.plans) ...[
          _PlanCard(plan: plan, selected: plan.id == selectedPlan.id, onTap: () => onSelectPlan(plan.id)),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        FilledButton.icon(
          onPressed: () => onOpenRequest(selectedPlan),
          icon: const Icon(Iconsax.card_pos_bold),
          label: Text(l10n.company_subscription_request_cta),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.selected, required this.onTap});

  final CompanySubscriptionPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppTheme.primaryColor : Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w800),
                  ),
                ),
                if (selected) const Icon(Iconsax.tick_circle_bold, color: AppTheme.primaryColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.company_subscription_plan_meta(plan.durationDays.toString(), plan.price.toString()),
              style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
            ),
            if ((plan.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                plan.description!,
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, color: Theme.of(context).hintColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ContactActionButton extends StatelessWidget {
  const _ContactActionButton({required this.channel, this.onPressed});

  final AdminSupportChannel channel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (channel.type) {
      AdminSupportChannelType.phone => l10n.company_call_admin,
      AdminSupportChannelType.email => l10n.company_email_admin,
      AdminSupportChannelType.chat => l10n.company_chat_admin_coming_soon,
    };
    final icon = switch (channel.type) {
      AdminSupportChannelType.phone => Iconsax.call_bold,
      AdminSupportChannelType.email => Iconsax.sms_bold,
      AdminSupportChannelType.chat => Iconsax.message_bold,
    };

    return OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label));
  }
}

class _SubscriptionRequestBottomSheet extends StatefulWidget {
  const _SubscriptionRequestBottomSheet({required this.plan, required this.isSubmitting, required this.onSubmit});

  final CompanySubscriptionPlan plan;
  final bool isSubmitting;
  final Future<void> Function(CompanySubscriptionRequestFormModel payload) onSubmit;

  @override
  State<_SubscriptionRequestBottomSheet> createState() => _SubscriptionRequestBottomSheetState();
}

class _SubscriptionRequestBottomSheetState extends State<_SubscriptionRequestBottomSheet> {
  final _notesController = TextEditingController();
  File? _image;
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _showSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.image_bold),
              title: Text(l10n.gallery),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.camera_bold),
              title: Text(l10n.camera),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(
        CompanySubscriptionRequestFormModel(
          subscriptionPlan: widget.plan.id,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          imagePath: _image?.path,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSubmitting = _submitting || widget.isSubmitting;

    return Container(
      padding: EdgeInsets.only(left: 24.w, top: 24.h, right: 24.w, bottom: MediaQuery.of(context).viewInsets.bottom + 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.company_subscription_request_cta,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.plan.name,
              style: TextStyle(fontSize: 14.sp, color: Theme.of(context).hintColor, fontFamily: AppTheme.fontFamily),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.company_subscription_notes, border: const OutlineInputBorder()),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.company_subscription_image_optional,
              style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            InkWell(
              onTap: _showSourceDialog,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 130.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.image_bold, size: 34.sp, color: Colors.grey),
                          SizedBox(height: 8.h),
                          Text(l10n.upload_logo),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : _submit,
                icon: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Iconsax.send_1_bold),
                label: Text(isSubmitting ? l10n.loading : l10n.company_subscription_submit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
