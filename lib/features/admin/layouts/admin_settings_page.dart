import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/features/auth/services/auth_services.dart';
import 'package:solar_hub/services/localization_service.dart';
import 'package:solar_hub/services/theme_service.dart';
import 'package:solar_hub/utils/app_theme.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            _buildSectionHeader('general'.tr),
            _buildSettingsCard(
              children: [
                _buildListTile(
                  icon: Iconsax.moon_bold,
                  title: 'dark_mode'.tr,
                  trailing: Switch(value: Get.isDarkMode, onChanged: (val) => ThemeService().switchTheme(), activeTrackColor: AppTheme.primaryColor),
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Iconsax.language_circle_bold,
                  title: 'language'.tr,
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: Get.locale?.languageCode == 'ar' ? 'Arabic' : 'English',
                      dropdownColor: Theme.of(context).cardColor,
                      items: <String>['English', 'Arabic'].map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue == 'Arabic') {
                          LocalizationService().changeLocale('ar');
                        } else {
                          LocalizationService().changeLocale('en');
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader('account'.tr),
            _buildSettingsCard(
              children: [
                _buildListTile(
                  icon: Iconsax.profile_circle_bold,
                  title: 'Admin ID',
                  trailing: Text(authController.user.value?.firstName ?? "N/A", style: const TextStyle(color: Colors.grey)),
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Iconsax.logout_bold,
                  title: 'Exit Admin Mode',
                  onTap: () => Get.offAllNamed('/home'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
                const Divider(height: 1, indent: 56),
                _buildListTile(
                  icon: Iconsax.logout_bold,
                  title: 'logout'.tr,
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    Get.find<AuthServices>().logout();
                    Get.offAllNamed('/auth');
                  },
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 48),
            Center(
              child: Text("Admin Console v1.0.0", style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap, Color? titleColor, Color? iconColor}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: (iconColor ?? Theme.of(Get.context!).primaryColor).withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: iconColor ?? Theme.of(Get.context!).primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
