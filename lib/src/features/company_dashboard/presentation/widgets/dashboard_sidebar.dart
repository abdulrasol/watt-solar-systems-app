import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';

// Assuming these path imports are necessary for role checking and subscription status
// We might need to adjust them based on where these providers actually live in the clean architecture
import 'package:solar_hub/src/features/company_dashboard/presentation/providers/company_dashboard_provider.dart';

class DashboardSidebar extends ConsumerWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, these values would come from properly defined providers for user role and subscription
    final bool hasOwnerRole = true;
    final bool hasManagerRole = true;
    final bool hasSalesRole = true;
    final bool hasAccountantRole = true;
    final bool hasInventoryRole = true;
    final bool hasInstallerRole = true;
    final bool hasDriverRole = true;

    final bool isSubActive = true;

    final currentIndex = ref.watch(companyDashboardIndexProvider);
    final l10n = AppLocalizations.of(context)!;

    // Helper to check roles
    bool hasAnyRole(List<bool> roles) => roles.any((element) => element);

    return Container(
      width: 280,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.solar_power, color: Theme.of(context).colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Text(l10n.solar_hub, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(context, ref, l10n.dashboard, Iconsax.category_bold, 0, 'dashboard', isSelected: currentIndex == 0),

                _buildSectionHeader(l10n.manage_business),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasSalesRole, hasAccountantRole]))
                  _buildNavItem(context, ref, l10n.orders, Iconsax.box_bold, 6, 'orders', isSelected: currentIndex == 6, isLocked: !isSubActive),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasSalesRole]))
                  _buildNavItem(context, ref, l10n.pos, FontAwesomeIcons.cashRegister, 5, 'pos', isSelected: currentIndex == 5, isLocked: !isSubActive),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasAccountantRole]))
                  _buildNavItem(
                    context,
                    ref,
                    l10n.invoices,
                    FontAwesomeIcons.fileInvoiceDollar,
                    7,
                    'invoices',
                    isSelected: currentIndex == 7,
                    isLocked: !isSubActive,
                  ),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasAccountantRole]))
                  _buildNavItem(context, ref, l10n.accounting, FontAwesomeIcons.calculator, 8, 'accounting', isSelected: currentIndex == 8),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasInventoryRole, hasInstallerRole]))
                  _buildNavItem(context, ref, l10n.inventory, FontAwesomeIcons.boxesStacked, 4, 'inventory', isSelected: currentIndex == 4),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasSalesRole]))
                  _buildNavItem(context, ref, l10n.offers, FontAwesomeIcons.bullhorn, 3, 'offers', isSelected: currentIndex == 3, isLocked: !isSubActive),

                _buildSectionHeader(l10n.people),

                _buildNavItem(context, ref, l10n.members, Iconsax.people_bold, 10, 'members', isSelected: currentIndex == 10),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasSalesRole, hasAccountantRole]))
                  _buildNavItem(context, ref, l10n.customers, Iconsax.user_tag_bold, 12, 'customers', isSelected: currentIndex == 12, isLocked: !isSubActive),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasSalesRole, hasInstallerRole]))
                  _buildNavItem(context, ref, l10n.suppliers, Iconsax.shop_bold, 13, 'suppliers', isSelected: currentIndex == 13, isLocked: !isSubActive),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasInventoryRole, hasSalesRole, hasInstallerRole]))
                  _buildNavItem(
                    context,
                    ref,
                    l10n.my_purchases,
                    FontAwesomeIcons.bagShopping,
                    14,
                    'my_purchases',
                    isSelected: currentIndex == 14,
                    isLocked: !isSubActive,
                  ),

                _buildSectionHeader(l10n.tools),

                if (hasAnyRole([hasOwnerRole, hasManagerRole]))
                  _buildNavItem(context, ref, l10n.analytics, Iconsax.chart_2_bold, 9, 'analytics', isSelected: currentIndex == 9, isLocked: !isSubActive),

                _buildNavItem(context, ref, l10n.systems, Iconsax.sun_1_bold, 11, 'systems', isSelected: currentIndex == 11, isLocked: !isSubActive),

                if (hasAnyRole([hasOwnerRole, hasManagerRole, hasInventoryRole, hasDriverRole]))
                  _buildNavItem(
                    context,
                    ref,
                    l10n.delivery,
                    Icons.local_shipping_outlined,
                    15,
                    'delivery',
                    isSelected: currentIndex == 15,
                    isLocked: !isSubActive,
                  ),

                _buildSectionHeader(l10n.settings),
                _buildNavItem(context, ref, l10n.company_profile, Iconsax.building_bold, 1, 'profile', isSelected: currentIndex == 1),

                if (hasAnyRole([hasOwnerRole, hasManagerRole]))
                  _buildNavItem(context, ref, l10n.subscription, FontAwesomeIcons.star, 2, 'subscription', isSelected: currentIndex == 2),

                const Divider(height: 32),

                _buildActionButton(context, ref, l10n.switch_to_user_view, Iconsax.user_square_bold, () => context.go('/home')),

                _buildActionButton(context, ref, l10n.settings, Iconsax.setting_2_bold, () => context.push('/settings')),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    int targetIndex,
    String targetRouteName, {
    bool isSelected = false,
    bool isLocked = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isLocked ? Colors.grey : (isSelected ? colorScheme.primary : theme.iconTheme.color?.withValues(alpha: 0.7));

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: isSelected ? colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent),
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? colorScheme.primary : (isLocked ? Colors.grey : theme.textTheme.bodyMedium?.color),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: isLocked ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey) : null,
        onTap: () {
          ref
              .read(companyDashboardControllerProvider.notifier)
              .changePage(targetIndex, targetRouteName, isSubscriptionActive: true /* replace with real sub status */);
          if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, String title, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: theme.iconTheme.color?.withValues(alpha: 0.7), size: 22),
        title: Text(
          title,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w500, fontSize: 14),
        ),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
