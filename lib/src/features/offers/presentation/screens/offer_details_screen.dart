import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_offer.dart';
import 'package:solar_hub/src/features/offers/presentation/providers/offers_provider.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class OfferDetailsScreen extends ConsumerWidget {
  final SolarOffer offer;

  const OfferDetailsScreen({super.key, required this.offer});

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
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Text(
                offer.note!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
          SizedBox(height: 32.h),
          const Divider(),
          SizedBox(height: 16.h),
          _buildActualActionArea(context, ref),
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
          l10n.panels,
          '${offer.panelCount} x ${offer.panelPower}W',
          note: offer.panelNote,
          icon: Iconsax.sun_1_bold,
        ),
        SizedBox(height: 12.h),
        _buildSpecRow(
          l10n.battery_storage,
          '${offer.batteryCount} x ${_formatNumber(offer.batterySize)}Wh (${offer.batteryType.localizedLabel(l10n)})',
          note: offer.batteryNote,
          icon: Iconsax.flash_1_bold,
        ),
        SizedBox(height: 12.h),
        _buildSpecRow(
          l10n.inverter_calc,
          '${_formatNumber(offer.inverterSize)}W (${offer.inverterType.localizedLabel(l10n)})',
          note: offer.inverterNote,
          icon: Iconsax.setting_2_bold,
        ),
      ],
    );
  }

  Widget _buildSpecRow(
    String label,
    String value, {
    String? note,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
                    color: Colors.grey[600],
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
                      color: Colors.blueGrey[600],
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

  Widget _buildActualActionArea(BuildContext context, WidgetRef ref) {
    final totalInvolvesPrice =
        offer.involves?.fold(
          0.0,
          (sum, item) =>
              sum + (item.totalCost ?? (item.cost * (item.quantity ?? 1))),
        ) ??
        0.0;
    final grandTotal = offer.price + totalInvolvesPrice;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.total_project_quote,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '\$${grandTotal.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {}, // TODO: Chat
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: const Icon(Iconsax.message_2_bold),
                label: Text(AppLocalizations.of(context)!.chat),
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
                child: Text(AppLocalizations.of(context)!.accept_offer),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () async {
              await ref
                  .read(offersProvider.notifier)
                  .respondToOffer(offer.id!, 'rejected');
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.reject_offer,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}
