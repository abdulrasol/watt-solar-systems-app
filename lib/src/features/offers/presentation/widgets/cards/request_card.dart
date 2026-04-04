import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_request.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class RequestCard extends StatelessWidget {
  final SolarRequest request;
  final VoidCallback onTap;

  const RequestCard({super.key, required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpecItem(
                  icon: Iconsax.sun_1_bold,
                  label: l10n.pv_power,
                  value: '${request.totalPanelPower}W',
                  color: Colors.orange,
                ),
                _buildSpecItem(
                  icon: Iconsax.flash_1_bold,
                  label: l10n.battery,
                  value: '${_formatNumber(request.totalBatteryPower)}Wh',
                  color: Colors.blue,
                ),
                _buildSpecItem(
                  icon: Iconsax.setting_2_bold,
                  label: l10n.inverter_calc,
                  value: '${_formatNumber(request.totalInvertersPower)}W',
                  color: Colors.purple,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Iconsax.location_bold, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  l10n.city_label(request.city?.name ?? '-'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: request.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    request.status.localizedLabel(l10n),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: request.status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatNumber(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}
