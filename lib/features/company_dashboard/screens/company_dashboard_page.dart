import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:solar_hub/features/company_dashboard/controllers/company_dashboard_controller.dart';
import 'package:solar_hub/features/company_dashboard/controllers/main_dashboard_controller.dart';
import 'package:solar_hub/features/company_dashboard/widgets/dashboard_menu_card.dart';
import 'package:solar_hub/features/company_dashboard/widgets/dashboard_metric_card.dart';
import 'package:solar_hub/layouts/shared/settings/settings_page.dart';
import 'package:solar_hub/utils/price_format_utils.dart';

class CompanyDashboardPage extends StatelessWidget {
  const CompanyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CompanyDashboardController());
    final mainController = Get.find<MainDashboardController>();

    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final company = controller.companyController.company.value;
      if (company == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('no_company_found'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('not_linked_company'.tr),
            ],
          ),
        );
      }

      if (company.status == 'pending') {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Iconsax.timer_1_bold, size: 60, color: Colors.orange),
              ),
              const SizedBox(height: 24),
              Text("verification_pending".tr, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "verification_pending_msg".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text("go_back".tr)),
            ],
          ),
        );
      }

      final stats = controller.companyController.stats;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome / Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white,
                          backgroundImage: company.logoUrl != null ? CachedNetworkImageProvider(company.logoUrl!) : null,
                          child: company.logoUrl == null
                              ? Text(
                                  company.name[0],
                                  style: TextStyle(fontSize: 28, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                company.tier.name.tr,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cash Balance
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.wallet_3_bold, color: Colors.white.withValues(alpha: 0.8), size: 16),
                                  const SizedBox(width: 6),
                                  Text("balance".tr, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  PriceFormatUtils.formatWithCurrency(company.balance, controller.effectiveCurrency.symbol),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3), margin: EdgeInsets.symmetric(horizontal: 16)),

                        // Inventory Value
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Iconsax.box_bold, color: Colors.white.withValues(alpha: 0.8), size: 16),
                                  const SizedBox(width: 6),
                                  Text("stock_value".tr, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  PriceFormatUtils.formatWithCurrency(stats['inventory_value'] ?? 0.0, controller.effectiveCurrency.symbol),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions (Stats)
            LayoutBuilder(
              builder: (context, constraints) {
                final double cardSpacing = 16;
                final double availableWidth = constraints.maxWidth;
                int metricCrossAxisCount = availableWidth > 900 ? 3 : (availableWidth > 600 ? 3 : 1);

                if (metricCrossAxisCount == 1) {
                  return Column(
                    children: [
                      DashboardMetricCard(
                        title: 'pending_orders'.tr,
                        value: (stats['pending_orders'] ?? 0).toString(),
                        icon: Iconsax.box_time_bold,
                        color: Colors.blue,
                        onTap: () => mainController.changePage(6, 'orders'),
                      ),
                      const SizedBox(height: 12),
                      DashboardMetricCard(
                        title: 'open_requests'.tr,
                        value: (stats['open_requests'] ?? 0).toString(),
                        icon: Iconsax.clipboard_text_bold,
                        color: Colors.orange,
                        onTap: () => mainController.changePage(3, 'offers'),
                      ),
                      const SizedBox(height: 12),
                      DashboardMetricCard(
                        title: 'low_stock'.tr,
                        value: '0',
                        icon: Iconsax.warning_2_bold,
                        color: Colors.redAccent,
                        onTap: () => mainController.changePage(4, 'inventory'),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: DashboardMetricCard(
                        title: 'pending_orders'.tr,
                        value: (stats['pending_orders'] ?? 0).toString(),
                        icon: Iconsax.box_time_bold,
                        color: Colors.blue,
                        onTap: () => mainController.changePage(6, 'orders'),
                      ),
                    ),
                    SizedBox(width: cardSpacing),
                    Expanded(
                      child: DashboardMetricCard(
                        title: 'open_requests'.tr,
                        value: (stats['open_requests'] ?? 0).toString(),
                        icon: Iconsax.clipboard_text_bold,
                        color: Colors.orange,
                        onTap: () => mainController.changePage(3, 'offers'),
                      ),
                    ),
                    SizedBox(width: cardSpacing),
                    Expanded(
                      child: DashboardMetricCard(
                        title: 'low_stock'.tr,
                        value: '0',
                        icon: Iconsax.warning_2_bold,
                        color: Colors.redAccent,
                        onTap: () => mainController.changePage(4, 'inventory'),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),

            _buildDashboardSection(context, 'manage_business'.tr, [
              if (controller.hasAnyRole(['owner', 'manager', 'sales', 'accountant']))
                DashboardMenuCard(
                  title: 'orders'.tr,
                  icon: FontAwesomeIcons.clipboardList,
                  color: Colors.deepOrange,
                  onTap: () => mainController.changePage(6, 'orders'),
                  badge: stats['pending_orders']?.toString() != "0" ? stats['pending_orders']?.toString() : null,
                ),
              if (controller.hasAnyRole(['owner', 'manager', 'sales']))
                DashboardMenuCard(title: 'pos'.tr, icon: FontAwesomeIcons.cashRegister, color: Colors.purple, onTap: () => mainController.changePage(5, 'pos')),
              if (controller.hasAnyRole(['owner', 'manager', 'accountant']))
                DashboardMenuCard(
                  title: 'invoices'.tr,
                  icon: FontAwesomeIcons.fileInvoiceDollar,
                  color: Colors.teal,
                  onTap: () => mainController.changePage(7, 'invoices'),
                ),
              if (controller.hasAnyRole(['owner', 'manager', 'inventory_manager', 'installer']))
                DashboardMenuCard(
                  title: 'inventory'.tr,
                  icon: FontAwesomeIcons.boxesStacked,
                  color: Colors.green,
                  onTap: () => mainController.changePage(4, 'inventory'),
                  badge: stats['products']?.toString() != "0" ? stats['products']?.toString() : null,
                ),
              if (controller.hasAnyRole(['owner', 'manager', 'sales']))
                DashboardMenuCard(
                  title: 'offer_requests'.tr,
                  icon: FontAwesomeIcons.bullhorn,
                  color: Colors.orange,
                  onTap: () => mainController.changePage(3, 'offers'),
                  badge: stats['open_requests']?.toString() != "0" ? stats['open_requests']?.toString() : null,
                ),
              if (controller.hasAnyRole(['owner', 'manager', 'accountant']))
                DashboardMenuCard(
                  title: 'accounting'.tr,
                  icon: FontAwesomeIcons.calculator,
                  color: Colors.deepPurple,
                  onTap: () => mainController.changePage(8, 'accounting'),
                ),
            ]),

            _buildDashboardSection(context, 'people'.tr, [
              DashboardMenuCard(title: 'members'.tr, icon: FontAwesomeIcons.users, color: Colors.brown, onTap: () => mainController.changePage(10, 'members')),
              if (controller.hasAnyRole(['owner', 'manager', 'sales', 'accountant']))
                DashboardMenuCard(
                  title: 'customers'.tr,
                  icon: FontAwesomeIcons.userGroup,
                  color: Colors.indigoAccent,
                  onTap: () => mainController.changePage(12, 'customers'),
                ),
              if (controller.hasAnyRole(['owner', 'manager', 'sales', 'installer']))
                DashboardMenuCard(
                  title: 'suppliers'.tr,
                  icon: Iconsax.shop_bold,
                  color: Colors.purpleAccent,
                  onTap: () => mainController.changePage(13, 'suppliers'),
                ),
              if (controller.hasAnyRole(['owner', 'manager', 'inventory_manager', 'sales', 'installer']))
                DashboardMenuCard(
                  title: 'my_purchases'.tr,
                  icon: FontAwesomeIcons.bagShopping,
                  color: Colors.pink,
                  onTap: () => mainController.changePage(14, 'my_purchases'),
                ),
            ]),

            _buildDashboardSection(context, 'tools'.tr, [
              if (controller.hasAnyRole(['owner', 'manager']))
                DashboardMenuCard(
                  title: 'analytics'.tr,
                  icon: FontAwesomeIcons.chartLine,
                  color: Colors.indigo,
                  onTap: () => mainController.changePage(9, 'analytics'),
                ),
              DashboardMenuCard(
                title: 'systems'.tr,
                icon: FontAwesomeIcons.solarPanel,
                color: Colors.blue,
                onTap: () => mainController.changePage(11, 'systems'),
              ),
              if (controller.hasAnyRole(['owner', 'manager', 'inventory_manager', 'driver']))
                DashboardMenuCard(title: 'delivery'.tr, icon: Icons.local_shipping, color: Colors.cyan, onTap: () => mainController.changePage(15, 'delivery')),
            ]),

            _buildDashboardSection(context, 'settings'.tr, [
              DashboardMenuCard(
                title: 'company_profile'.tr,
                icon: Iconsax.building_bold,
                color: Colors.blueGrey,
                onTap: () => mainController.changePage(1, 'profile'),
              ),
              if (controller.hasAnyRole(['owner', 'manager']))
                DashboardMenuCard(
                  title: 'subscription'.tr,
                  icon: FontAwesomeIcons.star,
                  color: Colors.amber,
                  onTap: () => mainController.changePage(2, 'subscription'),
                ),
              DashboardMenuCard(title: 'settings'.tr, icon: Iconsax.setting_2_bold, color: Colors.blueGrey, onTap: () => Get.to(SettingsPage())),
            ]),

            const SizedBox(height: 48), // Bottom padding
          ],
        ),
      );
    });
  }

  Widget _buildDashboardSection(BuildContext context, String title, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 16),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            double childAspectRatio = 1.1;

            if (constraints.maxWidth > 1400) {
              crossAxisCount = 6;
              childAspectRatio = 1.2;
            } else if (constraints.maxWidth > 1100) {
              crossAxisCount = 5;
              childAspectRatio = 1.1;
            } else if (constraints.maxWidth > 800) {
              crossAxisCount = 4;
              childAspectRatio = 1.0;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
              childAspectRatio = 1.0;
            }

            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
              children: children,
            );
          },
        ),
      ],
    );
  }
}
