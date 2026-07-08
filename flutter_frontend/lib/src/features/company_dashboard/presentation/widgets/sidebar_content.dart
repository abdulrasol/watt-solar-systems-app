import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/features/company_dashboard/presentation/models/nav_item.dart';
import 'package:watt/src/features/company_dashboard/presentation/widgets/nav_item_tile.dart';
import 'package:watt/src/utils/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/features/company_dashboard/presentation/providers/sidebar_controller.dart';

class SidebarContent extends ConsumerWidget {
  final List<NavItem> navItems;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidebarContent({super.key, required this.navItems, required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isCollapsed = ref.watch(sidebarControllerProvider);

    return Column(
      children: [
        SizedBox(height: 50),
        // Branding & Toggle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 0 : 20),
          child: Row(
            mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            children: [
              if (!isCollapsed)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Iconsax.sun_1, color: AppTheme.primaryColor, size: 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Solar Hub',
                          style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryDarkColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                onPressed: () => ref.read(sidebarControllerProvider.notifier).toggle(),
                icon: Icon(isCollapsed ? Iconsax.arrow_right_3 : Iconsax.arrow_left_2, size: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
        // Nav Items
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12),
            itemCount: navItems.length,
            itemBuilder: (context, index) {
              return NavItemTile(item: navItems[index], isSelected: selectedIndex == index, onTap: () => onItemSelected(index), isCollapsed: isCollapsed);
            },
          ),
        ),
        // User Profile (Bottom)
        Padding(
          padding: EdgeInsets.all(20),
          child: InkWell(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              context.go('/home');
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.lightBackground, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: Icon(Iconsax.user, size: 18, color: AppTheme.primaryColor),
                  ),
                  if (!isCollapsed) ...[
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.admin_user,
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          Text(
                            l10n.super_admin,
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Icon(Iconsax.logout_1, size: 18, color: Colors.redAccent),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
