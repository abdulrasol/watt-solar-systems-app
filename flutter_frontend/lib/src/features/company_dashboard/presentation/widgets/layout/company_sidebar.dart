import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/theme/app_colors.dart';
import 'package:watt/src/core/widgets/wd_image_preview.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/navigation/navigation_models.dart';
import 'package:watt/src/utils/app_theme.dart';

/// Desktop sidebar for the company dashboard.
///
/// Displays grouped navigation sections and a user footer.
class CompanySidebar extends ConsumerWidget {
  const CompanySidebar({
    super.key,
    required this.sections,
    required this.location,
    required this.authState,
    this.compact = false,
  });

  final List<CompanyNavigationSection> sections;
  final String location;
  final AuthState authState;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final company = authState.company;

    return Container(
      width: compact ? 88 : 280,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          right: BorderSide(color: colors.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            _SidebarHeader(
              compact: compact,
              companyName: company?.name ?? l10n.company_dashboard,
              colors: colors,
            ),
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
  const _SidebarHeader({required this.compact, required this.companyName, required this.colors});

  final bool compact;
  final String companyName;
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
              child: Icon(Iconsax.building, color: colors.primary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watt',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  companyName,
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

class _ExpandedSection extends StatelessWidget {
  const _ExpandedSection({required this.section, required this.location, required this.colors});

  final CompanyNavigationSection section;
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

  final CompanyNavigationSection section;
  final String location;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final activeItem = section.items.cast<CompanyNavigationItem?>().firstWhere(
          (item) => location == item!.route || location.startsWith('${item.route}/'),
          orElse: () => null,
        );
    final active = activeItem != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Tooltip(
        message: section.label,
        child: InkWell(
          onTap: () => context.go(section.defaultRoute),
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

  final CompanyNavigationItem item;
  final bool active;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          debugPrint('[CompanySidebar] navigating to ${item.route}');
          context.go(item.route);
        },
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
    final displayName = fullName == null || fullName.isEmpty ? user?.username ?? AppLocalizations.of(context)!.guest_user : fullName;

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
                    authState.company?.name ?? AppLocalizations.of(context)!.company_dashboard,
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
            IconButton(
              onPressed: () => context.go('/home'),
              icon: Icon(Iconsax.home_2, size: 18, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
