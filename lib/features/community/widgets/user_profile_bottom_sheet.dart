import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/profile/models/profile_model.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:solar_hub/features/community/controllers/community_controller.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';
import 'package:solar_hub/features/community/widgets/post_card.dart';
import 'package:solar_hub/features/systems/widgets/system_card.dart';
import 'package:solar_hub/features/community/models/community_post_model.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';

class UserProfileBottomSheet extends StatefulWidget {
  final ProfileModel user;

  const UserProfileBottomSheet({super.key, required this.user});

  static void show(BuildContext context, ProfileModel user) {
    Get.bottomSheet(
      UserProfileBottomSheet(user: user),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    );
  }

  @override
  State<UserProfileBottomSheet> createState() => _UserProfileBottomSheetState();
}

class _UserProfileBottomSheetState extends State<UserProfileBottomSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommunityController communityController = Get.find<CommunityController>();
  final SystemsController systemsController = Get.isRegistered<SystemsController>() ? Get.find<SystemsController>() : Get.put(SystemsController());

  List<CommunityPostModel> userPosts = [];
  List<SystemModel> userSystems = [];
  bool isLoadingPosts = true;
  bool isLoadingSystems = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _fetchPosts();
    _fetchSystems();
  }

  Future<void> _fetchPosts() async {
    final posts = await communityController.fetchPostsByUser(widget.user.id);
    if (mounted) {
      setState(() {
        userPosts = posts;
        isLoadingPosts = false;
      });
    }
  }

  Future<void> _fetchSystems() async {
    final systems = await systemsController.fetchSystemsUnified(type: SystemFilterType.user, id: widget.user.id);
    if (mounted) {
      setState(() {
        userSystems = systems;
        isLoadingSystems = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            StoreImage(url: widget.user.avatarUrl, width: 90, height: 90, borderRadius: 45),
            const SizedBox(height: 16),
            Text(widget.user.fullName ?? 'Unknown', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE0F7FA), borderRadius: BorderRadius.circular(12)),
              child: Text(
                widget.user.role.toUpperCase(),
                style: const TextStyle(color: Color(0xFF00ACC1), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00ACC1),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF00ACC1),
              tabs: [
                Tab(text: 'info'.tr, icon: const Icon(Icons.info_outline)),
                Tab(text: 'posts'.tr, icon: const Icon(Icons.history)),
                Tab(text: 'systems'.tr, icon: const Icon(Icons.solar_power_outlined)),
              ],
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: [_buildInfoTab(), _buildPostsTab(scrollController), _buildSystemsTab(scrollController)]),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (widget.user.phoneNumber != null)
            ListTile(
              leading: const Icon(Icons.phone_outlined, color: Colors.grey),
              title: Text(widget.user.phoneNumber!),
              subtitle: Text('phone_number'.tr),
            ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(ScrollController scrollController) {
    if (isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userPosts.isEmpty) {
      return Center(
        child: Text('no_posts_yet'.tr, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: userPosts.length,
      itemBuilder: (context, index) => PostCard(post: userPosts[index]),
    );
  }

  Widget _buildSystemsTab(ScrollController scrollController) {
    if (isLoadingSystems) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userSystems.isEmpty) {
      return Center(
        child: Text('no_systems_yet'.tr, style: const TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: userSystems.length,
      itemBuilder: (context, index) => SystemCard(system: userSystems[index]),
    );
  }
}
