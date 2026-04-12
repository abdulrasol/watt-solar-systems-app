import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/company_workspace_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/company_workspace_modules.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/summery_provider.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_activation_notice.dart';
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
    Future.microtask(() => ref.read(companySummeryProvider.notifier).getSummery());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final summaryState = ref.watch(companySummeryProvider);
    final company = authState.company;
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
                    child: _CompanyNavigation(activeModule: activeModule, navItems: navItems, compact: false, authState: authState),
                  )
                : null,
            appBar: AppBar(
              title: Text(
                activeModule.label,
                style: const TextStyle(fontFamily: AppTheme.fontFamily, fontWeight: FontWeight.w700),
              ),
              centerTitle: isMobile,
            ),
            body: SafeArea(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [workspaceColor, workspaceAccent, workspaceColor]),
                ),
                child: Row(
                  children: [
                    if (!isMobile) _CompanyNavigation(activeModule: activeModule, navItems: navItems, compact: isTablet, authState: authState),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(isMobile ? 10.w : 24, 20, isMobile ? 10.w : 24, 20),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: width >= 1440 ? 1320 : 1180),
                            child: company?.requiresActivationAttention == true
                                ? Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: CompanyActivationNotice(company: company!),
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

class _CompanyNavigation extends StatelessWidget {
  const _CompanyNavigation({required this.activeModule, required this.navItems, required this.compact, required this.authState});

  final CompanyWorkspaceItem activeModule;
  final List<CompanyWorkspaceItem> navItems;
  final bool compact;
  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 96.0 : 280.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final company = authState.company;
    final l10n = AppLocalizations.of(context)!;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    return Material(
      color: Theme.of(context).cardColor,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06))),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(compact ? 12 : 20, 16, compact ? 12 : 20, 20),
                child: compact
                    ? Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Iconsax.building_bold, color: AppTheme.primaryColor),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.app_name,
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14, color: AppTheme.primaryColor, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            company?.name ?? AppLocalizations.of(context)!.company_dashboard,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activeModule.subtitle,
                            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
              ),
              if (!compact)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _CompanyWorkspaceCard(company: company),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
                  children: [
                    for (final item in navItems)
                      _CompanyNavTile(item: item, active: item.id == activeModule.id, compact: compact, isMobile: isMobile, isTablet: isTablet),
                    if (compact) ...[
                      const SizedBox(height: 12),
                      _CompactAction(icon: Iconsax.home_2_bold, tooltip: 'User Mode', onTap: () => context.go('/home')),
                      if (authState.isSuperUser) _CompactAction(icon: Iconsax.shield_tick_bold, tooltip: 'Admin Mode', onTap: () => context.go('/admin')),
                    ],
                  ],
                ),
              ),
              if (!compact)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: _CompanyFooter(authState: authState),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyWorkspaceCard extends StatelessWidget {
  const _CompanyWorkspaceCard({required this.company});

  final dynamic company;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.company_dashboard,
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            company?.description ?? AppLocalizations.of(context)!.monitor_growth_subscriptions,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, height: 1.4, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _CompanyNavTile extends StatelessWidget {
  const _CompanyNavTile({required this.item, required this.active, required this.compact, required this.isMobile, required this.isTablet});

  final CompanyWorkspaceItem item;
  final bool active;
  final bool compact;
  final bool isMobile;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final hasCustomIcon = item.iconUrl != null && item.iconUrl!.isNotEmpty && item.iconUrl != 'null';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (item.isExternal) {
            context.push(item.externalRoute!);
            return;
          }
          context.go(item.route);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 12 : 14),
          decoration: BoxDecoration(color: active ? AppTheme.primaryColor : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: compact
              ? Tooltip(
                  message: item.label,
                  child: hasCustomIcon
                      ? WdImagePreview(
                          imageUrl: item.iconUrl!,
                          size: isMobile
                              ? 18
                              : isTablet
                              ? 12
                              : 22,
                          shape: BoxShape.circle,
                        )
                      : Icon(
                          item.icon,
                          color: active ? Colors.white : Colors.grey.shade600,
                          size: isMobile
                              ? 18
                              : isTablet
                              ? 12
                              : 22,
                        ),
                )
              : Row(
                  children: [
                    hasCustomIcon
                        ? WdImagePreview(
                            imageUrl: item.iconUrl!,
                            size: isMobile
                                ? 18
                                : isTablet
                                ? 12
                                : 22,
                            shape: BoxShape.circle,
                          )
                        : Icon(
                            item.icon,
                            color: active ? Colors.white : Colors.grey.shade600,
                            size: isMobile
                                ? 18
                                : isTablet
                                ? 12
                                : 22,
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: active ? Colors.white : Colors.grey.shade800,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (item.isExternal) Icon(Iconsax.export_3_bold, size: 16, color: active ? Colors.white.withValues(alpha: 0.85) : Colors.grey.shade500),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CompanyFooter extends StatelessWidget {
  const _CompanyFooter({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    final user = authState.user;
    final fullName = user?.fullName.trim();
    final displayName = fullName == null || fullName.isEmpty ? user?.username ?? AppLocalizations.of(context)!.guest_user : fullName;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          user?.image == null || user!.image!.isEmpty
              ? CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                  child: const Icon(Iconsax.user_bold, size: 18, color: AppTheme.primaryColor),
                )
              : WdImagePreview(imageUrl: user.image!, size: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  authState.company?.name ?? AppLocalizations.of(context)!.company_dashboard,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 11, color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
          IconButton(onPressed: () => context.go('/home'), icon: const Icon(Iconsax.home_2_bold, size: 18)),
          if (authState.isSuperUser) IconButton(onPressed: () => context.go('/admin'), icon: const Icon(Iconsax.shield_tick_bold, size: 18)),
        ],
      ),
    );
  }
}

class _CompactAction extends StatelessWidget {
  const _CompactAction({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
      ),
    );
  }
}
