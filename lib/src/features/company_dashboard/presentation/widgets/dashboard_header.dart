import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/global_search_provider.dart';
import 'package:solar_hub/src/features/notifications/presentation/controllers/notification_history_controller.dart';
import 'package:solar_hub/src/features/notifications/presentation/widgets/notification_center_bottom_sheet.dart';

class DashboardHeader extends ConsumerWidget {
  final String title;

  const DashboardHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Row(
      children: [
        if (!AppBreakpoints.isMobile(context))
          Expanded(
            flex: 2,
            child: Column(
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
                  'Manage your company and inventory',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        if (AppBreakpoints.isMobile(context))
          IconButton(
            icon: const Icon(Iconsax.search_normal_1_bold),
            onPressed: () {},
          )
        else
          Expanded(
            flex: 3,
            child: Container(
              height: 45.h,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                onChanged: (value) =>
                    ref.read(globalSearchProvider.notifier).setQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Iconsax.search_normal_1_bold, size: 18),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                ),
              ),
            ),
          ),
        const Spacer(),
        Row(
          children: [
            if (!AppBreakpoints.isMobile(context)) ...[
              ElevatedButton.icon(
                onPressed: () => _showQuickCreate(context),
                icon: const Icon(Iconsax.add_bold, color: Colors.white),
                label: Text(
                  'Add',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
            ],
            IconButton(
              icon: Badge(
                label: Text(ref.watch(notificationHistoryProvider).totalCount.toString()),
                isLabelVisible: ref.watch(notificationHistoryProvider).totalCount > 0,
                child: const Icon(Iconsax.notification_bing_bold),
              ),
              onPressed: () => _showNotifications(context),
            ),
            SizedBox(width: 12.w),
            IconButton(
              icon: const Icon(Iconsax.setting_2_bold),
              onPressed: () {},
            ),
            SizedBox(width: 16.w),
            _buildUserAvatar(ref),
          ],
        ),
      ],
    );
  }

  Widget _buildUserAvatar(WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: CircleAvatar(
        radius: 18.r,
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        backgroundImage: user?.image != null ? NetworkImage(user!.image!) : null,
        child: user?.image == null
            ? Text(
                user?.username.isNotEmpty == true ? user!.username[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              )
            : null,
      ),
    );
  }

  void _showQuickCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Create',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            SizedBox(height: 24.h),
            _ActionTile(
              icon: Iconsax.box_add_bold,
              title: 'Add Product',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                context.push('/inventory/add');
              },
            ),
            _ActionTile(
              icon: Iconsax.user_add_bold,
              title: 'Invite Member',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                context.push('/companies/dashboard/members');
              },
            ),
            _ActionTile(
              icon: Iconsax.document_bold,
              title: 'Create Offer',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                context.push('/offers');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationCenterBottomSheet(),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: color, size: 22.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
          fontFamily: AppTheme.fontFamily,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}
