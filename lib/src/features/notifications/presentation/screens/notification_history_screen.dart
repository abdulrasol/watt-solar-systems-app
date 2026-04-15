import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/notifications/domain/entities/app_notification.dart';
import 'package:solar_hub/src/features/notifications/domain/entities/notification_type.dart';
import 'package:solar_hub/src/features/notifications/presentation/controllers/notification_history_controller.dart';
import 'package:solar_hub/src/features/notifications/presentation/widgets/notification_content_widget.dart';
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
        body: const Center(child: Text('Login required to view notification history')),
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
        onRefresh: () => ref.read(notificationHistoryProvider.notifier).fetchHistory(),
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
                        style: TextStyle(color: AppTheme.errorColor, fontSize: 14.sp),
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
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 56.sp, color: Colors.grey.withValues(alpha: 0.3)),
                        SizedBox(height: 12.h),
                        Text(
                          l10n.no_notifications_yet,
                          style: TextStyle(fontSize: 15.sp, color: Colors.grey),
                        ),
                      ],
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
                return _NotificationCard(item: state.items[index], isDark: isDark);
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final AppNotificationItem item;
  final bool isDark;

  const _NotificationCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Resolve type from data.type (the inner type field inside 'data')
    final dataMap = item.data;
    final innerType = dataMap['type']?.toString();
    final notifType = NotificationType.fromString(innerType);
    final content = (dataMap['content'] as Map<String, dynamic>?) ?? {};
    final accentColor = notifType.color;
    final hasLongBody = item.body.trim().length > 100;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.grey.withValues(alpha: 0.13)),
        boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          // ── Avatar ───────────────────────────────────────────────────────
          leading: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(notifType.icon, color: accentColor, size: 20.sp),
          ),
          // ── Title + body preview + timestamp ─────────────────────────────
          title: Text(
            item.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),
              Text(
                item.body,
                maxLines: hasLongBody ? 2 : 4,
                overflow: hasLongBody ? TextOverflow.ellipsis : TextOverflow.visible,
                style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20.r)),
                    child: Text(
                      notifType.localizedName(l10n),
                      style: TextStyle(fontSize: 9.sp, color: accentColor, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                    ),
                  ),
                  Text(
                    timeago.format(
                      item.sentAt ?? item.createdAt,
                      locale: Localizations.localeOf(context).languageCode,
                    ),
                    style: TextStyle(fontSize: 10.sp, color: isDark ? Colors.grey[500] : Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          // ── Expanded section ──────────────────────────────────────────────
          children: [
            // Full body if truncated
            if (hasLongBody)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Text(
                    item.body,
                    style: TextStyle(fontSize: 13.sp, height: 1.45, color: isDark ? Colors.grey[200] : Colors.grey[800]),
                  ),
                ),
              ),

            // Structured content card
            if (content.isNotEmpty || notifType != NotificationType.unknown) NotificationContentWidget(type: notifType, content: content, isDark: isDark),

            SizedBox(height: 12.h),

            // Action button
            _ActionButton(notifType: notifType, content: content, accentColor: accentColor),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final NotificationType notifType;
  final Map<String, dynamic> content;
  final Color accentColor;

  const _ActionButton({required this.notifType, required this.content, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final route = notifType.navigationRoute(content);
    if (route == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => context.push(route),
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          backgroundColor: accentColor.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          padding: EdgeInsets.symmetric(vertical: 10.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(notifType.icon, size: 14),
            SizedBox(width: 8.w),
            Text(
              notifType.actionLabel(AppLocalizations.of(context)!),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
