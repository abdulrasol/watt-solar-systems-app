import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_offer.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class OfferCard extends StatelessWidget {
  final SolarOffer offer;
  final VoidCallback onTap;

  const OfferCard({super.key, required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: onSurface.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: offer.company.logo != null
                      ? WdImagePreview(imageUrl: offer.company.logo!)
                      : const Icon(
                          Iconsax.building_bold,
                          color: AppTheme.primaryColor,
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.company.name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          fontFamily: AppTheme.fontFamily,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        offer.createdAt != null
                            ? '${offer.createdAt!.day}/${offer.createdAt!.month}/${offer.createdAt!.year}'
                            : '',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: onSurface.withValues(alpha: 0.58),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: offer.status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        offer.status.localizedLabel(l10n),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: offer.status.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '\$${offer.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniSpec(
                    Iconsax.sun_1_bold,
                    '${offer.totalPanelPower}W',
                  ),
                  _buildMiniSpec(
                    Iconsax.flash_1_bold,
                    '${_formatNumber(offer.totalBatteryPower)}KWh',
                  ),
                  _buildMiniSpec(
                    Iconsax.setting_2_bold,
                    '${_formatNumber(offer.inverterSize)}W',
                  ),
                ],
              ),
            ),
            if (offer.involves != null && offer.involves!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Divider(
                  height: 1,
                  color: onSurface.withValues(alpha: 0.08),
                ),
              ),
              ...offer.involves!.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ),
                      Text(
                        'x${item.quantity ?? 1}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Text(
                        '\$${item.totalCost ?? (item.cost * (item.quantity ?? 1))}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMiniSpec(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 12.sp, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _formatNumber(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}
