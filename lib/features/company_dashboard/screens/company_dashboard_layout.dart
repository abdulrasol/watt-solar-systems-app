import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/controllers/notifications_controller.dart';
import 'package:solar_hub/features/company_dashboard/widgets/dashboard_sidebar.dart';
import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/layouts/company/notifications/notifications_page.dart';

class CompanyDashboardLayout extends StatelessWidget {
  const CompanyDashboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final mainController = Get.isRegistered<MainDashboardController>() ? Get.find<MainDashboardController>() : Get.put(MainDashboardController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        return Obx(
          () => Scaffold(
            appBar: _buildAppBar(context, showLeading: !isDesktop, title: mainController.currentTitle, mainController: mainController),
            drawer: isDesktop ? null : const Drawer(child: DashboardSidebar()),
            body: Row(
              children: [
                if (isDesktop) const DashboardSidebar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(key: ValueKey(mainController.currentIndex), child: mainController.currentBody),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, {required bool showLeading, required String title, required MainDashboardController mainController}) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).cardColor,
      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      leading: mainController.canGoBack
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => mainController.goBack())
          : (showLeading ? null : null), // null means it will use automaticallyImplyLeading if true
      automaticallyImplyLeading: !mainController.canGoBack && showLeading,
      actions: [...mainController.actions, _buildNotificationBadge(context), const SizedBox(width: 16)],
    );
  }

  Widget _buildNotificationBadge(BuildContext context) {
    return Obx(() {
      int count = 0;
      if (Get.isRegistered<NotificationsController>()) {
        count = Get.find<NotificationsController>().unreadCount.value;
      }
      return Stack(
        children: [
          IconButton(
            onPressed: () => Get.to(() => const NotificationsPage()),
            icon: Icon(Iconsax.notification_bing_bold, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6)),
            tooltip: 'notifications'.tr,
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
    });
  }
}
