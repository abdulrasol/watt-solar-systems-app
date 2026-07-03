import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/home/presentation/providers/home_page_provider.dart';
import 'package:solar_hub/src/shared/presntations/providers/is_enabled_providers.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class UserDashboardHeroCard extends ConsumerWidget {
  const UserDashboardHeroCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final auth = ref.watch(authProvider);
    final name = auth.isSigned ? (auth.user?.firstName ?? l10n.guest_user) : l10n.welcome_guest;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? const [Color(0xFF16201F), Color(0xFF0C1212)] : const [Color(0xFFF4FBF8), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: isDark ? Colors.white10 : AppTheme.primaryColor.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(l10n),
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey[700]),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      name,
                      style: TextStyle(fontSize: isArabic ? 28.sp : 30.sp, height: 1.1, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      l10n.dashboard_hero_subtitle,
                      style: TextStyle(fontSize: 13.sp, height: 1.5, color: isDark ? Colors.white70 : Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              Container(
                width: 62.w,
                height: 62.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primaryColor.withValues(alpha: 0.16), AppTheme.primaryColor.withValues(alpha: 0.06)]),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(Iconsax.sun_1, color: AppTheme.primaryColor, size: 30.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _buildHeroChip(context, Iconsax.flash_1, l10n.dashboard_chip_fast, route: '/calculator/fast-calculator'),
              if (ref.watch(isOffersEnabled))
                _buildHeroChip(context, Iconsax.document_text, l10n.dashboard_chip_offers, route: '/calculator/request-offer-wizard'),
              if (ref.watch(isStoreEnabled)) _buildHeroChip(context, Iconsax.shop, l10n.dashboard_chip_store, onTap: () => selectHomeTab(ref, HomeTab.store)),
            ],
          ),
          if (!auth.isSigned && ref.watch(isAuthEnabled)) ...[
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              onPressed: () => context.go('/auth'),
              icon: Icon(Iconsax.login, size: 18.sp),
              label: Text(l10n.sign_in),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroChip(BuildContext context, IconData icon, String label, {String? route, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (route != null) context.push(route);
        if (onTap != null) onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.sp, color: AppTheme.primaryColor),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return l10n.good_morning;
    if (hour >= 12 && hour < 17) return l10n.good_afternoon;
    if (hour >= 17 && hour < 21) return l10n.good_evening;
    return l10n.good_night;
  }
}
