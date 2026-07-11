import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/layout/app_breakpoints.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/navigation/navigation_models.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_activation_notice.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/layout/company_mobile_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/layout/company_sidebar.dart';
import 'package:watt/src/utils/helper_methods.dart';

/// Responsive shell for the company dashboard.
///
/// - Desktop: grouped sidebar.
/// - Tablet: compact sidebar.
/// - Mobile: drawer-based navigation (no bottom nav).
class CompanyShell extends ConsumerStatefulWidget {
  const CompanyShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<CompanyShell> createState() => _CompanyShellState();
}

class _CompanyShellState extends ConsumerState<CompanyShell> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(companySummaryProvider.notifier).getSummary());
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    dPrint(location, tag: 'CompanyShell');

    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final colors = ref.watch(appColorsProvider);
    final sections = CompanyNavigationRegistry.build(l10n, ref);
    final activeSection = _activeSection(sections, location);
    final activeItem = _activeItem(activeSection, location);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < AppBreakpoints.mobile;
        final isTablet = width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
        final bool isActive = authState.company?.requiresActivationAttention == true;

        return Scaffold(
          backgroundColor: colors.background,
          drawer: isMobile ? CompanyMobileDrawer(sections: sections, location: location, authState: authState) : null,
          bottomNavigationBar: isMobile
              ? _CompanyBottomNav(sections: sections, location: location, colors: colors, onTap: (index) => _onTap(context, index, sections))
              : null,
          appBar: isMobile
              ? AppBar(
                  title: Text(
                    activeItem?.label ?? activeSection.label,
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w700, color: colors.textPrimary),
                  ),
                  centerTitle: true,
                  backgroundColor: colors.surface,
                  foregroundColor: colors.textPrimary,
                  elevation: 0,
                  actions: [IconButton(onPressed: () {}, icon: Icon(Iconsax.notification))],
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile) CompanySidebar(sections: sections, location: location, authState: authState, compact: isTablet),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 12 : 24, isMobile ? 12 : 24, isMobile ? 12 : 24, 0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width >= 1440 ? 1320 : 1180),
                        child: isActive
                            ? SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: CompanyActivationNotice(company: authState.company!),
                              )
                            : widget.navigationShell,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTap(BuildContext context, int index, List<CompanyNavigationSection> sections) {
    if (index < 4 && index < sections.length) {
      context.go(sections[index].defaultRoute);
    } else {
      Scaffold.of(context).openDrawer();
    }
  }

  CompanyNavigationSection _activeSection(List<CompanyNavigationSection> sections, String location) {
    for (final section in sections) {
      if (section.isActiveFor(location)) return section;
    }
    return sections.first;
  }

  CompanyNavigationItem? _activeItem(CompanyNavigationSection section, String location) {
    for (final item in section.items) {
      if (location == item.route || location.startsWith('${item.route}/')) {
        return item;
      }
    }
    return null;
  }
}

class _CompanyBottomNav extends StatelessWidget {
  const _CompanyBottomNav({required this.sections, required this.location, required this.colors, required this.onTap});

  final List<CompanyNavigationSection> sections;
  final String location;
  final AppColors colors;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final navSections = sections.take(4).toList();

    int currentIndex = navSections.indexWhere((s) => s.isActiveFor(location));
    if (currentIndex == -1) currentIndex = 4; // 'More'

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: colors.surface,
      indicatorColor: colors.primary.withValues(alpha: 0.15),
      destinations: [
        ...navSections.map((section) {
          final active = section.isActiveFor(location);
          return NavigationDestination(
            icon: Icon(section.icon, color: active ? colors.primary : colors.textSecondary),
            selectedIcon: Icon(section.icon, color: colors.primary),
            label: section.label,
          );
        }),
        NavigationDestination(
          icon: Icon(Iconsax.menu, color: currentIndex == 4 ? colors.primary : colors.textSecondary),
          selectedIcon: Icon(Iconsax.menu, color: colors.primary),
          label: AppLocalizations.of(context)!.more_options,
        ),
      ],
    );
  }
}
