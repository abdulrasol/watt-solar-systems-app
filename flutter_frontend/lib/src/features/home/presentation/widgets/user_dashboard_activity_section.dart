import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/home/presentation/providers/home_page_provider.dart';
import 'package:solar_hub/src/features/home/presentation/providers/user_dashboard_provider.dart';
import 'package:solar_hub/src/shared/presntations/providers/is_enabled_providers.dart';

class UserDashboardActivitySection extends ConsumerWidget {
  const UserDashboardActivitySection({super.key, required this.storeEnabled, required this.notificationsEnabled, required this.authEnabled});
  final bool storeEnabled;
  final bool notificationsEnabled;
  final bool authEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final summaryAsync = ref.watch(userDashboardSummaryProvider);

    if (!authState.isSigned) {
      return Row(
        children: [
          Expanded(
            child: _buildShoppingCard(
              context,
              title: l10n.sign_in,
              subtitle: l10n.dashboard_sign_in_card_subtitle,
              icon: Iconsax.login,
              accent: const Color(0xFF3178F6),
              isDark: isDark,
              enabled: authEnabled,
              onTap: authEnabled ? () => context.push('/auth?redirect_to=/home') : null,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildShoppingCard(
              context,
              title: l10n.services,
              subtitle: l10n.dashboard_guest_services_card_subtitle,
              icon: Iconsax.category_2,
              accent: const Color(0xFF0E7C86),
              isDark: isDark,
              enabled: ref.watch(isservicesEnabled),
              onTap: ref.watch(isservicesEnabled) ? () => selectHomeTab(ref, HomeTab.services) : null,
            ),
          ),
        ],
      );
    }

    final summary = summaryAsync.asData?.value ?? const UserDashboardSummary();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildShoppingCard(
                context,
                title: l10n.my_requests,
                subtitle: l10n.dashboard_my_requests_count(summary.requestCount),
                icon: Iconsax.clipboard,
                accent: const Color(0xFF3178F6),
                isDark: isDark,
                enabled: ref.watch(isOffersEnabled),
                onTap: ref.watch(isOffersEnabled) ? () => context.push('/user-requests') : null,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildShoppingCard(
                context,
                title: l10n.my_orders,
                subtitle: l10n.dashboard_my_orders_count(summary.orderCount),
                icon: Iconsax.shopping_cart,
                accent: const Color(0xFFD94681),
                isDark: isDark,
                enabled: storeEnabled,
                onTap: storeEnabled ? () => context.push('/storefront/b2c/orders') : null,
              ),
            ),
          ],
        ),
        if (notificationsEnabled) ...[
          SizedBox(height: 12.h),
          _buildShoppingCard(
            context,
            title: l10n.notifications,
            subtitle: l10n.dashboard_notifications_count(summary.notificationCount),
            icon: Iconsax.notification_bing,
            accent: const Color(0xFFF59E0B),
            isDark: isDark,
            enabled: true,
            onTap: () => context.push('/notifications'),
          ),
        ],
        if (summaryAsync.isLoading) ...[SizedBox(height: 12.h), const LinearProgressIndicator(minHeight: 3)],
      ],
    );
  }

  Widget _buildShoppingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required bool isDark,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    final child = Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: enabled ? accent.withValues(alpha: 0.18) : (isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.12))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: enabled ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: accent, size: 22.sp),
          ),
          SizedBox(height: 18.h),
          Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12.sp, height: 1.45, color: isDark ? Colors.white70 : Colors.grey[700]),
          ),
          SizedBox(height: 14.h),
          Text(
            enabled ? AppLocalizations.of(context)!.dashboard_open_store : AppLocalizations.of(context)!.dashboard_placeholder_badge,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: accent),
          ),
        ],
      ),
    );
    if (!enabled || onTap == null) return child;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22.r), child: child);
  }
}
