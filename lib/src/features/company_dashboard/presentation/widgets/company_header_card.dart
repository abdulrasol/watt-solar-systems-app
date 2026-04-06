import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyHeaderCard extends StatelessWidget {
  final Company company;

  const CompanyHeaderCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = AppBreakpoints.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            Theme.of(context).cardColor,
            AppTheme.primaryColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          WdImagePreview(
            imageUrl: company.logo ?? '',
            size: 80,
            shape: BoxShape.circle,
          ),
          SizedBox(width: isMobile ? 0 : 20.w, height: isMobile ? 16.h : 0),
          if (isMobile)
            _buildDetails(
              context,
              l10n,
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          else
            Expanded(
              child: _buildDetails(
                context,
                l10n,
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetails(
    BuildContext context,
    AppLocalizations l10n, {
    required CrossAxisAlignment crossAxisAlignment,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                company.name,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: AppTheme.fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            if (company.status.toLowerCase() == 'active')
              Icon(Iconsax.verify_bold, color: Colors.blue, size: 20.sp),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          company.description ?? l10n.solar_solutions_provider,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey,
            fontFamily: AppTheme.fontFamily,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildChip(
              context,
              label: company.tier ?? l10n.standard,
              icon: Iconsax.crown_bold,
              color: Colors.orange,
            ),
            _buildChip(
              context,
              label: company.type ?? l10n.company,
              icon: Iconsax.building_bold,
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
