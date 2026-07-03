import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/company_workspace_modules.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summary_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_activation_notice.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_navigation.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyShell extends ConsumerStatefulWidget {
  const CompanyShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  ConsumerState<CompanyShell> createState() => _CompanyShellState();
}

class _CompanyShellState extends ConsumerState<CompanyShell> {
  int clickBackCounter = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(companySummaryProvider.notifier).getSummary());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final summaryState = ref.watch(companySummaryProvider);
    final activeModule = CompanyWorkspaceModules.activeForLocation(widget.location, l10n);
    final navItems = CompanyWorkspaceModules.build(l10n, summaryState);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workspaceColor = isDark ? const Color(0xFF10211D) : const Color(0xFFF3F8F5);
    final workspaceAccent = isDark ? AppTheme.primaryColor.withValues(alpha: 0.14) : AppTheme.primaryColor.withValues(alpha: 0.08);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 700;
        final isTablet = width >= 700 && width < 1100;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (clickBackCounter == 0) {
              clickBackCounter++;
              Scaffold.of(context).openDrawer();
            } else {
              context.go('/home');
            }
          },
          child: Scaffold(
            backgroundColor: workspaceColor,
            drawer: isMobile
                ? Drawer(
                    child: CompanyNavigation(activeModule: activeModule, navItems: navItems, compact: false, authState: authState),
                  )
                : null,
            appBar: AppBar(
              title: Text(activeModule.label, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700)),
              centerTitle: isMobile,
            ),
            body: SafeArea(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [workspaceColor, workspaceAccent, workspaceColor]),
                ),
                child: Row(
                  children: [
                    if (!isMobile) CompanyNavigation(activeModule: activeModule, navItems: navItems, compact: isTablet, authState: authState),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(isMobile ? 10.w : 24, 20, isMobile ? 10.w : 24, 20),
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
            ),
          ),
        );
      },
    );
  }
}
