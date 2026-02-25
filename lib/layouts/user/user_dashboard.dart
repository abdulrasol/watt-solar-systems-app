import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/controllers/home_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    // Mock stats for now (could be real fetches)
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Obx(
            () => authController.user.value == null
                ? const SizedBox.shrink()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor.withValues(alpha: 0.1), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('good_morning'.tr, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Obx(() {
                          final name = authController.user.value?.fullName;
                          final emailName = authController.user.value?.email?.split('@')[0];
                          return Text(
                            (name != null && name.isNotEmpty) ? name : (emailName ?? 'User'),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          );
                        }),
                        const SizedBox(height: 8),
                        Text('ready_manage_solar'.tr, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                      ],
                    ),
                  ),
          ),
          Obx(() => authController.user.value == null ? const SizedBox.shrink() : const SizedBox(height: 24)),

          // Overview Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('active_orders'.tr, "0", Iconsax.box_bold, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('my_systems'.tr, "0", Iconsax.sun_1_bold, Colors.orange)),
            ],
          ),

          const SizedBox(height: 24),
          Text('quick_actions'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            padding: EdgeInsets.zero,
            children: [
              _buildActionCard(
                'calculator'.tr,
                'plan_your_system'.tr,
                Iconsax.calculator_bold,
                Colors.purple,
                () => Get.find<HomeController>().changeIndex(1), // Switch to Calculator tab
              ),
              _buildActionCard(
                'store'.tr,
                'buy_components'.tr,
                Iconsax.shop_bold,
                Colors.pink,
                () => Get.find<HomeController>().changeIndex(3), // Switch to Store tab
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Banner
          GestureDetector(
            onTap: () {
              Get.find<HomeController>().changeIndex(2); // Switch to Hub tab
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'join_community'.tr,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text('share_system_feedback'.tr, style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Iconsax.people_bold, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
