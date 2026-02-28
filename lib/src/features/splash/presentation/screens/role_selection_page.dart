import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/settings/presentation/providers/settings_provider.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  // Controllers (Data should be loaded by Splash)
  final CasheInterface casheService = getIt<CasheInterface>();

  bool saveMyChoies = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.firstName ?? 'User';
    final isAdmin = authState.user?.isSuperUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
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

                image: authState.user?.image,
              ),

              const SizedBox(height: 20),

              // Option 2: Company Dashboard
              _buildRoleCard(
                context,
                title: authState.user?.company?.name ?? 'Company',
                subtitle: "Company Dashboard",
                icon: Iconsax.building_bold,
                color: Colors.orange,
                routeName: '/company_dashboard',
                image: authState.user?.company?.logo,
              ),
              if (isAdmin ?? false) ...[
                const SizedBox(height: 20),
                _buildRoleCard(
                  context,
                  title: "Admin Dashboard",
                  subtitle: "Platform Management",
                  icon: Iconsax.security_safe_bold,
                  color: Colors.redAccent,
                  routeName: '/admin_dashboard',
                ),
              ],
              const SizedBox(height: 40),
              ListTile(
                title: Text('Save role page selection'), // TODO: add translation
                trailing: Switch(
                  value: ref.watch(settingsProvider).saveRolePageSelection,
                  onChanged: (val) {
                    ref.read(settingsProvider.notifier).toggleSaveRolePageSelection();
                    setState(() {
                      saveMyChoies = val;
                    });
                  },
                  activeTrackColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    String? image,
    required Color color,
    required String routeName,
  }) {
    return GestureDetector(
      onTap: () {
        if (saveMyChoies) {
          ref.read(settingsProvider.notifier).setSaveRolePageSelectionRoute(routeName);
        }
        context.go(routeName);
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
              padding: EdgeInsets.all(image != null ? 5.r : 20.r),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: image != null ? WdImagePreview(imageUrl: image, size: 60, shape: BoxShape.circle) : Icon(icon, size: 40, color: color),
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
