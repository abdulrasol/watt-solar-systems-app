import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';

import 'package:solar_hub/controllers/subscription_controller.dart';

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompanyController>();
    final mainController = Get.find<MainDashboardController>();
    final subController = Get.put(SubscriptionController());

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
                Text("solar_hub".tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Menu Items
          Expanded(
            child: Obx(() {
              final isSubActive = subController.isSubscriptionActive.value;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildNavItem(
                    context,
                    'dashboard'.tr,
                    Iconsax.category_bold,
                    () => mainController.changePage(0, 'dashboard'),
                    isSelected: mainController.currentIndex == 0,
                  ),

                  _buildSectionHeader('manage_business'.tr),

                  if (controller.hasAnyRole(['owner', 'manager', 'sales', 'accountant']))
                    _buildNavItem(
                      context,
                      'orders'.tr,
                      Iconsax.box_bold,
                      () => mainController.changePage(6, 'orders'),
                      isSelected: mainController.currentIndex == 6,
                      isLocked: !isSubActive,
                    ),

                  if (controller.hasAnyRole(['owner', 'manager', 'sales']))
                    _buildNavItem(
                      context,
                      'pos'.tr,
                      FontAwesomeIcons.cashRegister,
                      () => mainController.changePage(5, 'pos'),
                      isSelected: mainController.currentIndex == 5,
                      isLocked: !isSubActive,
                    ),

                  if (controller.hasAnyRole(['owner', 'manager', 'accountant']))
                    _buildNavItem(
                      context,
                      'invoices'.tr,
                      FontAwesomeIcons.fileInvoiceDollar,
                      () => mainController.changePage(7, 'invoices'),
                      isSelected: mainController.currentIndex == 7,
                      isLocked: !isSubActive,
                    ),

                  if (controller.hasAnyRole(['owner', 'manager', 'accountant']))
                    _buildNavItem(
                      context,
                      'accounting'.tr,
                      FontAwesomeIcons.calculator,
                      () => mainController.changePage(8, 'accounting'),
                      isSelected: mainController.currentIndex == 8,
                    ),

                  if (controller.hasAnyRole(['owner', 'manager', 'inventory_manager', 'installer']))
                    _buildNavItem(
                      context,
                      'inventory'.tr,
                      FontAwesomeIcons.boxesStacked,
                      () => mainController.changePage(4, 'inventory'),
                      isSelected: mainController.currentIndex == 4,
                    ),

                  if (controller.hasAnyRole(['owner', 'manager', 'sales']))
                    _buildNavItem(
                      context,
                      'offers'.tr,
                      FontAwesomeIcons.bullhorn,
                      () => mainController.changePage(3, 'offers'),
                      isSelected: mainController.currentIndex == 3,
                      isLocked: !isSubActive,
                    ),

                  _buildSectionHeader('people'.tr),

                  _buildNavItem(
                    context,
                    'members'.tr,
                    Iconsax.people_bold,
                    () => mainController.changePage(10, 'members'),
                    isSelected: mainController.currentIndex == 10,
                  ),

                  if (controller.hasAnyRole(['owner', 'manager', 'sales', 'accountant']))
                    _buildNavItem(
                      context,
                      'customers'.tr,
                      Iconsax.user_tag_bold,
                      () => mainController.changePage(12, 'customers'),
                      isSelected: mainController.currentIndex == 12,
                      isLocked: !isSubActive,
                    ),

                  if (controller.hasAnyRole(['owner', 'manager', 'sales', 'installer']))
                    _buildNavItem(
                      context,
                      'suppliers'.tr,
                      Iconsax.shop_bold,
                      () => mainController.changePage(13, 'suppliers'),
                      isSelected: mainController.currentIndex == 13,
                      isLocked: !isSubActive,
                    ),

                  if (controller.hasAnyRole(['owner', 'manager', 'inventory_manager', 'sales', 'installer']))
                    _buildNavItem(
                      context,
                      'my_purchases'.tr,
                      FontAwesomeIcons.bagShopping,
                      () => mainController.changePage(14, 'my_purchases'),
                      isSelected: mainController.currentIndex == 14,
                      isLocked: !isSubActive,
                    ),

                  _buildSectionHeader('tools'.tr),

                  if (controller.hasAnyRole(['owner', 'manager']))
                    _buildNavItem(
                      context,
                      'analytics'.tr,
                      Iconsax.chart_2_bold,
                      () => mainController.changePage(9, 'analytics'),
                      isSelected: mainController.currentIndex == 9,
                      isLocked: !isSubActive, // Assuming analytics is also restricted based on previous list
                    ),

                  _buildNavItem(
                    context,
                    'systems'.tr,
                    Iconsax.sun_1_bold,
                    () => mainController.changePage(11, 'systems'),
                    isSelected: mainController.currentIndex == 11,
                    isLocked: !isSubActive,
                  ),

                  if (controller.hasAnyRole(['owner', 'manager', 'inventory_manager', 'driver']))
                    _buildNavItem(
                      context,
                      'delivery'.tr,
                      Icons.local_shipping_outlined,
                      () => mainController.changePage(15, 'delivery'),
                      isSelected: mainController.currentIndex == 15,
                      isLocked: !isSubActive,
                    ),

                  _buildSectionHeader('settings'.tr),
                  _buildNavItem(
                    context,
                    'company_profile'.tr,
                    Iconsax.building_bold,
                    () => mainController.changePage(1, 'profile'),
                    isSelected: mainController.currentIndex == 1,
                  ),

                  if (controller.hasAnyRole(['owner', 'manager']))
                    _buildNavItem(
                      context,
                      'subscription'.tr,
                      FontAwesomeIcons.star,
                      () => mainController.changePage(2, 'subscription'),
                      isSelected: mainController.currentIndex == 2,
                    ),

                  const Divider(height: 32),

                  _buildNavItem(
                    context,
                    'switch_to_user_view'.tr,
                    Iconsax.user_square_bold,
                    () => Get.offAllNamed('/home'),
                    isSelected: false,
                    closeDrawer: false,
                  ),

                  _buildNavItem(context, 'settings'.tr, Iconsax.setting_2_bold, () => Get.toNamed('/settings'), isSelected: false),

                  const SizedBox(height: 20),
                ],
              );
            }),
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
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isSelected = false,
    bool isLocked = false,
    bool closeDrawer = true,
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
          onTap(); // Controller will handle dialog if locked, but here we invoke it anyway
          if (closeDrawer && (Scaffold.maybeOf(context)?.isDrawerOpen ?? false)) {
            // Don't close drawer immediately if locked? Ideally controller shows dialog
            Navigator.of(context).pop();
          }
        },
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
