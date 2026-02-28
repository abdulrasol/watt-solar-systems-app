import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/community/controllers/community_controller.dart';
import 'package:solar_hub/features/community/models/community_post_model.dart';
import 'package:solar_hub/features/community/widgets/comment_row.dart';
import 'package:solar_hub/features/community/widgets/user_profile_bottom_sheet.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:solar_hub/utils/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailsPage extends StatefulWidget {
  final CommunityPostModel post;

  const PostDetailsPage({super.key, required this.post});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final CommunityController controller = Get.find<CommunityController>();
  final TextEditingController _commentController = TextEditingController();
  final RxList<Map<String, dynamic>> _comments = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    _isLoading.value = true;
    try {
      final comments = await controller.fetchComments(widget.post.id);
      _comments.assignAll(comments);
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompany = widget.post.isCompanyPost;
    final name = isCompany ? widget.post.companyName ?? 'Unknown Company' : widget.post.author?.fullName ?? 'Unknown User';
    final avatarUrl = isCompany ? widget.post.companyLogo : widget.post.author?.avatarUrl;

    return Scaffold(
      appBar: AppBar(title: Text('post_details'.tr), elevation: 0, backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchComments,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Post Details
                  InkWell(
                    onTap: () {
                      if (isCompany) {
                        Get.toNamed('/store/${widget.post.companyId}');
                      } else if (widget.post.author != null) {
                        UserProfileBottomSheet.show(context, widget.post.author!);
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'post_avatar_${widget.post.id}',
                          child: StoreImage(
                            url: avatarUrl,
                            width: 50,
                            height: 50,
                            borderRadius: 25,
                            fallback: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F7FA),
                                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                              Text(timeago.format(widget.post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.post.content != null && widget.post.content!.isNotEmpty)
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(widget.post.content!, style: const TextStyle(fontSize: 16, height: 1.6), textAlign: TextAlign.start),
                    ),
                  if (widget.post.imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Column(
                      children: widget.post.imageUrls.map((url) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: StoreImage(url: url, width: double.infinity, height: 250, fit: BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
                  Row(
                    children: [
                      Text('comments'.tr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(width: 8),
                      Obx(() => Text('(${_comments.length})', style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (_isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_comments.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(AntDesign.comment_outline, size: 48, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text('no_comments_yet'.tr, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        final author = comment['author'];
                        return CommentRow(author: author, comment: comment);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -2), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'add_comment'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _submitComment,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final success = await controller.addComment(widget.post.id, content);
    if (success && mounted) {
      _commentController.clear();
      FocusScope.of(context).unfocus();
      _fetchComments();
    }
  }
}
