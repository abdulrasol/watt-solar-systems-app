import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/admin/controllers/admin_dashboard_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:icons_plus/icons_plus.dart';

class AdminDashboardLayout extends StatelessWidget {
  const AdminDashboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar (Visible on Desktop)
          if (isDesktop) _buildSidebar(context, controller),

          // Main Body
          Expanded(
            child: Column(
              children: [
                _buildAppBar(context, controller, !isDesktop),
                Expanded(child: GetBuilder<AdminDashboardController>(builder: (controller) => controller.currentBody)),
              ],
            ),
          ),
        ],
      ),
      drawer: !isDesktop ? Drawer(child: _buildSidebar(context, controller)) : null,
    );
  }

  Widget _buildAppBar(BuildContext context, AdminDashboardController controller, bool showMenu) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            if (showMenu)
              Builder(
                builder: (context) => IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.menu)),
              ),

            Obx(() => Text(controller.currentTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const Spacer(),
            // User Profile / Logout
            IconButton(
              onPressed: () => Get.offAllNamed('/home'), // Go back to Home/User View safely
              icon: const Icon(Icons.exit_to_app, color: Colors.grey),
              tooltip: "Exit Admin Mode",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AdminDashboardController controller) {
    return Container(
      width: 260,
      color: Theme.of(context).cardColor,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.security_safe_bold, color: AppTheme.primaryColor, size: 32),
                const SizedBox(width: 12),
                const Text("SOLAR ADMIN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
              ],
            ),
            const SizedBox(height: 32),

            // Menu Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.menuItems.length,
                itemBuilder: (context, index) {
                  final item = controller.menuItems[index];
                  return Obx(() {
                    final isSelected = controller.currentIndex == item['index'];
                    return _buildNavItem(context, item['title'], item['icon'], isSelected, () {
                      controller.changePage(item['index']);
                      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                        Navigator.pop(context);
                      }
                    });
                  });
                },
              ),
            ),

            // Footer
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        dense: true,
      ),
    );
  }
}
