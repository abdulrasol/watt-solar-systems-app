import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_offer.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/offer_reply_form.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/services/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';

class OfferDetailsScreen extends ConsumerWidget {
  final SolarOffer offer;
  final bool isCompanyView;

  const OfferDetailsScreen({
    super.key,
    required this.offer,
    this.isCompanyView = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.offer_details,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          _buildCompanyHeader(context),
          SizedBox(height: 24.h),
          _buildPriceSection(
            l10n.offering_price,
            offer.price,
            isHighlight: true,
          ),
          SizedBox(height: 24.h),
          Text(
            l10n.technical_specifications,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSpecList(context),
          if (offer.involves != null && offer.involves!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              l10n.included_services_items,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 12.h),
            ...offer.involves!.map((item) => _buildInvolveItem(item)),
          ],
          if (offer.note != null && offer.note!.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              l10n.notes_from_provider,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
              child: Text(
                offer.note!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.78),
                  height: 1.5,
                ),
              ),
            ),
          ],
          SizedBox(height: 32.h),
          const Divider(),
          SizedBox(height: 16.h),
          _buildActionArea(context, ref),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        CircleAvatar(
          radius: 28.r,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
          child: offer.company.logo != null
              ? WdImagePreview(imageUrl: offer.company.logo!)
              : const Icon(
                  Iconsax.building_bold,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.company.name,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              Text(
                offer.createdAt != null
                    ? l10n.submitted_on_date(
                        '${offer.createdAt!.day}/${offer.createdAt!.month}/${offer.createdAt!.year}',
                      )
                    : l10n.quotation,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: offer.status.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            offer.status.localizedLabel(l10n),
            style: TextStyle(
              fontSize: 12.sp,
              color: offer.status.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(
    String label,
    double value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: isHighlight ? 24.sp : 18.sp,
            fontWeight: FontWeight.w900,
            color: isHighlight ? AppTheme.primaryColor : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildSpecRow(
          context,
          l10n.panels,
          '${offer.panelCount} x ${offer.panelPower}W',
          note: offer.panelNote,
          icon: Iconsax.sun_1_bold,
        ),
        SizedBox(height: 12.h),
        _buildSpecRow(
          context,
          l10n.battery_storage,
          '${offer.batteryCount} x ${_formatNumber(offer.batterySize)}Wh (${offer.batteryType.localizedLabel(l10n)})',
          note: offer.batteryNote,
          icon: Iconsax.flash_1_bold,
        ),
        SizedBox(height: 12.h),
        _buildSpecRow(
          context,
          l10n.inverter_calc,
          '${_formatNumber(offer.inverterSize)}W (${offer.inverterType.localizedLabel(l10n)})',
          note: offer.inverterNote,
          icon: Iconsax.setting_2_bold,
        ),
      ],
    );
  }

  Widget _buildSpecRow(
    BuildContext context,
    String label,
    String value, {
    String? note,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: onSurface.withValues(alpha: 0.64),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                if (note != null && note.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: onSurface.withValues(alpha: 0.72),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvolveItem(dynamic item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ),
          Text(
            'x${item.quantity ?? 1}',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          SizedBox(width: 24.w),
          Text(
            '\$${(item.totalCost ?? (item.cost * (item.quantity ?? 1))).toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, WidgetRef ref) {
    return isCompanyView
        ? _buildCompanyActionArea(context, ref)
        : _buildUserActionArea(context, ref);
  }

  Widget _buildUserActionArea(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    final contactNumber = authState.company?.phone?.trim();
    final hasContact = contactNumber != null && contactNumber.isNotEmpty;

    return Column(
      children: [
        _buildGrandTotalRow(context),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasContact
                    ? () => _openWhatsApp(context, contactNumber)
                    : () => _showMissingContact(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: const Icon(Iconsax.whatsapp_bold),
                label: Text(l10n.whatsapp),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: hasContact
                    ? () => _openCall(context, contactNumber)
                    : () => _showMissingContact(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: const Icon(Iconsax.call_bold),
                label: Text(l10n.call),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () async {
                  await ref
                      .read(offersProvider.notifier)
                      .respondToOffer(offer.id!, 'rejected');
                  if (context.mounted) Navigator.pop(context);
                },
                child: Text(
                  l10n.reject_offer,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(offersProvider.notifier)
                      .respondToOffer(offer.id!, 'accepted');
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(l10n.accept_offer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanyActionArea(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isPending = offer.status == OfferStatus.pending;
    final isRejected = offer.status == OfferStatus.rejected;
    final isAccepted = offer.status == OfferStatus.accepted;

    return Column(
      children: [
        _buildGrandTotalRow(context),
        SizedBox(height: 24.h),
        if (isPending || isRejected) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openEditForm(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: const Icon(Iconsax.edit_bold),
                  label: Text(_tr(context, 'Edit', 'تعديل')),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(context, ref),
                  icon: const Icon(Iconsax.trash_bold, color: Colors.red),
                  label: Text(
                    l10n.remove,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
        if (isAccepted)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final success = await ref
                    .read(offersProvider.notifier)
                    .finishOffer(offer.id!);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: const Icon(Iconsax.tick_circle_bold),
              label: Text(_tr(context, 'Finish offer', 'إنهاء العرض')),
            ),
          ),
      ],
    );
  }

  Widget _buildGrandTotalRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10n.total_project_quote,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Text(
          '\$${offer.price.toStringAsFixed(1)}',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Future<void> _openEditForm(BuildContext context) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => OfferReplyForm(offer: offer)),
    );
    if (updated == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_tr(context, 'Delete offer', 'حذف العرض')),
          content: Text(
            _tr(
              context,
              'This will remove the offer permanently.',
              'سيؤدي هذا إلى حذف العرض نهائيًا.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(_tr(context, 'Cancel', 'إلغاء')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                _tr(context, 'Delete', 'حذف'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;
    final success = await ref
        .read(offersProvider.notifier)
        .deleteOffer(offer.id!);
    if (success && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String rawNumber) async {
    final sanitized = rawNumber
        .replaceAll(RegExp(r'[^0-9+]'), '')
        .replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$sanitized');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) _showMissingContact(context);
    }
  }

  Future<void> _openCall(BuildContext context, String rawNumber) async {
    final uri = Uri.parse('tel:${rawNumber.replaceAll(' ', '')}');
    if (!await launchUrl(uri)) {
      if (context.mounted) _showMissingContact(context);
    }
  }

  void _showMissingContact(BuildContext context) {
    ToastService.error(
      context,
      _tr(context, 'Contact unavailable', 'جهة الاتصال غير متاحة'),
      _tr(
        context,
        'No phone number is available for this action.',
        'لا يوجد رقم هاتف متاح لهذا الإجراء.',
      ),
    );
  }

  String _tr(BuildContext context, String en, String ar) {
    return Localizations.localeOf(context).languageCode.toLowerCase() == 'ar'
        ? ar
        : en;
  }

  String _formatNumber(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}
