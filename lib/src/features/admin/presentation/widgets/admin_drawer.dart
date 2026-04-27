import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/app_constants.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E2C).withValues(alpha: 0.97)
            : Colors.white.withValues(alpha: 0.98),
      ),
      child: Column(
        children: [
          _buildHeader(context, authState),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: FontAwesomeIcons.solidBuilding,
                  title: AppLocalizations.of(context)!.dashboard,
                  onTap: () => _closeIfDrawer(context),
                  delay: 100,
                  isActive: true,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.message_circle_bold,
                  title: AppLocalizations.of(context)!.user_feedbacks,
                  onTap: () {
                    _closeIfDrawer(context);
                    context.go('/admin/feedbacks');
                  },
                  delay: 150,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.setting_2_bold,
                  title: 'App Configurations',
                  onTap: () {
                    _closeIfDrawer(context);
                    context.go('/admin/configs');
                  },
                  delay: 180,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.shop_bold,
                  title: 'Marketplace Oversight',
                  onTap: () {
                    _closeIfDrawer(context);
                    context.push('/admin-marketplace');
                  },
                  delay: 190,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.building_bold,
                  title: 'Manage Companies',
                  onTap: () {
                    _closeIfDrawer(context);
                    context.go('/admin/companies');
                  },
                  delay: 200,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.gallery_edit_bold,
                  title: 'Service Types',
                  onTap: () {
                    _closeIfDrawer(context);
                    context.go('/admin/service-types');
                  },
                  delay: 205,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.category_2_bold,
                  title: 'Service Catalog',
                  onTap: () {
                    _closeIfDrawer(context);
                    context.go('/admin/service-catalog');
                  },
                  delay: 210,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.briefcase_bold,
                  title: 'Service Requests',
                  onTap: () {
                    _closeIfDrawer(context);
                    context.go('/admin/service-requests');
                  },
                  delay: 220,
                ),
                const SizedBox(height: 16),
                Text(
                  'Switch Dashboard',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.home_2_bold,
                  title: AppLocalizations.of(context)!.home,
                  onTap: () {
                    if (!embedded) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                    context.go('/home');
                  },
                  delay: 200,
                ),
                if (authState.isCompanyMember)
                  _buildDrawerItem(
                    context: context,
                    icon: Iconsax.building_bold,
                    title:
                        authState.company?.name ??
                        AppLocalizations.of(context)!.company_dashboard,
                    onTap: () {
                      if (!embedded) {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                      context.go('/companies/dashboard');
                    },
                    delay: 250,
                  ),
                const SizedBox(height: 16),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.setting_2_bold,
                  title: AppLocalizations.of(context)!.settings,
                  route: '/settings',
                  delay: 300,
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Iconsax.message_text_bold,
                  title: AppLocalizations.of(context)!.send_feedback,
                  onTap: () async {
                    _closeIfDrawer(context);
                    context.push('/feedback');
                  },
                  delay: 350,
                ),
                _buildFooter(context, authState, ref, isDark),
              ],
            ),
          ),
        ],
      ),
    );

    if (embedded) return content;
    return Drawer(backgroundColor: Colors.transparent, child: content);
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    final user = authState.user;
    final name = user?.firstName ?? AppLocalizations.of(context)!.guest_user;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.r),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.3),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.white,
                child: user == null || user.image == null || user.image!.isEmpty
                    ? const Icon(
                        Icons.admin_panel_settings,
                        size: 28,
                        color: AppTheme.primaryColor,
                      )
                    : WdImagePreview(imageUrl: user.image!),
              ),
            ),
            horSpace(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.verify_bold,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    horSpace(),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int delay,
    VoidCallback? onTap,
    String? route,
    bool isActive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(
              alpha: isActive ? 0.2 : 0.1,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            fontFamily: AppTheme.fontFamily,
            color: isActive
                ? AppTheme.primaryColor
                : (isDark ? Colors.white : Colors.black87),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isActive
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.check_bold,
                  color: Colors.white,
                  size: 12,
                ),
              )
            : const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey,
              ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          if (onTap != null) onTap();
          if (route != null) context.push(route);
        },
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      ),
    ).animate().fadeIn(duration: 50.ms).slideX(begin: -0.1);
  }

  Widget _buildFooter(
    BuildContext context,
    AuthState authState,
    WidgetRef ref,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dark Mode',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                ),
              ),
              Switch(
                value: isDark,
                activeTrackColor: AppTheme.primaryColor,
                onChanged: (val) =>
                    ref.read(settingsProvider.notifier).toggleDark(),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                _closeIfDrawer(context);
                if (authState.isSigned) {
                  await getIt<AuthRepository>().logout();
                  ref.read(authProvider.notifier).logout();
                } else {
                  context.go('/auth');
                }
              },
              icon: Icon(
                authState.isSigned ? Iconsax.logout_bold : Iconsax.login_bold,
                size: 20,
              ),
              label: Text(
                authState.isSigned
                    ? AppLocalizations.of(context)!.sign_out
                    : AppLocalizations.of(context)!.sign_in,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: authState.isSigned
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppTheme.primaryColor,
                foregroundColor: authState.isSigned ? Colors.red : Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 100.ms).slideY(begin: 0.1);
  }

  void _closeIfDrawer(BuildContext context) {
    if (!embedded) {
      Navigator.of(context).pop();
    }
  }
}
