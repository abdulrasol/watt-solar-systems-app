import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/features/admin/controllers/app_config_controller.dart';
import 'package:solar_hub/features/auth/services/auth_services.dart';
import 'package:solar_hub/features/company_dashboard/screens/main_dashboard_page.dart';
import 'package:solar_hub/services/theme_service.dart';
import 'package:solar_hub/utils/app_theme.dart';
// import 'package:solar_hub/layouts/user/hub/offer_requests/user_requests_page.dart'; // Old
import 'package:solar_hub/features/requests/screens/user_requests_page.dart';
import 'package:solar_hub/features/company_registration/screens/company_registration_page.dart';
import 'package:solar_hub/features/admin/layouts/admin_dashboard_layout.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    // Lazy put to find or create if not exists, we use it to check membership
    final CompanyController companyController = Get.put(CompanyController());
    final AppConfigController appConfigController = Get.put(AppConfigController());
    final themeService = ThemeService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: 300,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topRight: Radius.circular(30), bottomRight: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2C).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
              border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Column(
              children: [
                _buildHeader(authController),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Obx(() {
                        if (authController.isSigned.value) {
                          return Column(
                            children: [
                              _buildDrawerItem(
                                context: context,
                                icon: Iconsax.box_bold,
                                title: "My Orders",
                                onTap: () => Get.toNamed('/my-orders'),
                                delay: 100,
                              ),
                              _buildDrawerItem(
                                context: context,
                                icon: Iconsax.setting_2_bold,
                                title: "My Systems",
                                onTap: () => Get.toNamed('/my-systems'),
                                delay: 150,
                              ),
                              _buildDrawerItem(
                                context: context,
                                icon: Iconsax.clipboard_bold,
                                title: "My Requests",
                                onTap: () => Get.to(() => const UserRequestsPage()),
                                delay: 160,
                              ),
                              // Company Dashboard or Register
                              Obx(() {
                                final company = companyController.company.value;
                                if (company != null) {
                                  return _buildDrawerItem(
                                    context: context,
                                    icon: Iconsax.building_bold,
                                    title: "Company Dashboard",
                                    onTap: () => Get.to(() => const MainDashboardPage()),
                                    delay: 170,
                                  );
                                } else if (authController.role.value == 'user' && appConfigController.isEnabled('register_new_company')) {
                                  return _buildDrawerItem(
                                    context: context,
                                    icon: Iconsax.building_3_bold,
                                    title: "Register Company",
                                    onTap: () => Get.to(() => const CompanyRegistrationPage()),
                                    delay: 170,
                                  );
                                }
                                return const SizedBox.shrink();
                              }),

                              _buildDrawerItem(context: context, icon: Iconsax.user_bold, title: "Profile", onTap: () => Get.toNamed('/profile'), delay: 200),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      _buildDrawerItem(context: context, icon: Iconsax.setting_2_bold, title: "Settings", onTap: () => Get.toNamed('/settings'), delay: 300),

                      Obx(() {
                        if (authController.role.value == 'admin') {
                          return _buildDrawerItem(
                            context: context,
                            icon: Iconsax.monitor_bold,
                            title: "Admin Dashboard",
                            onTap: () => Get.to(() => const AdminDashboardLayout()),
                            delay: 350,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
                _buildFooter(context, authController, themeService),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController authController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.6)],
        ),
      ),
      child: Obx(() {
        final user = authController.user.value;
        final name = user?.firstName ?? "Guest User";
        final isGuest = user == null;

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.3)),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: isGuest
                    ? const Icon(Iconsax.user_bold, size: 28, color: Colors.grey)
                    : Text(
                        name[0].toUpperCase(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isGuest ? "Welcome, Guest" : "Hello,", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDrawerItem({required BuildContext context, required IconData icon, required String title, required VoidCallback onTap, required int delay}) {
    // We can also use Theme.of(context) here if we want item colors to adapt
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.of(context).pop(); // Close drawer
          onTap();
        },
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
    ).animate().fadeIn(duration: 50.ms).slideX(begin: -0.1);
  }

  Widget _buildFooter(BuildContext context, AuthController authController, ThemeService themeService) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.w600)),
              Switch(value: isDark, activeTrackColor: AppTheme.primaryColor, onChanged: (val) => themeService.switchTheme()),
            ],
          ),
          const SizedBox(height: 20),
          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (authController.isSigned.value) {
                    await getIt<AuthServices>().logout();
                  } else {
                    Get.toNamed('/auth');
                  }
                },
                icon: Icon(authController.isSigned.value ? Iconsax.logout_bold : Iconsax.login_bold, size: 20),
                label: Text(authController.isSigned.value ? "Sign Out" : "Sign In"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: authController.isSigned.value ? Colors.red.withValues(alpha: 0.1) : AppTheme.primaryColor,
                  foregroundColor: authController.isSigned.value ? Colors.red : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 100.ms).slideY(begin: 0.1);
  }
}
