import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/company_service.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyServiceCard extends StatelessWidget {
  final CompanyService service;

  const CompanyServiceCard({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: service.isActive
              ? AppTheme.primaryColor.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIcon(context),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        fontFamily: AppTheme.fontFamily,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      service.serviceCode,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),
          if (service.isActive) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTag(context, Iconsax.calendar_bold, 'Started: ${service.startsAt?.substring(0, 10) ?? 'N/A'}'),
                _buildInfoTag(context, Iconsax.calendar_tick_bold, 'Ends: ${service.endsAt?.substring(0, 10) ?? 'N/A'}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        image: service.icon != null
            ? DecorationImage(image: NetworkImage(service.icon!), fit: BoxFit.contain)
            : null,
      ),
      child: service.icon == null
          ? Icon(Iconsax.setting_2_bold, color: AppTheme.primaryColor, size: 20.sp)
          : null,
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    switch (service.status?.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = AppTheme.warningColor;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        break;
      case 'suspended':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        (service.status ?? 'N/A').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8.sp,
          fontWeight: FontWeight.bold,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }

  Widget _buildInfoTag(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 12.sp, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
        ),
      ],
    );
  }
}
