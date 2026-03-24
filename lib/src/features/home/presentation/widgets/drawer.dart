import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/feedback/presentation/screens/feedback_page.dart';
import 'package:solar_hub/src/features/admin/presentation/screen/admin_dashboard.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart' show isEnabled;
import 'package:solar_hub/src/features/calculations/presentation/screens/calculated_systems_page.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
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
                _buildHeader(context, authState),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (authState.isSigned) ...[
                        Column(
                          children: [
                            _buildDrawerItem(
                              context: context,
                              icon: Iconsax.user_bold,
                              title: AppLocalizations.of(context)!.profile,
                              route: '/auth/profile',
                              delay: 100,
                            ),
                          ],
                        ),
                        _buildDrawerItem(
                          context: context,
                          icon: Iconsax.home_2_bold,
                          title: AppLocalizations.of(context)!.my_systems,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const CalculatedSystemsPage()));
                          },
                          delay: 100,
                        ),
                        _buildDrawerItem(
                          context: context,
                          icon: Iconsax.clipboard_bold,
                          title: AppLocalizations.of(context)!.my_requests,
                          route: '/my_requests',
                          delay: 100,
                        ),
                        _buildDrawerItem(
                          context: context,
                          icon: Iconsax.shopping_cart_bold,
                          title: AppLocalizations.of(context)!.my_orders,
                          route: '/my_orders',
                          delay: 100,
                        ),
                      ],

                      if (authState.isCompanyMember)
                        Column(
                          children: [
                            _buildDrawerItem(
                              context: context,
                              icon: Iconsax.building_bold,
                              title: authState.company?.name ?? AppLocalizations.of(context)!.company_dashboard,
                              route: '/company/dashboard',
                              delay: 100,
                            ),
                          ],
                        )
                      else if (authState.isSuperUser)
                        Column(
                          children: [
                            _buildDrawerItem(
                              context: context,
                              icon: EvaIcons.code,
                              title: AppLocalizations.of(context)!.admin_dashboard,
                              onTap: () {
                                // Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
                              },
                              delay: 100,
                            ),
                          ],
                        )
                      else if (isEnabled(ref, 'auth', skipFalseIfDebug: true) && isEnabled(ref, 'company_registration', skipFalseIfDebug: true))
                        _buildDrawerItem(
                          context: context,
                          icon: Iconsax.building_3_bold,
                          title: AppLocalizations.of(context)!.register_company,
                          route: '/auth/company_registration',
                          delay: 170,
                        ),

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
                          Navigator.of(context).pop(); // Close drawer first
                          await Navigator.push(context, MaterialPageRoute(builder: (c) => const FeedbackPage()));
                        },
                        delay: 350,
                      ),

                      _buildFooter(context, authState, ref),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    final user = authState.user;
    final name = user?.firstName ?? AppLocalizations.of(context)!.guest_user;
    final isGuest = user == null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.6)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.3)),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: isGuest || user.image == null || user.image!.isEmpty
                  ? const Icon(Iconsax.user_bold, size: 28, color: Colors.grey)
                  : WdImagePreview(imageUrl: user.image!),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? AppLocalizations.of(context)!.welcome_guest : AppLocalizations.of(context)!.hello,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
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
  }) {
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
          // Navigator.of(context).pop(); // Close drawer
          if (onTap != null) onTap();
          if (route != null) context.push(route);
        },
        splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
    ).animate().fadeIn(duration: 50.ms).slideX(begin: -0.1);
  }

  Widget _buildFooter(BuildContext context, AuthState authState, WidgetRef ref) {
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
              Text(AppLocalizations.of(context)!.dark_mode, style: const TextStyle(fontWeight: FontWeight.w600)),
              Switch(value: isDark, activeTrackColor: AppTheme.primaryColor, onChanged: (val) => ref.read(settingsProvider.notifier).toggleDark()),
            ],
          ),
          SizedBox(height: 20.h),
          if (isEnabled(ref, 'auth', skipFalseIfDebug: true))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (authState.isSigned) {
                    await getIt<AuthRepository>().logout();
                    ref.read(authProvider.notifier).logout();
                  } else {
                    context.go('/auth');
                  }
                },
                icon: Icon(authState.isSigned ? Iconsax.logout_bold : Iconsax.login_bold, size: 20),
                label: Text(authState.isSigned ? AppLocalizations.of(context)!.sign_out : AppLocalizations.of(context)!.sign_in),
                style: ElevatedButton.styleFrom(
                  backgroundColor: authState.isSigned ? Colors.red.withValues(alpha: 0.1) : AppTheme.primaryColor,
                  foregroundColor: authState.isSigned ? Colors.red : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 100.ms).slideY(begin: 0.1);
  }
}
