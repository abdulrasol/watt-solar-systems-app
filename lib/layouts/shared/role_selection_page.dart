import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/controllers/auth_controller.dart';
import 'package:solar_hub/controllers/company_controller.dart';
import 'package:solar_hub/core/cashe/cashe_interface.dart';
import 'package:solar_hub/core/di/get_it.dart';
import 'package:solar_hub/utils/app_theme.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  // Controllers (Data should be loaded by Splash)
  final companyController = Get.find<CompanyController>();
  final authController = Get.find<AuthController>();
  final CasheInterface casheService = getIt<CasheInterface>();

  bool saveMyChoies = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    // Using Obx to listen to changes mainly for the Admin role check,
    // but variables inside build won't auto-update unless inside Obx builder.
    // However, usually these are static at this point.
    // We'll wrap the main content in Obx to be safe and responsive.

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            final userName = authController.user.value?.email ?? 'User';
            final companyName = companyController.company.value?.name ?? 'My Company';
            final isAdmin = authController.role.value == 'admin';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose how you want to continue",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Option 1: Solar Hub (User View)
                _buildRoleCard(
                  context,
                  title: "Solar Hub",
                  subtitle: "Continue as $userName",
                  icon: Icons.person_outline,
                  color: Colors.blue,
                  routeName: '/home',
                  casheName: 'user',
                ),

                const SizedBox(height: 20),

                // Option 2: Company Dashboard
                _buildRoleCard(
                  context,
                  title: companyName,
                  subtitle: "Company Dashboard",
                  icon: Iconsax.building_bold,
                  color: Colors.orange,
                  routeName: '/company_dashboard',
                  casheName: 'company',
                ),

                if (isAdmin) ...[
                  const SizedBox(height: 20),
                  _buildRoleCard(
                    context,
                    title: "Admin Dashboard",
                    subtitle: "Platform Management",
                    icon: Iconsax.security_safe_bold,
                    color: Colors.redAccent,
                    routeName: 'admin_dashboard',
                    casheName: 'admin',
                  ),
                ],
                const SizedBox(height: 40),
                ListTile(
                  title: Text('Save role page selection'.tr),
                  trailing: Switch(
                    value: getIt<CasheInterface>().get('save-role-page-selection') ?? false,
                    onChanged: (val) {
                      getIt<CasheInterface>().save('save-role-page-selection', val);
                      setState(() {
                        saveMyChoies = val;
                      });
                    },
                    activeTrackColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String routeName,
    required String casheName,
  }) {
    return GestureDetector(
      onTap: () {
        if (saveMyChoies) {
          casheService.save('save-role-page-selection-route', casheName);
          debugPrint('route myChoies: $routeName');
          debugPrint('cash myChoies: $casheName');
          debugPrint('cashed myChoies: ${casheService.get('save-role-page-selection-route')}');
        }
        Get.offAllNamed(routeName);
      },
      child: Container(
        // Constrain height or let it be flexible.
        // A minimum height ensures consistency.
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        // constraints: const BoxConstraints(minHeight: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600]),
                    overflow: TextOverflow.visible,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
