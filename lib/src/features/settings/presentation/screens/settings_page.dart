import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.app_preferences,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildSwitchItem(
              icon: isDark ? Iconsax.moon_bold : Iconsax.sun_1_bold,
              title: l10n.dark_mode,
              value: settings.isDark,
              onChanged: (val) =>
                  ref.read(settingsProvider.notifier).toggleDark(),
              isDark: isDark,
            ),
            if (isEnabled(ref, 'notifications'))
              _buildSwitchItem(
                icon: Iconsax.notification_bold,
                title: l10n.push_notifications,
                value: settings.isNotificationEnabled,
                onChanged: (val) =>
                    ref.read(settingsProvider.notifier).toggleNotification(),
                isDark: isDark,
              ),

            const SizedBox(height: 24),
            Text(
              l10n.localization,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildDropdownItem(
              icon: Iconsax.language_circle_bold,
              title: l10n.language,
              value: settings.language,
              items: [
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                DropdownMenuItem(value: 'ar', child: Text(l10n.arabic)),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(settingsProvider.notifier).setLanguage(val);
                }
              },
              isDark: isDark,
            ),
            if (ref.read(authProvider).isCompanyMember ||
                ref.read(authProvider).isSuperUser) ...[
              const SizedBox(height: 24),
              Text(
                l10n.startup_roles,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildSwitchItem(
                icon: Iconsax.login_1_bold,
                title: l10n.save_role_page_selection,
                subtitle: l10n.startup_role_subtitle,
                value: settings.saveRolePageSelection,
                onChanged: (val) => ref
                    .read(settingsProvider.notifier)
                    .toggleSaveRolePageSelection(),
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            : null,
        trailing: Switch(
          value: value,
          activeTrackColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: items,
            onChanged: onChanged,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
