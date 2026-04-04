import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/notifications/domain/entities/app_notification.dart';
import 'package:solar_hub/src/features/notifications/presentation/controllers/notification_history_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final state = ref.watch(notificationHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!authState.isSigned) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.notifications)),
        body: const Center(
          child: Text('Login required to view notification history'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: () =>
            ref.read(notificationHistoryProvider.notifier).fetchHistory(),
        child: Builder(
          builder: (_) {
            if (state.isLoading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 160.h),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (state.items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 160.h),
                  Center(
                    child: Text(
                      'No notifications yet',
                      style: TextStyle(fontSize: 15.sp),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: state.items.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _NotificationCard(
                  item: state.items[index],
                  isDark: isDark,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotificationItem item;
  final bool isDark;

  const _NotificationCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasLongBody = item.body.trim().length > 120;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Iconsax.notification_bing_bold,
              color: AppTheme.primaryColor,
              size: 20.sp,
            ),
          ),
          title: Text(
            item.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(
                item.body,
                maxLines: hasLongBody ? 2 : 4,
                overflow: hasLongBody
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                timeago.format(item.sentAt ?? item.createdAt),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
          children: [
            if (hasLongBody)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.body,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: isDark ? Colors.grey[200] : Colors.grey[800],
                  ),
                ),
              ),
            if (item.data.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.grey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  item.data.toString(),
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
