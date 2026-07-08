import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/admin/presentation/models/navigation/admin_navigation_registry.dart';
import 'package:watt/src/features/admin/presentation/models/navigation/admin_navigation_item.dart';
import 'package:watt/src/features/admin/presentation/models/navigation/admin_navigation_section.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/utils/app_theme.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final colors = ref.watch(appColorsProvider);
    final sections = AdminNavigationRegistry.build(l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 700;
        final isTablet = width >= 700 && width < 1100;

        return Scaffold(
          backgroundColor: colors.background,
          drawer: isMobile
              ? _AdminDrawer(sections: sections, location: location, authState: authState, colors: colors)
              : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isMobile)
                  _AdminSidebar(
                    sections: sections,
                    location: location,
                    authState: authState,
                    compact: isTablet,
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(isMobile ? 12 : 24, isMobile ? 12 : 24, isMobile ? 12 : 24, 0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width >= 1440 ? 1320 : 1180),
                        child: child,
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

}

class _AdminSidebar extends ConsumerWidget {
  const _AdminSidebar({
    required this.sections,
    required this.location,
    required this.authState,
    this.compact = false,
  });

  final List<AdminNavigationSection> sections;
  final String location;
  final AuthState authState;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appColorsProvider);

    return Container(
      width: compact ? 88 : 280,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            _SidebarHeader(compact: compact, colors: colors),
            if (!compact)
              _ModeSwitcher(authState: authState, colors: colors),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 8),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return compact
                      ? _CompactSection(section: section, location: location, colors: colors)
                      : _ExpandedSection(section: section, location: location, colors: colors);
                },
              ),
            ),
            if (!compact) _SidebarFooter(authState: authState, colors: colors),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.compact, required this.colors});

  final bool compact;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 12 : 20, 20, compact ? 12 : 20, 16),
      child: compact
          ? Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Iconsax.shield, color: colors.primary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SolarHub',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.admin_dashboard,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.authState, required this.colors});

  final AuthState authState;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Switch Mode',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Iconsax.home_2, size: 16),
                  label: const Text('User'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.primary,
                    side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12),
                  ),
                ),
                if (authState.isCompanyMember)
                  FilledButton.icon(
                    onPressed: () => context.go('/companies/dashboard'),
                    icon: const Icon(Iconsax.building, size: 16),
                    label: const Text('Company'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedSection extends StatelessWidget {
  const _ExpandedSection({required this.section, required this.location, required this.colors});

  final AdminNavigationSection section;
  final String location;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final sectionActive = section.isActiveFor(location);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Icon(section.icon, size: 16, color: sectionActive ? colors.primary : colors.textTertiary),
                const SizedBox(width: 8),
                Text(
                  section.label,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: sectionActive ? colors.primary : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          ...section.items.map(
            (item) => _NavItemTile(
              item: item,
              active: location == item.route || location.startsWith('${item.route}/'),
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactSection extends StatelessWidget {
  const _CompactSection({required this.section, required this.location, required this.colors});

  final AdminNavigationSection section;
  final String location;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final active = section.isActiveFor(location);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: section.label,
        child: InkWell(
          onTap: () => context.go(section.items.first.route),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: active ? colors.primary : colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              section.icon,
              size: 22,
              color: active ? Colors.white : colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemTile extends StatelessWidget {
  const _NavItemTile({required this.item, required this.active, required this.colors});

  final AdminNavigationItem item;
  final bool active;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: active ? Colors.white : colors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({required this.authState, required this.colors});

  final AuthState authState;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final user = authState.user;
    final fullName = user?.fullName.trim();
    final displayName = fullName == null || fullName.isEmpty
        ? user?.username ?? AppLocalizations.of(context)!.guest_user
        : fullName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            user?.image == null || user!.image!.isEmpty
                ? CircleAvatar(
                    radius: 18,
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    child: Icon(Iconsax.user, size: 18, color: colors.primary),
                  )
                : WdImagePreview(imageUrl: user.image!, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.admin_dashboard,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  const _AdminDrawer({
    required this.sections,
    required this.location,
    required this.authState,
    required this.colors,
  });

  final List<AdminNavigationSection> sections;
  final String location;
  final AuthState authState;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(authState: authState, colors: colors),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  for (final section in sections) ...[
                    _DrawerSection(
                      section: section,
                      location: location,
                      colors: colors,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Divider(),
                  ListTile(
                    leading: Icon(Iconsax.home_2, color: colors.textSecondary),
                    title: Text(l10n.home, style: TextStyle(fontFamily: AppTheme.fontFamily)),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.go('/home');
                    },
                  ),
                  if (authState.isCompanyMember)
                    ListTile(
                      leading: Icon(Iconsax.building, color: colors.textSecondary),
                      title: Text(
                        authState.company?.name ?? l10n.company_dashboard,
                        style: TextStyle(fontFamily: AppTheme.fontFamily),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go('/companies/dashboard');
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.authState, required this.colors});

  final AuthState authState;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final user = authState.user;
    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : user?.username ?? AppLocalizations.of(context)!.guest_user;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: user?.image?.isNotEmpty == true
                  ? WdImagePreview(imageUrl: user!.image!, size: 48)
                  : Icon(Iconsax.shield, size: 24, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.section, required this.location, required this.colors});

  final AdminNavigationSection section;
  final String location;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final sectionActive = section.isActiveFor(location);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Text(
            section.label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: sectionActive ? colors.primary : colors.textTertiary,
            ),
          ),
        ),
        ...section.items.map(
          (item) {
            final active = location == item.route || location.startsWith('${item.route}/');
            return ListTile(
              dense: true,
              leading: Icon(item.icon, size: 20, color: active ? colors.primary : colors.textSecondary),
              title: Text(
                item.label,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? colors.primary : colors.textPrimary,
                ),
              ),
              selected: active,
              selectedTileColor: colors.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Navigator.of(context).pop();
                context.go(item.route);
              },
            );
          },
        ),
      ],
    );
  }
}
