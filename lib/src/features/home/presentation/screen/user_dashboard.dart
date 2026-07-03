import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/system_calculator_wizard.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/home/presentation/providers/home_page_provider.dart';
import 'package:solar_hub/src/features/home/presentation/providers/user_dashboard_provider.dart';
import 'package:solar_hub/src/features/home/presentation/widgets/user_dashboard_action_card.dart';
import 'package:solar_hub/src/features/home/presentation/widgets/user_dashboard_activity_section.dart';
import 'package:solar_hub/src/features/home/presentation/widgets/user_dashboard_hero_card.dart';
import 'package:solar_hub/src/features/home/presentation/widgets/user_dashboard_hint_card.dart';
import 'package:solar_hub/src/features/home/presentation/widgets/solar_production_card.dart';
import 'package:solar_hub/src/shared/presntations/providers/is_enabled_providers.dart';
import 'package:solar_hub/src/utils/app_explanations.dart';

class UserDashboard extends ConsumerStatefulWidget {
  const UserDashboard({super.key});

  @override
  ConsumerState<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends ConsumerState<UserDashboard> {
  Future<void> _refresh() async {
    ref.invalidate(userDashboardSummaryProvider);
    await ref.read(userDashboardSummaryProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final storeEnabled = ref.watch(isStoreEnabled);
    final notificationsEnabled = ref.watch(isNotificationsEnabled);
    final authEnabled = ref.watch(isAuthEnabled);
    final authController = ref.watch(authProvider);
    final hints = _dashboardHints(context, l10n);
    final actions = _calculatorActions(context, l10n);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserDashboardHeroCard(),
            SizedBox(height: 26.h),
            UserDashboardSectionHeader(title: l10n.quick_actions, subtitle: l10n.dashboard_quick_actions_subtitle),
            SizedBox(height: 14.h),
            for (final action in actions) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: action,
              ),
            ],
            SizedBox(height: 12.h),
            UserDashboardSectionHeader(
              title: authController.isSigned ? l10n.dashboard_your_activity : l10n.dashboard_get_started,
              subtitle: authController.isSigned ? l10n.dashboard_activity_signed_in_subtitle : l10n.dashboard_activity_guest_subtitle,
            ),
            SizedBox(height: 14.h),
            UserDashboardActivitySection(storeEnabled: storeEnabled, notificationsEnabled: notificationsEnabled, authEnabled: authEnabled),
            SizedBox(height: 28.h),
            const SolarProductionCard(),
            SizedBox(height: 28.h),
            UserDashboardSectionHeader(title: l10n.solar_tips, subtitle: l10n.dashboard_tips_subtitle),
            SizedBox(height: 14.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hints.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => UserDashboardHintCard(hint: hints[index]),
            ),
          ],
        ),
      ),
    );
  }

  List<ExplanationItem> _dashboardHints(BuildContext context, AppLocalizations l10n) {
    return [
      ...AppExplanations(context).getGeneralHints(),
      ExplanationItem(title: l10n.dashboard_hint_clean_title, description: l10n.dashboard_hint_clean_desc),
      ExplanationItem(title: l10n.dashboard_hint_expand_title, description: l10n.dashboard_hint_expand_desc),
      ExplanationItem(title: l10n.dashboard_hint_compare_title, description: l10n.dashboard_hint_compare_desc),
    ];
  }

  List<Widget> _calculatorActions(BuildContext context, AppLocalizations l10n) {
    final actions = <Widget>[
      UserDashboardActionCard(
        title: l10n.dashboard_fast_calculator,
        subtitle: l10n.dashboard_fast_calculator_desc,
        icon: Iconsax.flash_1,
        accent: const Color(0xFF0BAA9D),
        gradient: const [Color(0xFFE8FCF8), Color(0xFFF7FFFD)],
        onTap: () => context.push('/calculator/fast-calculator'),
      ),
      UserDashboardActionCard(
        title: l10n.dashboard_system_wizard,
        subtitle: l10n.dashboard_system_wizard_desc,
        icon: Iconsax.calculator,
        accent: const Color(0xFFFF9800),
        gradient: const [Color(0xFFFFF4E8), Color(0xFFFFFCF8)],
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SystemCalculatorWizard()));
        },
      ),
      if (ref.watch(isOffersEnabled))
        UserDashboardActionCard(
          title: l10n.dashboard_offer_wizard,
          subtitle: l10n.dashboard_offer_wizard_desc,
          icon: Iconsax.document_text,
          accent: const Color(0xFF3178F6),
          gradient: const [Color(0xFFEAF2FF), Color(0xFFF8FBFF)],
          onTap: () => context.push('/calculator/request-offer-wizard'),
        ),
      if (ref.watch(isservicesEnabled))
        UserDashboardActionCard(
          title: l10n.services,
          subtitle: l10n.dashboard_services_action_subtitle,
          icon: Iconsax.category_2,
          accent: const Color(0xFF2563EB),
          gradient: const [Color(0xFFE8F0FF), Color(0xFFF8FBFF)],
          onTap: () => selectHomeTab(ref, HomeTab.services),
        ),
      if (ref.watch(isStoreEnabled))
        UserDashboardActionCard(
          title: l10n.store,
          subtitle: l10n.dashboard_store_action_subtitle,
          icon: Iconsax.shop,
          accent: const Color(0xFFD94681),
          gradient: const [Color(0xFFFFEEF5), Color(0xFFFFFAFC)],
          onTap: () => selectHomeTab(ref, HomeTab.store),
        ),
    ];
    return actions;
  }
}
