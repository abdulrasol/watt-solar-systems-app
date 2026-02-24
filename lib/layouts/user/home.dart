import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/controllers/home_controller.dart';
import 'package:solar_hub/features/calculations/layouts/calculator_landing_page.dart';
import 'package:solar_hub/features/store/controllers/cart_controller.dart';
import 'package:solar_hub/features/community/screens/community_feed_page.dart';
import 'package:solar_hub/controllers/notifications_controller.dart';
import 'package:solar_hub/layouts/company/notifications/notifications_page.dart';
import 'package:solar_hub/features/store/screens/cart_page.dart';
import 'package:solar_hub/features/store/screens/store_home_page.dart';
import 'package:solar_hub/layouts/user/user_dashboard.dart';
import 'package:solar_hub/layouts/shared/widgets/drawer.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/features/community/controllers/community_controller.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    List pages = [const UserDashboard(), const CalculatorLandingPage(), const CommunityFeedPage(), const Store()];

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(preferredSize: const Size.fromHeight(kToolbarHeight), child: Obx(() => _appBar())),
      // But user wanted AppBar in Dashboard too now. Step 254 request: "use appabr ... in user_dashboard.dart as in home".
      // Step 262 implemented: appBar: _appBar() (always show).
      // So I will stick to ALWAYS showing _appBar(), but maybe title changes.
      // Wait, in Step 262 I changed it to `appBar: _appBar()`.
      // Let's verify what the previous code was.
      // Previous code in Step 258: `appBar: currentIndex == 0 ? null : _appBar(),`
      // Step 262 change: `appBar: _appBar(),`
      // So it is always shown.
      body: Obx(() => IndexedStack(index: controller.currentIndex.value, children: pages.cast<Widget>())),

      bottomNavigationBar: Obx(
        () => CrystalNavigationBar(
          currentIndex: controller.currentIndex.value,
          height: 10,
          unselectedItemColor: Colors.white70,
          backgroundColor: Colors.black.withValues(alpha: 0.1),
          onTap: (int index) {
            controller.changeIndex(index);
          },
          items: [
            /// Dashboard
            CrystalNavigationBarItem(icon: Iconsax.home_bold, unselectedIcon: Iconsax.home_outline, selectedColor: Theme.of(context).primaryColor),

            /// Calculator
            CrystalNavigationBarItem(
              icon: FontAwesomeIcons.calculator,
              unselectedIcon: FontAwesomeIcons.calculator,
              selectedColor: Theme.of(context).primaryColor,
            ),

            /// Hub
            CrystalNavigationBarItem(icon: Icons.hub_outlined, unselectedIcon: Icons.hub_outlined, selectedColor: Theme.of(context).primaryColor),

            /// Store
            CrystalNavigationBarItem(icon: FontAwesomeIcons.store, unselectedIcon: FontAwesomeIcons.store, selectedColor: Theme.of(context).primaryColor),
          ],
        ),
      ),
      drawer: const AppDrawer(),
    );
  }

  AppBar _appBar() {
    final CartController cartController = Get.put(CartController());
    final HomeController controller = Get.find();
    final CommunityController hubController = Get.isRegistered<CommunityController>() ? Get.find() : Get.put(CommunityController());

    return AppBar(
      title: Obx(() {
        if (controller.currentIndex.value == 2 && hubController.isSearching.value) {
          return TextField(
            controller: hubController.searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'search_hub'.tr,
              border: InputBorder.none,
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (val) => hubController.searchPosts(val),
          );
        }
        return Text(['Dashboard', 'Calculator', 'Hub', 'Shop'][controller.currentIndex.value].tr);
      }),
      actions: [
        Obx(() {
          final isHub = controller.currentIndex.value == 2;
          if (!isHub) return const SizedBox.shrink();

          return IconButton(
            icon: Icon(hubController.isSearching.value ? Icons.close : Icons.search, color: AppTheme.primaryColor),
            onPressed: () {
              hubController.isSearching.toggle();
              if (!hubController.isSearching.value) {
                hubController.searchController.clear();
                hubController.searchPosts('');
              }
            },
          );
        }),
        Row(
          children: [
            // Cart Icon (Only in Store)
            if (controller.currentIndex.value == 3)
              Obx(
                () => Stack(
                  children: [
                    IconButton(onPressed: () => Get.to(() => const CartPage()), icon: const Icon(FontAwesomeIcons.cartShopping, size: 20)),
                    if (cartController.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text(
                            '${cartController.itemCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Notification Icon with Badge
            Obx(() {
              final count = Get.find<NotificationsController>().unreadCount.value;
              return Stack(
                children: [
                  IconButton(
                    onPressed: () => Get.to(() => const NotificationsPage()),
                    icon: const Icon(Iconsax.notification_bing_bold, color: AppTheme.primaryColor),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          count > 9 ? '+9' : '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
