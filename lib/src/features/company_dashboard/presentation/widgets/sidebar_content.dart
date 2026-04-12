import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/nav_item_tile.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SidebarContent extends StatelessWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarContent({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(height: 50.h),
        // Branding
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.sun_1_bold,
                  color: AppTheme.primaryColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Solar Hub',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDarkColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        // Nav Items
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: navItems.length,
            itemBuilder: (context, index) {
              return NavItemTile(
                item: navItems[index],
                isSelected: selectedIndex == index,
                onTap: () => onItemSelected(index),
              );
            },
          ),
        ),
        // User Profile (Bottom)
        Padding(
          padding: EdgeInsets.all(20.r),
          child: InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.go('/home');
            },
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.2,
                    ),
                    child: Icon(
                      Iconsax.user_bold,
                      size: 18.sp,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.admin_user,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          l10n.super_admin,
                          style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Iconsax.logout_1_bold,
                    size: 18.sp,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
