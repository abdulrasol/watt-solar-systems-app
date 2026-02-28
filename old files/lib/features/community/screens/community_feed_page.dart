import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/community/controllers/community_controller.dart';
import 'package:solar_hub/features/community/widgets/post_card.dart';
import 'package:solar_hub/features/community/widgets/create_post_sheet.dart';
import 'package:solar_hub/features/community/widgets/system_details_bottom_sheet.dart';
import 'package:solar_hub/features/systems/widgets/system_card.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  late final CommunityController controller;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(CommunityController()); // Initialize here

    // Pagination Listener
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        controller.fetchPosts();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'posts'.tr),
              Tab(text: 'systems'.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Posts Tab
            RefreshIndicator(
              onRefresh: () => controller.fetchPosts(refresh: true),
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.posts.isEmpty) return Center(child: Text('no_more_posts'.tr));

                return ListView.separated(
                  controller: scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.posts.length + 1,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == controller.posts.length) {
                      return controller.isMoreLoading.value
                          ? const Center(
                              child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 80);
                    }
                    return PostCard(post: controller.posts[index]);
                  },
                );
              }),
            ),

            // Systems Tab
            RefreshIndicator(
              onRefresh: () => controller.fetchPublicSystems(refresh: true),
              child: Obx(() {
                if (controller.isLoadingSystems.value) return const Center(child: CircularProgressIndicator());
                if (controller.publicSystems.isEmpty) return Center(child: Text('no_systems_found'.tr));

                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.publicSystems.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final system = controller.publicSystems[index];
                    return SystemCard(system: system, onTap: () => SystemDetailsBottomSheet.show(context, system));
                  },
                );
              }),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Get.bottomSheet(const CreatePostSheet(), isScrollControlled: true, backgroundColor: Colors.transparent);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
