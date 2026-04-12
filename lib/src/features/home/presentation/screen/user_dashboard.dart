import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/fast_calculator.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/system_calculator_wizard.dart';
import 'package:solar_hub/src/features/home/presentation/providers/home_page_provider.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard> {
  late final PageController _posterController;
  int _posterIndex = 0;

  @override
  void initState() {
    super.initState();
    _posterController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _posterController.dispose();
    super.dispose();
  }

  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return l10n.good_morning;
    if (hour >= 12 && hour < 17) return l10n.good_afternoon;
    if (hour >= 17 && hour < 21) return l10n.good_evening;
    return l10n.good_night;
  }

  List<ExplanationItem> _dashboardHints(BuildContext context, AppLocalizations l10n) {
    return [
      ...AppExplanations(context).getGeneralHints(),
      ExplanationItem(title: l10n.dashboard_hint_clean_title, description: l10n.dashboard_hint_clean_desc),
      ExplanationItem(title: l10n.dashboard_hint_expand_title, description: l10n.dashboard_hint_expand_desc),
      ExplanationItem(title: l10n.dashboard_hint_compare_title, description: l10n.dashboard_hint_compare_desc),
    ];
  }

  List<_DashboardAction> _calculatorActions(BuildContext context, AppLocalizations l10n) {
    return [
      _DashboardAction(
        title: l10n.dashboard_fast_calculator,
        subtitle: l10n.dashboard_fast_calculator_desc,
        icon: Iconsax.flash_1_bold,
        accent: const Color(0xFF0BAA9D),
        gradient: const [Color(0xFFE8FCF8), Color(0xFFF7FFFD)],
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FastCalculator()));
        },
      ),
      _DashboardAction(
        title: l10n.dashboard_offer_wizard,
        subtitle: l10n.dashboard_offer_wizard_desc,
        icon: Iconsax.document_text_bold,
        accent: const Color(0xFF3178F6),
        gradient: const [Color(0xFFEAF2FF), Color(0xFFF8FBFF)],
        onTap: () => context.push('/calculator/request-offer-wizard'),
      ),
      _DashboardAction(
        title: l10n.dashboard_system_wizard,
        subtitle: l10n.dashboard_system_wizard_desc,
        icon: Iconsax.calculator_bold,
        accent: const Color(0xFFFF9800),
        gradient: const [Color(0xFFFFF4E8), Color(0xFFFFFCF8)],
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SystemCalculatorWizard()));
        },
      ),
    ];
  }

  List<_PosterPlaceholder> _posterItems(AppLocalizations l10n) {
    return [
      _PosterPlaceholder(
        title: l10n.dashboard_poster_title_1,
        subtitle: l10n.dashboard_poster_desc_1,
        accent: const Color(0xFF0E7C86),
        icon: Iconsax.shop_bold,
      ),
      _PosterPlaceholder(
        title: l10n.dashboard_poster_title_2,
        subtitle: l10n.dashboard_poster_desc_2,
        accent: const Color(0xFF1D8F5A),
        icon: Iconsax.flash_bold,
      ),
      _PosterPlaceholder(
        title: l10n.dashboard_poster_title_3,
        subtitle: l10n.dashboard_poster_desc_3,
        accent: const Color(0xFFF59E0B),
        icon: Iconsax.sun_1_bold,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final authController = ref.watch(authProvider);
    final actions = _calculatorActions(context, l10n);
    final posters = _posterItems(l10n);
    final hints = _dashboardHints(context, l10n);
    final storeEnabled = isEnabled(ref, 'store', defaultValue: false);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(context, l10n, isDark, isArabic, authController),
          SizedBox(height: 26.h),
          _buildSectionHeader(context, title: l10n.quick_actions, subtitle: l10n.dashboard_quick_actions_subtitle),
          SizedBox(height: 14.h),
          ...actions.map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _buildCalculatorCard(context, action, isDark),
            ),
          ),
          SizedBox(height: 12.h),
          _buildSectionHeader(context, title: l10n.dashboard_shopping, subtitle: l10n.dashboard_shopping_subtitle),
          SizedBox(height: 14.h),
          _buildShoppingRow(context, l10n, isDark, storeEnabled),
          SizedBox(height: 28.h),
          _buildSectionHeader(context, title: l10n.dashboard_promotions, subtitle: l10n.dashboard_promotions_subtitle),
          SizedBox(height: 14.h),
          _buildPosterSlider(context, posters, isDark),
          SizedBox(height: 28.h),
          _buildSectionHeader(context, title: l10n.solar_tips, subtitle: l10n.dashboard_tips_subtitle),
          SizedBox(height: 14.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hints.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) => _buildHintCard(context, hints[index], isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AppLocalizations l10n, bool isDark, bool isArabic, AuthState authController) {
    final name = authController.isSigned ? (authController.user?.firstName ?? l10n.guest_user) : l10n.welcome_guest;

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
                child: Icon(Iconsax.sun_1_bold, color: AppTheme.primaryColor, size: 30.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _buildHeroChip(context, Iconsax.flash_1_bold, l10n.dashboard_chip_fast),
              _buildHeroChip(context, Iconsax.document_text_bold, l10n.dashboard_chip_offers),
              _buildHeroChip(context, Iconsax.shop_bold, l10n.dashboard_chip_store),
            ],
          ),
          if (!authController.isSigned && isEnabled(ref, 'auth')) ...[
            SizedBox(height: 18.h),
            ElevatedButton.icon(
              onPressed: () => context.go('/auth'),
              icon: Icon(Iconsax.login_bold, size: 18.sp),
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

  Widget _buildHeroChip(BuildContext context, IconData icon, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required String subtitle}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp, color: theme.brightness == Brightness.dark ? Colors.white60 : Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCalculatorCard(BuildContext context, _DashboardAction action, bool isDark) {
    final theme = Theme.of(context);
    final surfaceGradient = isDark ? [theme.cardColor, Color.alphaBlend(action.accent.withValues(alpha: 0.08), theme.cardColor)] : action.gradient;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Ink(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: surfaceGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: isDark ? Colors.white10 : action.accent.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.05),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(color: action.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18.r)),
              child: Icon(action.icon, color: action.accent, size: 26.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    action.subtitle,
                    style: TextStyle(fontSize: 12.sp, height: 1.45, color: isDark ? Colors.white70 : Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: action.accent),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingRow(BuildContext context, AppLocalizations l10n, bool isDark, bool storeEnabled) {
    return Row(
      children: [
        Expanded(
          child: _buildShoppingCard(
            context,
            title: l10n.dashboard_shop_now,
            subtitle: storeEnabled ? l10n.dashboard_shop_now_desc : l10n.dashboard_store_coming_soon,
            icon: Iconsax.shop_bold,
            accent: const Color(0xFFD94681),
            isDark: isDark,
            enabled: storeEnabled,
            onTap: storeEnabled ? () => ref.read(homePageIndexProvider.notifier).state = 3 : null,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildShoppingCard(
            context,
            title: l10n.dashboard_featured_products,
            subtitle: l10n.dashboard_featured_products_desc,
            icon: Iconsax.box_search_bold,
            accent: const Color(0xFF4B7BEC),
            isDark: isDark,
            enabled: false,
            onTap: null,
          ),
        ),
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

  Widget _buildPosterSlider(BuildContext context, List<_PosterPlaceholder> posters, bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 190.h,
          child: PageView.builder(
            controller: _posterController,
            itemCount: posters.length,
            onPageChanged: (index) => setState(() => _posterIndex = index),
            itemBuilder: (context, index) {
              final poster = posters[index];
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 10.w),
                child: Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        poster.accent,
                        Color.alphaBlend(Colors.white.withValues(alpha: isDark ? 0.04 : 0.18), poster.accent),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: [BoxShadow(color: poster.accent.withValues(alpha: 0.24), blurRadius: 18, offset: const Offset(0, 12))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14.r)),
                            child: Icon(poster.icon, color: Colors.white, size: 22.sp),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999.r)),
                            child: Text(
                              AppLocalizations.of(context)!.dashboard_placeholder_badge,
                              style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        poster.title,
                        style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        poster.subtitle,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.sp, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            posters.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _posterIndex == index ? 20.w : 7.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: _posterIndex == index ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHintCard(BuildContext context, ExplanationItem hint, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14.r)),
            child: Icon(Iconsax.info_circle_bold, color: AppTheme.primaryColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hint.title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 6.h),
                Text(
                  hint.description,
                  style: TextStyle(fontSize: 12.sp, height: 1.55, color: isDark ? Colors.white70 : Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({required this.title, required this.subtitle, required this.icon, required this.accent, required this.gradient, required this.onTap});

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<Color> gradient;
  final VoidCallback onTap;
}

class _PosterPlaceholder {
  const _PosterPlaceholder({required this.title, required this.subtitle, required this.accent, required this.icon});

  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
}
