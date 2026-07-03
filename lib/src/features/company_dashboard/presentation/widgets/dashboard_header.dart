import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/src/core/layout/app_breakpoints.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/global_search_provider.dart';
import 'package:solar_hub/src/features/notifications/presentation/controllers/notification_history_controller.dart';
import 'package:solar_hub/src/features/notifications/presentation/widgets/notification_center_bottom_sheet.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/quick_create_actions.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';

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
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, fontFamily: AppTheme.fontFamily),
                ),
                Text(
                  AppLocalizations.of(context)!.monitor_growth_subscriptions,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: AppTheme.fontFamily),
                ),
              ],
            ),
          ),
        if (AppBreakpoints.isMobile(context))
          IconButton(icon: const Icon(Iconsax.search_normal_1), onPressed: () {})
        else
          Expanded(
            flex: 3,
            child: Container(
              height: 45.h,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12.r)),
              child: TextField(
                onChanged: (value) => ref.read(globalSearchProvider.notifier).setQuery(value),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  prefixIcon: const Icon(Iconsax.search_normal_1, size: 18),
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
                onPressed: () {
                  final summaryState = ref.read(companySummaryProvider);
                  final l10n = AppLocalizations.of(context)!;
                  showQuickCreateSheet(context, summaryState, l10n);
                },
                icon: const Icon(Iconsax.add, color: Colors.white),
                label: Text('Add', style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Builder(
              builder: (context) {
                final notificationState = ref.watch(notificationHistoryProvider);
                final unreadCount = notificationState.items.where((item) => item.status != 'read').length;
                return IconButton(
                  icon: Badge(label: Text(unreadCount.toString()), isLabelVisible: unreadCount > 0, child: const Icon(Iconsax.notification_bing)),
                  onPressed: () => _showNotifications(context),
                );
              },
            ),
            SizedBox(width: 12.w),
            IconButton(icon: const Icon(Iconsax.setting_2), onPressed: () => context.push('/settings')),
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
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
              )
            : null,
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
