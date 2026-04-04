import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/admin_company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyCard extends StatelessWidget {
  final AdminCompany company;
  final VoidCallback onTap;

  const CompanyCard({super.key, required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: company.isPending
                ? AppTheme.warningColor.withOpacity(0.3)
                : isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildLogo(context),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          company.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            fontFamily: AppTheme.fontFamily,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(context),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    company.cityName ?? 'Unknown City',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildFeatureTag(context, 'B2B', company.allowsB2b),
                      SizedBox(width: 8.w),
                      _buildFeatureTag(context, 'B2C', company.allowsB2c),
                      const Spacer(),
                      if (company.tier != null)
                        Text(
                          company.tier!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        image: company.logo != null
            ? DecorationImage(image: NetworkImage(company.logo!), fit: BoxFit.cover)
            : null,
      ),
      child: company.logo == null
          ? Icon(Iconsax.building_bold, color: AppTheme.primaryColor, size: 28.sp)
          : null,
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    switch (company.status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'pending':
        color = AppTheme.warningColor;
        break;
      case 'rejected':
        color = AppTheme.errorColor;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        company.status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }

  Widget _buildFeatureTag(BuildContext context, String label, bool enabled) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: enabled ? AppTheme.primaryColor.withOpacity(0.1) : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: enabled ? AppTheme.primaryColor : Colors.grey,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }
}
