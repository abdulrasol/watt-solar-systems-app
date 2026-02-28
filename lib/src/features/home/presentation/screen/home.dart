import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/calculations/presentation/screens/calculator_landing_page.dart';
import 'package:solar_hub/src/features/home/presentation/providers/home_page_provider.dart';
import 'package:solar_hub/src/features/home/presentation/screen/user_dashboard.dart';
import 'package:solar_hub/src/features/home/presentation/widgets/drawer.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homePageIndexProvider);
    // List pages = [const UserDashboard(), const CalculatorLandingPage(), const CommunityFeedPage(), const Store()];
    List pages = [const UserDashboard(), const CalculatorLandingPage(), const UserDashboard(), const UserDashboard()];

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(preferredSize: const Size.fromHeight(kToolbarHeight), child: _appBar(ref)),
      // But user wanted AppBar in Dashboard too now. Step 254 request: "use appabr ... in user_dashboard.dart as in home".
      // Step 262 implemented: appBar: _appBar() (always show).
      // So I will stick to ALWAYS showing _appBar(), but maybe title changes.
      // Wait, in Step 262 I changed it to `appBar: _appBar()`.
      // Let's verify what the previous code was.
      // Previous code in Step 258: `appBar: currentIndex == 0 ? null : _appBar(),`
      // Step 262 change: `appBar: _appBar(),`
      // So it is always shown.
      body: IndexedStack(index: index, children: pages.cast<Widget>()),

      bottomNavigationBar: CrystalNavigationBar(
        currentIndex: index,
        height: 10,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.black.withValues(alpha: 0.1),
        onTap: (int index) {
          ref.read(homePageIndexProvider.notifier).state = index;
        },
        items: [
          /// Dashboard
          CrystalNavigationBarItem(icon: Iconsax.home_bold, unselectedIcon: Iconsax.home_outline, selectedColor: Theme.of(context).primaryColor),

          /// Calculator
          CrystalNavigationBarItem(
            icon: FontAwesome.calculator_solid,
            unselectedIcon: FontAwesome.calculator_solid,
            selectedColor: Theme.of(context).primaryColor,
          ),

          /// Hub
          CrystalNavigationBarItem(icon: Icons.hub_outlined, unselectedIcon: Icons.hub_outlined, selectedColor: Theme.of(context).primaryColor),

          /// Store
          CrystalNavigationBarItem(
            icon: FontAwesome.store_slash_solid,
            unselectedIcon: FontAwesome.store_slash_solid,
            selectedColor: Theme.of(context).primaryColor,
          ),
        ],
      ),

      drawer: const AppDrawer(),
    );
  }

  AppBar _appBar(WidgetRef ref) {
    int index = ref.watch(homePageIndexProvider);

    return AppBar(
      title: Text('data'), // TODO: implement title
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: AppTheme.primaryColor),
          onPressed: () {
            // hubController.isSearching.toggle();
            // if (!hubController.isSearching.value) {
            //   hubController.searchController.clear();
            //   hubController.searchPosts('');
            // }
          },
        ),
        Row(
          children: [
            // Cart Icon (Only in Store)
            if (index == 3)
              Stack(
                children: [
                  IconButton(onPressed: () => {}, icon: const Icon(FontAwesome.cart_shopping_solid, size: 20)),

                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '5',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

            // Notification Icon with Badge
            Stack(
              children: [
                IconButton(
                  onPressed: () => {}, // TODO: implement Get.to(() => const NotificationsPage()),
                  icon: const Icon(Iconsax.notification_bing_bold, color: AppTheme.primaryColor),
                ),

                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '+9', // TODO: implement unread count
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
