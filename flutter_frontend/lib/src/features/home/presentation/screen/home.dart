import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/core/widgets/offline_status_banner.dart';
import 'package:watt/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:watt/src/features/calculations/presentation/screens/calculator_landing_page.dart';
import 'package:watt/src/features/home/presentation/providers/home_page_provider.dart';
import 'package:watt/src/features/home/presentation/screen/user_dashboard.dart';
import 'package:watt/src/features/home/presentation/widgets/drawer.dart';
import 'package:watt/src/features/notifications/presentation/controllers/notification_history_controller.dart';
import 'package:watt/src/shared/presntations/providers/is_enabled_providers.dart';
import 'package:watt/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:watt/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:watt/src/features/storefront/presentation/screens/storefront_screen.dart';
import 'package:watt/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:watt/src/features/services/presentation/screens/services_explorer_screen.dart';
import 'package:watt/src/utils/app_theme.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(homePageIndexProvider);
    final navigation = ref.watch(homeNavigationProvider);
    final effectiveIndex = navigation.sanitizeIndex(selectedIndex);

    if (selectedIndex != effectiveIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(homePageIndexProvider.notifier).state = effectiveIndex;
      });
    }

    final pages = <Widget>[
      const UserDashboard(),
      const CalculatorLandingPage(showAppBar: false),
      const ServicesExplorerScreen(embedded: true),
      const StorefrontScreen(audience: StorefrontAudience.b2c),
    ];
    final navItems = navigation.visibleTabs.map((tab) => _buildNavItem(tab, context)).toList();
    final navIndex = navigation.navIndexFor(effectiveIndex);

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(preferredSize: const Size.fromHeight(kToolbarHeight), child: _appBar(context, ref)),
      body: Column(
        children: [
          const OfflineStatusBanner(),
          Expanded(
            child: IndexedStack(index: effectiveIndex, children: pages),
          ),
        ],
      ),
      bottomNavigationBar: _navbar(navItems, context, navIndex, ref, navigation),
      drawer: const AppDrawer(),
    );
  }

  CrystalNavigationBarItem _buildNavItem(HomeTab tab, BuildContext context) {
    switch (tab) {
      case HomeTab.dashboard:
        return CrystalNavigationBarItem(icon: Iconsax.home, unselectedIcon: Iconsax.home, selectedColor: Theme.of(context).primaryColor);
      case HomeTab.calculator:
        return CrystalNavigationBarItem(
          icon: Iconsax.calculator,
          unselectedIcon: Iconsax.calculator,
          selectedColor: Theme.of(context).primaryColor,
        );
      case HomeTab.services:
        return CrystalNavigationBarItem(icon: Iconsax.category_2, unselectedIcon: Iconsax.category_2, selectedColor: Theme.of(context).primaryColor);
      case HomeTab.store:
        return CrystalNavigationBarItem(icon: Iconsax.shop, unselectedIcon: Iconsax.shop, selectedColor: Theme.of(context).primaryColor);
      case HomeTab.community:
        return CrystalNavigationBarItem(icon: Icons.hub_outlined, unselectedIcon: Icons.hub_outlined, selectedColor: Theme.of(context).primaryColor);
    }
  }

  Padding _navbar(List<CrystalNavigationBarItem> navItems, BuildContext context, int navIndex, WidgetRef ref, HomeNavigationState navigation) {
    return Padding(
      padding: navItems.length <= 2
          ? EdgeInsets.only(left: MediaQuery.sizeOf(context).width * 0.22, right: MediaQuery.sizeOf(context).width * 0.22, bottom: 10)
          : EdgeInsets.zero,
      child: CrystalNavigationBar(
        currentIndex: navIndex,
        height: 10,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black.withValues(alpha: 0.1),
        onTap: (int index) {
          selectHomeTab(ref, navigation.visibleTabAt(index));
        },
        items: navItems,
      ),
    );
  }

  String _getTitle(HomeTab tab, BuildContext context) {
    switch (tab) {
      case HomeTab.dashboard:
        return AppLocalizations.of(context)!.home;
      case HomeTab.calculator:
        return AppLocalizations.of(context)!.calculator;
      case HomeTab.services:
        return AppLocalizations.of(context)!.services;
      case HomeTab.store:
        return AppLocalizations.of(context)!.store;
      case HomeTab.community:
        return AppLocalizations.of(context)!.home;
    }
  }

  AppBar _appBar(BuildContext context, WidgetRef ref) {
    final navigation = ref.watch(homeNavigationProvider);
    final selectedIndex = ref.watch(homePageIndexProvider);
    final currentTab = HomeTab.fromIndex(navigation.sanitizeIndex(selectedIndex));

    return AppBar(
      title: Text(_getTitle(currentTab, context)),
      actions: [
        Row(
          children: [
            // Cart Icon (Only in Store)
            if (currentTab == HomeTab.store)
              ListenableBuilder(
                listenable: storefrontCart,
                builder: (context, _) {
                  final count = storefrontCart.totalItemsAll();
                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            buildStorefrontRoute(
                              context: context,
                              page: const StorefrontCartScreen(audience: StorefrontAudience.b2c),
                            ),
                          );
                        },
                        icon: const Icon(Iconsax.shopping_cart, size: 20),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

            // Notification Icon with Badge
            Consumer(
              builder: (context, ref, _) {
                final isSigned = ref.watch(authProvider.select((auth) => auth.isSigned));
                final notificationsEnabled = ref.watch(isNotificationsEnabled);
                if (!isSigned || !notificationsEnabled) {
                  return const SizedBox.shrink();
                }
                final notificationCount = ref.watch(notificationHistoryProvider.select((state) => state.totalCount));
                return InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/notifications'),
                  child: Stack(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                        icon: const Icon(Iconsax.notification_bing, color: AppTheme.primaryColor),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              notificationCount > 9 ? '9+' : '$notificationCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
