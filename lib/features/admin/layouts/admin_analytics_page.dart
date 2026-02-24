import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/services/supabase_service.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:solar_hub/features/admin/layouts/admin_orders_page.dart';
import 'package:solar_hub/features/admin/layouts/admin_products_page.dart';
import 'package:solar_hub/features/admin/layouts/admin_systems_page.dart';

class AdminAnalyticsController extends GetxController {
  final _supabase = SupabaseService().client;
  final isLoading = false.obs;

  // Stats
  final totalUsers = 0.obs;
  final totalCompanies = 0.obs;
  final totalSystems = 0.obs;
  final totalOrders = 0.obs;
  final totalProducts = 0.obs;

  final topSellingCompanies = <Map<String, dynamic>>[].obs;
  final recentCompanies = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    isLoading.value = true;
    try {
      // Parallel fetching for summary counts
      final results = await Future.wait([
        _supabase.from('profiles').count(),
        _supabase.from('companies').count(),
        _supabase.from('systems').count(),
        _supabase.from('orders').count(),
        _supabase.from('products').count(),
      ]);

      totalUsers.value = results[0];
      totalCompanies.value = results[1];
      totalSystems.value = results[2];
      totalOrders.value = results[3];
      totalProducts.value = results[4];

      // Fetch Recent Companies
      final recent = await _supabase.from('companies').select().order('created_at', ascending: false).limit(5);
      recentCompanies.assignAll(List<Map<String, dynamic>>.from(recent));

      // Fetch Top Selling (Mocking complex aggregation for now or performing client-side if data is small,
      // but for scalable solution we'd need an RPC or View. For now, let's just show recent active companies as placeholder or fetch orders to aggregate)
      // Simulating "Top Selling" by just taking random active companies for demonstration if no RPC exists
      final top = await _supabase.from('companies').select().eq('status', 'active').limit(5);
      topSellingCompanies.assignAll(List<Map<String, dynamic>>.from(top));
    } catch (e) {
      debugPrint("Error fetching admin stats: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAnalyticsController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Platform Overview", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount = width > 1100 ? 5 : (width > 800 ? 3 : 2);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard(context, "Users", controller.totalUsers.value, Iconsax.people_bold, Colors.blue),
                      _buildStatCard(
                        context,
                        "Companies",
                        controller.totalCompanies.value,
                        Iconsax.buildings_bold,
                        Colors.orange,
                        onTap: () {
                          final dashboardController = Get.find<AdminDashboardController>();
                          dashboardController.changePage(1); // Navigate to Companies tab
                        },
                      ),
                      _buildStatCard(
                        context,
                        "Systems",
                        controller.totalSystems.value,
                        Iconsax.sun_1_bold,
                        Colors.yellow[700]!,
                        onTap: () {
                          Get.to(() => const AdminSystemsPage());
                        },
                      ),
                      _buildStatCard(
                        context,
                        "Orders",
                        controller.totalOrders.value,
                        Iconsax.box_bold,
                        Colors.green,
                        onTap: () {
                          Get.to(() => const AdminOrdersPage());
                        },
                      ),
                      _buildStatCard(
                        context,
                        "Products",
                        controller.totalProducts.value,
                        Iconsax.shopping_bag_bold,
                        Colors.purple,
                        onTap: () {
                          Get.to(() => const AdminProductsPage());
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recent Registrations
                  Expanded(flex: 3, child: _buildSection(context, "Recent Companies", _buildRecentCompaniesList(controller.recentCompanies))),
                  if (MediaQuery.of(context).size.width > 900) ...[
                    const SizedBox(width: 24),
                    // Top Companies
                    Expanded(
                      flex: 2,
                      child: _buildSection(
                        context,
                        "Active Performers",
                        _buildRecentCompaniesList(controller.topSellingCompanies), // Reusing list for now
                      ),
                    ),
                  ],
                ],
              ),

              if (MediaQuery.of(context).size.width <= 900) ...[
                const SizedBox(height: 24),
                _buildSection(context, "Active Performers", _buildRecentCompaniesList(controller.topSellingCompanies)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildRecentCompaniesList(List<Map<String, dynamic>> companies) {
    if (companies.isEmpty) return const Text("No data available");

    return Column(
      children: companies.map((c) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            backgroundImage: c['logo_url'] != null ? CachedNetworkImageProvider(c['logo_url']) : null,
            child: c['logo_url'] == null ? const Icon(Iconsax.building_bold, size: 20) : null,
          ),
          title: Text(c['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(c['tier'] ?? 'N/A', style: const TextStyle(fontSize: 12)),
          trailing: Text((c['created_at'] as String?)?.substring(0, 10) ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, int value, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ),
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
