import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/models/company_workspace_item.dart';
import 'package:solar_hub/src/features/company_dashboard/presentation/widgets/company_nav_tile.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyNavigation extends StatelessWidget {
  const CompanyNavigation({super.key, required this.activeModule, required this.navItems, required this.compact, required this.authState});

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
                        child: const Icon(Iconsax.building, color: AppTheme.primaryColor),
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
                            company?.name ?? l10n.company_dashboard,
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
                  child: CompanyWorkspaceInfoCard(company: company),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
                  children: [
                    for (final item in navItems)
                      CompanyNavTile(item: item, active: item.id == activeModule.id, compact: compact, isMobile: isMobile, isTablet: isTablet),
                    if (compact) ...[
                      const SizedBox(height: 12),
                      CompactAction(icon: Iconsax.home_2, tooltip: l10n.user_mode, onTap: () => context.go('/home')),
                      if (authState.isSuperUser) CompactAction(icon: Iconsax.shield_tick, tooltip: l10n.admin_mode, onTap: () => context.go('/admin')),
                    ],
                  ],
                ),
              ),
              if (!compact)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                  child: CompanyFooter(authState: authState),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyWorkspaceInfoCard extends StatelessWidget {
  const CompanyWorkspaceInfoCard({super.key, required this.company});
  final dynamic company;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.company_dashboard,
            style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            company?.description ?? l10n.monitor_growth_subscriptions,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12, height: 1.4, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class CompanyFooter extends StatelessWidget {
  const CompanyFooter({super.key, required this.authState});
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
                  child: const Icon(Iconsax.user, size: 18, color: AppTheme.primaryColor),
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
          IconButton(onPressed: () => context.go('/home'), icon: const Icon(Iconsax.home_2, size: 18)),
          if (authState.isSuperUser) IconButton(onPressed: () => context.go('/admin'), icon: const Icon(Iconsax.shield_tick, size: 18)),
        ],
      ),
    );
  }
}

class CompactAction extends StatelessWidget {
  const CompactAction({super.key, required this.icon, required this.tooltip, required this.onTap});
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
