import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/offline_status_banner.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/calculator_landing_page.dart';
import 'package:solar_hub/src/features/home/presentation/providers/home_page_provider.dart';
import 'package:solar_hub/src/features/home/presentation/screen/user_dashboard.dart';
import 'package:solar_hub/src/features/home/presentation/widgets/drawer.dart';
import 'package:solar_hub/src/features/notifications/presentation/controllers/notification_history_controller.dart';
import 'package:solar_hub/src/features/storefront/domain/entities/storefront_models.dart';
import 'package:solar_hub/src/features/storefront/presentation/providers/storefront_cart_controller.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_cart_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/screens/storefront_screen.dart';
import 'package:solar_hub/src/features/storefront/presentation/utils/storefront_page_route.dart';
import 'package:solar_hub/src/features/services/presentation/screens/services_explorer_screen.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

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
      const UserDashboard(),
    ];
    final navItems = navigation.visibleTabs
        .map((tab) => _buildNavItem(tab, context))
        .toList();
    final navIndex = navigation.navIndexFor(effectiveIndex);

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _appBar(context, ref),
      ),
      body: Column(
        children: [
          const OfflineStatusBanner(),
          Expanded(child: IndexedStack(index: effectiveIndex, children: pages)),
        ],
      ),
      bottomNavigationBar: _navbar(
        navItems,
        context,
        navIndex,
        ref,
        navigation,
      ),
      drawer: const AppDrawer(),
    );
  }

  CrystalNavigationBarItem _buildNavItem(HomeTab tab, BuildContext context) {
    switch (tab) {
      case HomeTab.dashboard:
        return CrystalNavigationBarItem(
          icon: Iconsax.home_bold,
          unselectedIcon: Iconsax.home_outline,
          selectedColor: Theme.of(context).primaryColor,
        );
      case HomeTab.calculator:
        return CrystalNavigationBarItem(
          icon: FontAwesome.calculator_solid,
          unselectedIcon: FontAwesome.calculator_solid,
          selectedColor: Theme.of(context).primaryColor,
        );
      case HomeTab.services:
        return CrystalNavigationBarItem(
          icon: Iconsax.category_2_bold,
          unselectedIcon: Iconsax.category_2_outline,
          selectedColor: Theme.of(context).primaryColor,
        );
      case HomeTab.store:
        return CrystalNavigationBarItem(
          icon: Iconsax.shop_bold,
          unselectedIcon: Iconsax.shop_outline,
          selectedColor: Theme.of(context).primaryColor,
        );
      case HomeTab.community:
        return CrystalNavigationBarItem(
          icon: Icons.hub_outlined,
          unselectedIcon: Icons.hub_outlined,
          selectedColor: Theme.of(context).primaryColor,
        );
    }
  }

  Padding _navbar(
    List<CrystalNavigationBarItem> navItems,
    BuildContext context,
    int navIndex,
    WidgetRef ref,
    HomeNavigationState navigation,
  ) {
    return Padding(
      padding: navItems.length <= 2
          ? EdgeInsets.only(
              left: MediaQuery.sizeOf(context).width * 0.22,
              right: MediaQuery.sizeOf(context).width * 0.22,
              bottom: 10,
            )
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
        return 'community';
    }
  }

  AppBar _appBar(BuildContext context, WidgetRef ref) {
    final navigation = ref.watch(homeNavigationProvider);
    final selectedIndex = ref.watch(homePageIndexProvider);
    final currentTab = HomeTab.fromIndex(
      navigation.sanitizeIndex(selectedIndex),
    );
    final notificationCount = ref
        .watch(notificationHistoryProvider)
        .items
        .length;

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
                              page: const StorefrontCartScreen(
                                audience: StorefrontAudience.b2c,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          FontAwesome.cart_shopping_solid,
                          size: 20,
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              count > 9 ? '9+' : '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

            // Notification Icon with Badge
            if (ref.watch(authProvider).isSigned)
              InkWell(
                onTap: () => context.push('/notifications'),
                child: Stack(
                  children: [
                    IconButton(
                      onPressed: () => context.push('/notifications'),
                      icon: const Icon(
                        Iconsax.notification_bing_bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    if (notificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notificationCount > 9 ? '9+' : '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
