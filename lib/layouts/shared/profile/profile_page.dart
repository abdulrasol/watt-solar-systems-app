import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:solar_hub/controllers/data_controller.dart';
import 'package:solar_hub/controllers/auth_controller.dart';
import 'package:solar_hub/features/profile/controllers/profile_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final dataController = Get.put(DataController());
    final profileController = Get.put(ProfileController());
    final user = authController.user.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (authController.isSignedIn)
            IconButton(
              icon: const Icon(Iconsax.edit_2_bold),
              onPressed: () async {
                final result = await Get.toNamed('/profile/edit');
                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                  );
                  // Refresh profile data
                  profileController.fetchProfile(user?.id ?? '');
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
              child: Obx(() {
                final profile = profileController.currentProfile.value;
                return Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty) ? CachedNetworkImageProvider(profile.avatarUrl!) : null,
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: (profile?.avatarUrl == null || profile!.avatarUrl!.isEmpty)
                            ? Text(
                                (profile?.fullName?.isNotEmpty == true)
                                    ? profile!.fullName![0].toUpperCase()
                                    : (user?.email?.isNotEmpty == true)
                                    ? user!.email![0].toUpperCase()
                                    : 'G',
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
            // Name and Phone
            Obx(() {
              final profile = profileController.currentProfile.value;
              return Column(
                children: [
                  Text(profile?.fullName ?? user?.email ?? 'Guest User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (profile?.phoneNumber != null && profile!.phoneNumber!.isNotEmpty) Text(profile.phoneNumber!, style: TextStyle(color: Colors.grey[600])),
                  if (user?.id != null) Text('ID: ${user?.id.substring(0, 8)}...', style: TextStyle(color: Colors.grey[600])),
                ],
              );
            }),
            const SizedBox(height: 32),
            _buildProfileItem(icon: Iconsax.box_bold, title: 'My Orders', onTap: () => Get.toNamed('/my-orders')),
            _buildProfileItem(icon: Iconsax.setting_2_bold, title: 'My Systems', onTap: () => Get.toNamed('/my-systems')),
            _buildProfileItem(icon: Iconsax.setting_4_bold, title: 'Settings', onTap: () => Get.toNamed('/settings')),

            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("My Posts", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            Obx(() {
              final myPosts = dataController.posts.where((p) => p.userId == user?.id).toList();
              if (myPosts.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: isDark ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Text("You haven't posted anything yet.")),
                );
              }
              return Column(
                children: myPosts
                    .map(
                      (post) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                        ),
                        child: ListTile(
                          title: Text(post.content, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(post.createdAt.toString().substring(0, 10), style: const TextStyle(fontSize: 12)),
                          leading: const Icon(Iconsax.document_text_bold),
                        ),
                      ),
                    )
                    .toList(),
              );
            }),
            const SizedBox(height: 24),
            if (authController.isSignedIn) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await authController.logOut();
                    Get.offAllNamed('/home');
                  },
                  icon: const Icon(Iconsax.logout_bold),
                  label: const Text('Sign Out'),
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
                    Get.toNamed('/auth');
                  },
                  icon: const Icon(Iconsax.login_bold),
                  label: const Text('Sign In'),
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
        color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
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
