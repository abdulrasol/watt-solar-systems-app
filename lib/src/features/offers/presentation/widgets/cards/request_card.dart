import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_request.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/date_utils.dart';

class RequestCard extends StatelessWidget {
  final SolarRequest request;
  final VoidCallback onTap;
  final VoidCallback? onConvertToLead;

  const RequestCard({super.key, required this.request, required this.onTap, this.onConvertToLead});

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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: request.user?.image != null ? NetworkImage(request.user!.image!) : null,
                  child: request.user?.image == null ? Icon(Iconsax.user, size: 18.sp, color: AppTheme.primaryColor) : null,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.user?.name ?? l10n.unknown_user,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        request.createdAt != null ? AppDateUtils.timeAgo(request.createdAt!, l10n) : '',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(color: request.status.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text(
                    request.status.localizedLabel(l10n),
                    style: TextStyle(fontSize: 10.sp, color: request.status.color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: const Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSpecItem(icon: Iconsax.sun_1, label: l10n.pv_power, value: l10n.unit_watts(request.totalPanelPower), color: Colors.orange),
                _buildSpecItem(
                  icon: Iconsax.battery_charging,
                  label: l10n.battery,
                  value: l10n.unit_kilowatthours(_formatNumber(request.totalBatteryPower)),
                  color: Colors.green,
                ),
                _buildSpecItem(
                  icon: Iconsax.flash_1,
                  label: l10n.inverter_calc,
                  value: l10n.unit_kilowatts(_formatNumber(request.totalInvertersPower)),
                  color: Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Iconsax.location, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  l10n.city_label(request.city?.name ?? '-'),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (onConvertToLead != null)
                  TextButton.icon(
                    onPressed: onConvertToLead,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size(0, 32.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                      ),
                    ),
                    icon: Icon(Iconsax.user_add, size: 14.sp),
                    label: Text(
                      l10n.convert_to_lead,
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                else if (request.offersCount != null && request.offersCount! > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8.r)),
                    child: Row(
                      children: [
                        Icon(Iconsax.document_text, size: 12.sp, color: Colors.blue),
                        SizedBox(width: 4.w),
                        Text(
                          l10n.bids_count(request.offersCount!),
                          style: TextStyle(fontSize: 10.sp, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem({required IconData icon, required String label, required String value, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20.sp),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, fontFamily: AppTheme.fontFamily),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatNumber(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}
