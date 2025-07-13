import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/layouts/hub/community_share/fake_data.dart';
import 'package:solar_hub/layouts/widgets/post_card.dart';
import 'package:solar_hub/layouts/widgets/system_page_info_card_widget.dart';

class SystemDetailsPage extends StatefulWidget {
  const SystemDetailsPage({super.key});

  @override
  State<SystemDetailsPage> createState() => _SystemDetailsPageState();
}

class _SystemDetailsPageState extends State<SystemDetailsPage> {
  @override
  Widget build(BuildContext context) {
    List posts = [];
    Map<String, dynamic> systemData = Get.arguments;
    Future loadPosts() async {
      await Future.delayed(Duration(seconds: 5)); // Simulate network delay
      posts = fakePosts
          .where((post) => post['system_id'] == systemData['id'])
          .toList();
      return posts;
    }

    // --- New method to show the create post dialog ---
    void showCreatePostDialog() {
      Get.dialog(
        CreatePostDialog(
          userSystems: fakeSystems, // Pass your fake systems to the dialog
          onCreatePost: (title, content, type, systemData) {
            // Here you would typically add the new post to your data source
            // For now, let's just print it and add it to fakePosts for demonstration
            final newPost = {
              'post_id23'
                      'title':
                  title,
              'user': 'Current User', // Replace with actual current user
              'type': type,
              'date': DateTime.now().toIso8601String().substring(0, 10),
              'content': content,
              'likes': 0,
              'dislikes': 0,
              'comments': [],
              'system': systemData,
            };
            // systemData!['relatedPosts'].add('post_id23'); // Add post ID to system data
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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar منزلقة
          SliverAppBar(
            pinned: true,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(systemData['user_name'] ?? 'User'),
              background: Image.asset(
                'assets/png/cards/system.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // التفاصيل
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoRow('Date', systemData['installDate']),
                      if (systemData['installer'] != null &&
                          systemData['installer'].toString().isNotEmpty)
                        infoRow('Installer', systemData['installer']),
                    ],
                  ),
                  systemInfoCard(
                    context,
                    title: 'Panels',
                    image: 'assets/png/cards/panels.png',
                    children: [
                      infoRow('Power', systemData['panelPower']),
                      // infoRow('Type', systemData['panelType']),
                      infoRow('Count', systemData['panelCount']),
                      infoRow('Brand', systemData['panelBrand']),
                      optionalNote(systemData['panelNotes']),
                    ],
                  ),
                  systemInfoCard(
                    context,
                    title: 'battery',
                    image: 'assets/png/cards/battery.png',
                    children: [
                      infoRow('Voltage', systemData['batteryVoltage']),
                      infoRow('Capacity (Ah)', systemData['batteryAh']),
                      infoRow('Count', systemData['batteryCount']),
                      infoRow('Brand', systemData['batteryBrand']),
                      optionalNote(systemData['batteryNotes']),
                    ],
                  ),
                  systemInfoCard(
                    context,
                    title: 'Inverter',
                    image: 'assets/png/cards/inverter.png',
                    children: [
                      infoRow('Size (kW)', systemData['inverterSize']),
                      infoRow('Type', systemData['inverterType']),
                      infoRow('Brand', systemData['inverterBrand']),
                      optionalNote(systemData['inverterNotes']),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: const Divider(height: 32)),
                      const SizedBox(width: 4),
                      const SizedBox(width: 4),
                      Text(
                        '${systemData['relatedPosts'].length} Posts',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          //  fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // قائمة المشاركات
          SliverPadding(padding: EdgeInsets.zero),
          // التعليقات أو المنشورات
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              // Use the fake post data for demonstration
              // Map<String, dynamic> post = systemData['relatedPosts'][index];

              return FutureBuilder(
                future: loadPosts(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return shimmerPostCard;
                  }
                  if (asyncSnapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Error loading posts: ${asyncSnapshot.error}',
                      ),
                    );
                  }
                  if (asyncSnapshot.hasData && asyncSnapshot.data.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No posts available'),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: postCard(posts[index]),
                  );
                },
              );
            }, childCount: systemData['relatedPosts'].length),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showCreatePostDialog, // Call the new method
        child: const Icon(Icons.add),
      ),
    );
  }
}
// --- New Widget for Create Post Dialog ---

class CreatePostDialog extends StatefulWidget {
  final List<Map<String, dynamic>> userSystems;
  final Function(
    String title,
    String content,
    String type,
    Map<String, dynamic>? selectedSystem,
  )
  onCreatePost;

  const CreatePostDialog({
    super.key,
    required this.userSystems,
    required this.onCreatePost,
  });

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _postType = 'post'; // Default to 'post'
  Map<String, dynamic>? _selectedSystem;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Post"),
      content: SingleChildScrollView(
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _postType,
                decoration: const InputDecoration(
                  labelText: 'Post Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'post', child: Text('Post')),
                  DropdownMenuItem(value: 'issue', child: Text('Problem')),
                ],
                onChanged: (value) {
                  setState(() {
                    _postType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _contentController.text.isNotEmpty) {
              widget.onCreatePost(
                _titleController.text,
                _contentController.text,
                _postType,
                _selectedSystem,
              );
            } else {
              Get.snackbar(
                'Error',
                'Please fill in both title and content.',
                snackPosition: SnackPosition.TOP,
              );
            }
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
