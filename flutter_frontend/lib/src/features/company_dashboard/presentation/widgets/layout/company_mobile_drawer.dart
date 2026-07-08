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

/// Mobile drawer for the company dashboard.
///
/// Displays grouped navigation sections as an expandable list.
class CompanyMobileDrawer extends ConsumerWidget {
  const CompanyMobileDrawer({
    super.key,
    required this.sections,
    required this.location,
    required this.authState,
  });

  final List<CompanyNavigationSection> sections;
  final String location;
  final AuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = ref.watch(appColorsProvider);
    final company = authState.company;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Iconsax.building, color: colors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
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
                        Text(
                          company?.name ?? l10n.company_dashboard,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: colors.border, height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return _DrawerSection(
                    section: section,
                    location: location,
                    colors: colors,
                  );
                },
              ),
            ),
            Divider(color: colors.border, height: 1),
            _DrawerFooter(authState: authState, colors: colors),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.section, required this.location, required this.colors});

  final CompanyNavigationSection section;
  final String location;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final sectionActive = section.isActiveFor(location);

    return ExpansionTile(
      initiallyExpanded: sectionActive,
      leading: Icon(section.icon, color: sectionActive ? colors.primary : colors.textSecondary),
      title: Text(
        section.label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: sectionActive ? colors.primary : colors.textPrimary,
        ),
      ),
      iconColor: colors.primary,
      collapsedIconColor: colors.textTertiary,
      children: section.items.map((item) {
        final active = location == item.route || location.startsWith('${item.route}/');
        return Material(
          type: MaterialType.transparency,
          child: ListTile(
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
          onTap: () {
            debugPrint('[CompanyMobileDrawer] navigating to ${item.route}');
            final scaffold = Scaffold.of(context);
            GoRouter.of(context).go(item.route);
            scaffold.closeDrawer();
          },
          ),
        );
      }).toList(),
    );
  }
}

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({required this.authState, required this.colors});

  final AuthState authState;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final user = authState.user;
    final fullName = user?.fullName.trim();
    final displayName = fullName == null || fullName.isEmpty ? user?.username ?? AppLocalizations.of(context)!.guest_user : fullName;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          user?.image == null || user!.image!.isEmpty
              ? CircleAvatar(
                  radius: 20,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                  child: Icon(Iconsax.user, size: 20, color: colors.primary),
                )
              : WdImagePreview(imageUrl: user.image!, size: 40),
          const SizedBox(width: 12),
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
                    fontSize: 14,
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
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/home'),
            icon: Icon(Iconsax.home_2, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
