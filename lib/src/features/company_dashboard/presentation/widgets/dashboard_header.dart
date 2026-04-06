import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String title;

  const DashboardHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            Text(
              l10n.company_dashboard_subtitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Iconsax.notification_bing_bold),
              onPressed: () {},
            ),
            SizedBox(width: 12.w),
            IconButton(
              icon: const Icon(Iconsax.setting_2_bold),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
