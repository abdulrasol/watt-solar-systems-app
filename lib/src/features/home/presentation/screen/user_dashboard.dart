import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/home/presentation/providers/home_page_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

class UserDashboard extends ConsumerWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authProvider);

    // Mock stats for now (could be real fetches)
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          authController.isSigned
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
                      Text('good_morning', style: TextStyle(fontSize: 16, color: Colors.grey[600])), // TODO: implement localization
                      const SizedBox(height: 8),

                      Text(
                        authController.user?.firstName ?? 'User',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text('ready_manage_solar', style: TextStyle(fontSize: 14, color: Colors.grey[500])), // TODO: implement localization
                    ],
                  ),
                ),

          authController.isSigned ? const SizedBox.shrink() : const SizedBox(height: 24),

          // Overview Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('active_orders', "0", Iconsax.box_bold, Colors.blue)), // TODO: implement localization
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('my_systems', "0", Iconsax.sun_1_bold, Colors.orange)), // TODO: implement localization
            ],
          ),

          const SizedBox(height: 24),
          Text('quick_actions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // TODO: implement localization
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
                'calculator', // TODO: implement localization
                'plan_your_system', // TODO: implement localization
                Iconsax.calculator_bold,
                Colors.purple,
                () => ref.read(homePageIndexProvider.notifier).state = 1, // Switch to Calculator tab
              ),
              _buildActionCard(
                'store', // TODO: implement localization
                'buy_components', // TODO: implement localization
                Iconsax.shop_bold,
                Colors.pink,
                () => ref.read(homePageIndexProvider.notifier).state = 3, // Switch to Store tab
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Banner
          GestureDetector(
            onTap: () {
              ref.read(homePageIndexProvider.notifier).state = 2; // Switch to Hub tab
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
                          'join_community', // TODO: implement localization
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text('share_system_feedback', style: const TextStyle(color: Colors.white70)), // TODO: implement localization
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
