import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/providers/calculator_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/fast_calculator.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/system_calculator_wizard.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/battery_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/inverter_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/panel_calculator_page.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/pump_calculator.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/tools/wires_calculator_page.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class CalculatorLandingPage extends ConsumerWidget {
  const CalculatorLandingPage({super.key, this.showAppBar = false});

  final bool showAppBar;

  bool _isArabic(BuildContext context) => Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr(BuildContext context, String en, String ar) {
    return _isArabic(context) ? ar : en;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isArabic = _isArabic(context);
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(l10n.calculator_tools)) : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 26.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n, theme),
            SizedBox(height: 18.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPrimaryCard(
                    context,
                    title: _tr(context, 'Fast PV', 'حاسبة سريعة'),
                    description: _tr(
                      context,
                      'Quick home PV sizing for current, panels, inverter, and batteries.',
                      'تقدير سريع لمنظومة منزلية يشمل التيار والألواح والعاكس والبطاريات.',
                    ),
                    icon: Iconsax.flash_1_bold,
                    accent: const Color(0xFF0BAA9D),
                    gradient: const [Color(0xFFE8FCF8), Color(0xFFFCFFFF)],
                    cta: _tr(context, 'Open calculator', 'فتح الحاسبة'),
                    isMobile: isMobile,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FastCalculator()));
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildPrimaryCard(
                    context,
                    title: l10n.system_wizard,
                    description: l10n.system_wizard_desc,
                    icon: Iconsax.calculator_bold,
                    accent: const Color(0xFFFF9800),
                    gradient: const [Color(0xFFFFF4E8), Color(0xFFFFFCF8)],
                    cta: _tr(context, 'Open wizard', 'فتح المعالج'),
                    isMobile: isMobile,
                    onTap: () {
                      ref.read(calculatorProvider).currentSystemId = null;
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SystemCalculatorWizard()));
                    },
                  ),
                ),
                if (!isMobile) const Spacer(),
              ],
            ),
            if (isEnabled(ref, 'offers')) ...[
              SizedBox(height: 14.h),
              _buildOfferCard(
                context,
                title: l10n.request_offer_wizard,
                description: l10n.request_offer_desc,
                icon: Iconsax.document_text_bold,
                accent: const Color(0xFF4B9EFF),
                onTap: () => context.push('/calculator/request-offer-wizard'),
              ),
            ],
            SizedBox(height: 22.h),
            Row(
              children: [
                Text(
                  l10n.quick_tools,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 21.sp),
                ),
                const Spacer(),
                Text(
                  _tr(context, 'Choose a tool', 'اختر أداة'),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: isArabic ? 0.72 : 0.78,
              children: [
                _buildToolCard(
                  context,
                  l10n.panels_calc,
                  Iconsax.sun_1_bold,
                  Colors.amber,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PanelCalculatorPage())),
                  'panel_hero',
                ),
                _buildToolCard(
                  context,
                  l10n.inverter_calc,
                  Iconsax.flash_bold,
                  Colors.red,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InverterCalculatorPage())),
                  'inverter_hero',
                ),
                _buildToolCard(
                  context,
                  l10n.battery_calc,
                  Iconsax.battery_charging_bold,
                  Colors.green,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BatteryCalculatorPage())),
                  'battery_hero',
                ),
                _buildToolCard(
                  context,
                  l10n.wires_calc,
                  Icons.cable,
                  Colors.grey,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WiresCalculatorPage())),
                  'wires_hero',
                ),
                _buildToolCard(
                  context,
                  l10n.pump_calc,
                  Icons.water_drop,
                  Colors.blueAccent,
                  () => Navigator.push(context, MaterialPageRoute(builder: (context) => PumpCalculator())),
                  'pump_hero',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark ? const [Color(0xFF171E1D), Color(0xFF101615)] : [theme.cardColor, theme.cardColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppTheme.primaryColor.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18.r)),
            child: const Icon(Iconsax.category_bold, color: AppTheme.primaryColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.calculator_tools,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 22.sp, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 6.h),
                Text(
                  _tr(
                    context,
                    'Choose a quick estimate, a full wizard, or one focused calculation tool.',
                    'اختر تقديرًا سريعًا أو معالجًا كاملًا أو أداة متخصصة لحساب محدد.',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13.sp, height: 1.45, color: isDark ? Colors.white70 : Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color accent,
    required List<Color> gradient,
    required String cta,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceGradient = isDark ? [theme.cardColor, Color.alphaBlend(accent.withValues(alpha: 0.08), theme.cardColor)] : gradient;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isMobile ? 248.h : null,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: surfaceGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: accent.withValues(alpha: isDark ? 0.32 : 0.24), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: isMobile ? null : EdgeInsets.all(38),
              width: !isMobile ? null : 56.w,
              height: !isMobile ? null : 56.w,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18.r)),
              child: Icon(icon, color: accent, size: 30),
            ),
            SizedBox(height: 14.h),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: !isMobile ? null : 20.sp, fontWeight: FontWeight.w900, height: 1.12, color: isDark ? Colors.white : Colors.black87),
            ),
            SizedBox(height: 8.h),
            Text(
              description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: !isMobile ? null : 12.5.sp,
                color: isDark ? Colors.white70 : Colors.grey[700],
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              cta,
              style: TextStyle(fontSize: !isMobile ? null : 12.sp, fontWeight: FontWeight.w800, color: accent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Color.alphaBlend(accent.withValues(alpha: 0.06), theme.cardColor), theme.cardColor]
                : const [Color(0xFFF6F3FF), Color(0xFFFFFCFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: accent.withValues(alpha: isDark ? 0.3 : 0.22), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(18.r)),
              child: Icon(icon, color: accent, size: 30.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, height: 1.15),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 13.sp, height: 1.45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, [String? heroTag]) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconBox = Container(
      width: 46.w,
      height: 46.w,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18.r)),
      child: Icon(icon, color: color, size: 24.sp),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? [theme.cardColor, Color.alphaBlend(color.withValues(alpha: 0.05), theme.cardColor)] : const [Color(0xFFFCF7FB), Color(0xFFFFFEFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
              blurRadius: 10.r,
              offset: Offset(0, 6.r),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (heroTag != null) Hero(tag: heroTag, child: iconBox) else iconBox,
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp, height: 1.24, color: isDark ? Colors.white : null),
            ),
          ],
        ),
      ),
    );
  }
}
