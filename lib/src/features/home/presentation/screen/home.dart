import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
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
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homePageIndexProvider);
    final bool hasCommunity = isEnabled(ref, 'community');
    final bool hasStore = isEnabled(ref, 'store', defaultValue: true);

    final availableIndices = [0, 1];
    if (hasCommunity) availableIndices.add(2);
    if (hasStore) availableIndices.add(3);

    int navIndex = availableIndices.indexOf(index);
    if (navIndex == -1) navIndex = 0; // fallback if state is out of sync

    // List pages = [const UserDashboard(), const CalculatorLandingPage(), const CommunityFeedPage(), const Store()];
    List<Widget> pages = [
      const UserDashboard(),
      const CalculatorLandingPage(),
      const UserDashboard(),
      const StorefrontScreen(audience: StorefrontAudience.b2c),
    ];

    List<CrystalNavigationBarItem> navItems = [
      /// Dashboard
      CrystalNavigationBarItem(
        icon: Iconsax.home_bold,
        unselectedIcon: Iconsax.home_outline,
        selectedColor: Theme.of(context).primaryColor,
      ),

      /// Calculator
      CrystalNavigationBarItem(
        icon: FontAwesome.calculator_solid,
        unselectedIcon: FontAwesome.calculator_solid,
        selectedColor: Theme.of(context).primaryColor,
      ),
    ];

    if (hasCommunity) {
      navItems.add(
        /// Hub
        CrystalNavigationBarItem(
          icon: Icons.hub_outlined,
          unselectedIcon: Icons.hub_outlined,
          selectedColor: Theme.of(context).primaryColor,
        ),
      );
    }

    if (hasStore) {
      navItems.add(
        /// Store
        CrystalNavigationBarItem(
          icon: Iconsax.shop_bold,
          unselectedIcon: Iconsax.shop_outline,
          selectedColor: Theme.of(context).primaryColor,
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _appBar(context, ref),
      ),
      body: IndexedStack(index: index, children: pages),

      bottomNavigationBar: Padding(
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
            ref.read(homePageIndexProvider.notifier).state =
                availableIndices[index];
          },
          items: navItems,
        ),
      ),

      drawer: const AppDrawer(),
    );
  }

  AppBar _appBar(BuildContext context, WidgetRef ref) {
    int index = ref.watch(homePageIndexProvider);
    final notificationCount = ref
        .watch(notificationHistoryProvider)
        .items
        .length;

    return AppBar(
      title: Text(
        index == 0
            ? AppLocalizations.of(context)!.home
            : index == 3
            ? AppLocalizations.of(context)!.store
            : AppLocalizations.of(context)!.calculator,
      ),
      actions: [
        // IconButton(
        //   icon: Icon(Icons.search, color: AppTheme.primaryColor),
        //   onPressed: () {
        //     // hubController.isSearching.toggle();
        //     // if (!hubController.isSearching.value) {
        //     //   hubController.searchController.clear();
        //     //   hubController.searchPosts('');
        //     // }
        //   },
        // ),
        Row(
          children: [
            // Cart Icon (Only in Store)
            if (index == 3)
              ListenableBuilder(
                listenable: storefrontCart,
                builder: (context, _) {
                  final count = storefrontCart.totalItems(
                    StorefrontAudience.b2c,
                  );
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
                              count > 99 ? '99+' : '$count',
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
              Stack(
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
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
