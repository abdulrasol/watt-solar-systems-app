import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/layouts/hub/community_share/create_post_dialog.dart';
import 'package:solar_hub/layouts/hub/community_share/fake_data.dart';
import 'package:solar_hub/layouts/widgets/post_card.dart';
import 'package:solar_hub/layouts/widgets/system_card_widget.dart';

class CommunityShare extends StatefulWidget {
  const CommunityShare({super.key});

  @override
  State<CommunityShare> createState() => _CommunityShareState();
}

class _CommunityShareState extends State<CommunityShare>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int notificationCount = 1; // Initialize notification count
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- New method to show the create post dialog ---
  void _showCreatePostDialog() {
    Get.dialog(
      CreatePostDialog(
        userSystems: fakeSystems, // Pass your fake systems to the dialog
        onCreatePost: (title, content, type, selectedSystem) {
          // Here you would typically add the new post to your data source
          // For now, let's just print it and add it to fakePosts for demonstration
          final newPost = {
            'title': title,
            'user': 'Current User', // Replace with actual current user
            'type': type,
            'date': DateTime.now().toIso8601String().substring(0, 10),
            'content': content,
            'likes': 0,
            'dislikes': 0,
            'comments': [],
            'system': selectedSystem,
          };
          setState(() {
            fakePosts.add(newPost);
          });
          Get.back(); // Close the dialog
          Get.snackbar(
            'Success',
            'Post created successfully!',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
      ),
    );
  }

  // --- New: Method to handle notification icon tap ---
  void _onNotificationTap() async {
    // Navigate to the notifications screen
    // In a real app, you would navigate to a notifications screen
    await Get.toNamed('/community/notifications');
    // After returning from the notifications screen, assume all are read
    setState(() {
      notificationCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Community",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // --- New: Notification Icon Button ---
          Stack(
            children: [
              IconButton(
                icon: const Icon(IonIcons.notifications),
                onPressed: () {
                  _onNotificationTap();
                },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        centerTitle: true,
        titleSpacing: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Systems".tr),
            Tab(text: "Posts".tr),
            Tab(text: "Problems".tr), // Changed to "Problems" for consistency
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: User Systems
          ListView(
            padding: const EdgeInsets.all(12),
            children: fakeSystems
                .map((system) => systemCard(context, system))
                .toList(),
          ),
          // Tab 2: Posts
          ListView(
            padding: const EdgeInsets.all(12),
            children: fakePosts
                .where((post) => post["type"] != "issue")
                .map((post) => postCard(post))
                .toList(),
          ),
          // Tab 3: Issues
          ListView(
            padding: const EdgeInsets.all(12),
            children: fakePosts
                .where((post) => post["type"] == "issue")
                .map((post) => postCard(post))
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog, // Call the new method
        child: const Icon(Icons.add),
      ),
    );
  }
}
