import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authProvider);
    final user = authController.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
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
        actions: [
          if (authController.isSigned)
            IconButton(
              icon: const Icon(Iconsax.edit_2_bold),
              onPressed: () async {
                final result = await context.push('/auth/edit_profile');
                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                  );
                  // Refresh profile data
                  //  profileController.fetchProfile(user?.id ?? '');
                }
              },
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: (user?.image == null || user!.image!.isEmpty)
                          ? Text(
                              (user?.firstName != null && user!.firstName!.isNotEmpty)
                                  ? user.firstName![0].toUpperCase()
                                  : (user?.email != null && user!.email!.isNotEmpty)
                                  ? user.email![0].toUpperCase()
                                  : 'S',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                            )
                          : WdImagePreview(imageUrl: user.image!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Name and Phone
            Column(
              children: [
                Text(
                  user?.firstName ?? user?.email ?? AppLocalizations.of(context)!.guest_user,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (user?.phone != null && user!.phone!.isNotEmpty) Text(user.phone!, style: TextStyle(color: Colors.grey[600])),
                if (user?.id != null) Text('ID: ${user?.id}...', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 32),

            //   _buildProfileItem(icon: Iconsax.box_bold, title: 'My Orders', onTap: () => Get.toNamed('/my-orders')),
            //   _buildProfileItem(icon: Iconsax.setting_2_bold, title: 'My Systems', onTap: () => Get.toNamed('/my-systems')),
            //   _buildProfileItem(icon: Iconsax.setting_4_bold, title: 'Settings', onTap: () => Get.toNamed('/settings')),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("My Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            // Obx(() {
            //   final myPosts = dataController.posts.where((p) => p.userId == user?.id).toList();
            //   if (myPosts.isEmpty) {
            //     return Container(
            //       padding: const EdgeInsets.all(16),
            //       decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            //       child: const Center(child: Text("You haven't posted anything yet.")),
            //     );
            //   }
            //   return Column(
            //     children: myPosts
            //         .map(
            //           (post) => Container(
            //             margin: const EdgeInsets.only(bottom: 12),
            //             padding: const EdgeInsets.all(12),
            //             decoration: BoxDecoration(
            //               color: isDark ? Colors.grey[900] : Colors.white,
            //               borderRadius: BorderRadius.circular(12),
            //               boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
            //             ),
            //             child: ListTile(
            //               title: Text(post.content, maxLines: 1, overflow: TextOverflow.ellipsis),
            //               subtitle: Text(post.createdAt.toString().substring(0, 10), style: const TextStyle(fontSize: 12)),
            //               leading: const Icon(Iconsax.document_text_bold),
            //             ),
            //           ),
            //         )
            //         .toList(),
            //   );
            // }),
            const SizedBox(height: 24),
            if (authController.isSigned) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await getIt<AuthRepository>().logout();
                    ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/home');
                  },
                  icon: const Icon(Iconsax.logout_bold),
                  label: Text(AppLocalizations.of(context)!.sign_out),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    //  Get.toNamed('/auth');
                  },
                  icon: const Icon(Iconsax.login_bold),
                  label: Text(AppLocalizations.of(context)!.sign_in),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({required IconData icon, required String title, required VoidCallback onTap, String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
