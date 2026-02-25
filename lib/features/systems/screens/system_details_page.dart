import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';
import 'package:solar_hub/features/systems/screens/system_form_page.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:solar_hub/features/store/screens/company_store_page.dart';
import 'package:solar_hub/layouts/shared/widgets/system_page_info_card_widget.dart';
import 'package:solar_hub/features/community/controllers/community_controller.dart';
import 'package:solar_hub/features/community/models/community_post_model.dart';
import 'package:solar_hub/features/community/widgets/post_card.dart';
import 'package:solar_hub/features/community/widgets/create_post_sheet.dart';

class SystemDetailsPage extends StatelessWidget {
  final SystemModel system;
  final bool isCommunityView;
  final bool isCompanyView; // passed to contextually show buttons

  const SystemDetailsPage({super.key, required this.system, this.isCompanyView = false, this.isCommunityView = false});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final controller = Get.put(SystemsController());
    final communityController = Get.put(CommunityController());
    final auth = Get.find<AuthController>();

    // Using Obx to react to changes from the controller (like status updates)
    return Obx(() {
      // Try to find the latest version of this system in the lists
      SystemModel currentSystem =
          controller.mySystems.firstWhereOrNull((s) => s.id == system.id) ?? controller.companySystems.firstWhereOrNull((s) => s.id == system.id) ?? system;

      final currentUser = auth.user.value;
      final isMe = (currentSystem.userId != null && currentSystem.userId == currentUser?.id) || (currentSystem.userPhone == currentUser?.phone);

      // Status Logic
      // Only show User Actions if strictly NOT in company view
      bool canApproveUser = !isCompanyView && isMe && currentSystem.userStatus == 'pending';
      bool canApproveCompany = isCompanyView && currentSystem.companyStatus == 'pending';

      // Companies can edit systems they installed, users can edit their own systems
      bool canEdit = isMe || isCompanyView;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // 1. Graphical Header
            SliverAppBar(
              pinned: true,
              expandedHeight: 220.0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (canEdit) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                    onPressed: () => Get.to(() => SystemFormPage(system: currentSystem, isUserView: !isCompanyView, companyId: currentSystem.installedBy)),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                    onPressed: () => _confirmDelete(context, controller),
                  ),
                ],
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  currentSystem.userName ?? 'Unknown User',
                  style: const TextStyle(
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/png/cards/system.jpg', // Default illustration
                      fit: BoxFit.cover,
                    ),
                    // If we had a real photo, we would overlay it or replace it here
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Status & Info
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Indicators
                    Row(
                      children: [
                        Expanded(child: _buildStatusBadge(context, "User Status", currentSystem.userStatus, canApproveUser)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatusBadge(context, "Company Status", currentSystem.companyStatus, canApproveCompany)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Basic Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        infoRow('Date', currentSystem.createdAt?.toString().substring(0, 10) ?? 'N/A'),
                        if (currentSystem.companyName != null && currentSystem.companyName!.isNotEmpty)
                          InkWell(
                            onTap: currentSystem.installedBy != null ? () => _navigateToCompany(currentSystem.installedBy!) : null,
                            child: Row(
                              children: [
                                const Icon(Icons.store, size: 16, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  currentSystem.companyName!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Specs List
                    Text("Specifications", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    systemInfoCard(
                      context,
                      title: 'Panels',
                      image: 'assets/png/cards/panels.png',
                      children: [
                        infoRow('Power', "${currentSystem.pv.capacity} W"),
                        infoRow('Count', currentSystem.pv.count),
                        infoRow('Brand', currentSystem.pv.mark ?? 'N/A'),
                      ],
                    ),

                    systemInfoCard(
                      context,
                      title: 'Battery',
                      image: 'assets/png/cards/battery.png',
                      children: [
                        infoRow('Capacity', "${currentSystem.battery.capacity} Ah"),
                        infoRow('Count', currentSystem.battery.count),
                        infoRow('Brand', currentSystem.battery.mark ?? 'N/A'),
                      ],
                    ),

                    systemInfoCard(
                      context,
                      title: 'Inverter',
                      image: 'assets/png/cards/inverter.png',
                      children: [
                        infoRow('Size', "${currentSystem.inverter.capacity} kVA"),
                        infoRow('Brand', currentSystem.inverter.mark ?? 'N/A'),
                        if (currentSystem.inverter.phase != null) infoRow('Phase', currentSystem.inverter.phase),
                      ],
                    ),

                    if (currentSystem.notes != null && currentSystem.notes!.isNotEmpty) ...[const SizedBox(height: 12), optionalNote(currentSystem.notes)],

                    const SizedBox(height: 30),

                    // Actions
                    if (canApproveUser) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => controller.updateStatus(currentSystem.id!, userStatus: 'accepted'),
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Confirm System (User)"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (canApproveCompany) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => controller.updateStatus(currentSystem.id!, companyStatus: 'accepted'),
                          icon: const Icon(Icons.verified),
                          label: const Text("Accept Installation (Company)"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Bottom padding
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            if (isCommunityView) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(),
                      Text("Community Posts", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // Posts List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: FutureBuilder<List<CommunityPostModel>>(
                  future: communityController.fetchPostsBySystem(system.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }

                    final relatedPosts = snapshot.data ?? [];

                    if (relatedPosts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'no_posts_yet'.tr,
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) => PostCard(post: relatedPosts[index]), childCount: relatedPosts.length),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding for FAB
            ],
          ],
        ),
        floatingActionButton: isCommunityView
            ? Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    Get.bottomSheet(
                      CreatePostSheet(
                        userSystems: [
                          {...currentSystem.toJson(), 'system_name': currentSystem.userName ?? 'System', 'capacity_kw': currentSystem.inverter.capacity},
                        ],
                        onCreatePost: (content, type, systemId) {
                          communityController.createPost(content, postType: type, systemId: systemId ?? system.id);
                        },
                      ),
                      isScrollControlled: true,
                    );
                  },
                ),
              )
            : null,
      );
    });
  }

  Widget _buildStatusBadge(BuildContext context, String label, String status, bool canAction) {
    Color color = status == 'accepted' ? Colors.green : (status == 'rejected' ? Colors.red : Colors.orange);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(status == 'accepted' ? Icons.check_circle : (status == 'pending' ? Icons.access_time_filled : Icons.cancel), size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                status.capitalizeFirst!,
                style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
              ),
            ],
          ),
          if (canAction) ...[
            const SizedBox(height: 6),
            const Text(
              "Action Required",
              style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  void _navigateToCompany(String companyId) {
    Get.showOverlay(
      asyncFunction: () async {
        final controller = Get.find<SystemsController>();
        final res = await controller.fetchCompanyById(companyId);
        if (res != null) {
          Get.to(() => ShopPage(company: res));
        }
      },
      loadingWidget: const Center(child: CircularProgressIndicator()),
    );
  }

  void _confirmDelete(BuildContext context, SystemsController ctrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete System"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              final success = await ctrl.deleteSystem(system.id!);
              if (success && context.mounted) {
                // Determine if we should show a toast or snackbar safely
                // For now, safe toast or just pop
                Navigator.of(context).pop(); // Close page
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
