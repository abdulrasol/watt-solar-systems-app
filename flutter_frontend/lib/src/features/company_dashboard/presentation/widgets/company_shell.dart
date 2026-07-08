import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/layout/app_breakpoints.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/navigation/navigation_models.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/company_activation_notice.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/layout/company_mobile_drawer.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/layout/company_sidebar.dart';

/// Responsive shell for the company dashboard.
///
/// - Desktop: grouped sidebar.
/// - Tablet: compact sidebar.
/// - Mobile: drawer-based navigation (no bottom nav).
class CompanyShell extends ConsumerStatefulWidget {
  const CompanyShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

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
    debugPrint('[CompanyShell] location=${widget.location}');
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final colors = ref.watch(appColorsProvider);
    final sections = CompanyNavigationRegistry.build(l10n, ref);
    final activeSection = _activeSection(sections, widget.location);
    final activeItem = _activeItem(activeSection, widget.location);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < AppBreakpoints.mobile;
        final isTablet = width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;

        return Scaffold(
          backgroundColor: colors.background,
          drawer: isMobile ? CompanyMobileDrawer(sections: sections, location: widget.location, authState: authState) : null,
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
                )
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile) CompanySidebar(sections: sections, location: widget.location, authState: authState, compact: isTablet),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 12 : 24, isMobile ? 12 : 24, isMobile ? 12 : 24, 0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width >= 1440 ? 1320 : 1180),
                        child: authState.company?.requiresActivationAttention == true
                            ? SingleChildScrollView(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: CompanyActivationNotice(company: authState.company!),
                              )
                            : widget.child,
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
