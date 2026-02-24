import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/community/models/community_post_model.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:solar_hub/features/community/widgets/user_profile_bottom_sheet.dart';
import 'package:solar_hub/features/community/screens/post_details_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  final CommunityPostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Determine Author Info
    final isCompany = post.isCompanyPost;
    final name = isCompany ? post.companyName ?? 'Unknown Company' : post.author?.fullName ?? 'Unknown User';
    final avatarUrl = isCompany ? post.companyLogo : post.author?.avatarUrl;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Get.to(() => PostDetailsPage(post: post));
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Chevron (Teal)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(Icons.arrow_back_ios_new, color: Color(0xFF26C6DA), size: 18),
              ),
              const SizedBox(width: 8),

              const Spacer(),

              // Content & Info Column
              Expanded(
                flex: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Header: Flags, Name, Avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!isCompany && post.author?.phoneNumber != null)
                                Text(post.author!.phoneNumber!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              Text(timeago.format(post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Avatar
                        GestureDetector(
                          onTap: () {
                            if (isCompany) {
                              Get.toNamed('/store/${post.companyId}');
                            } else if (post.author != null) {
                              UserProfileBottomSheet.show(context, post.author!);
                            }
                          },
                          child: Hero(
                            tag: 'post_avatar_${post.id}',
                            child: StoreImage(
                              url: avatarUrl,
                              width: 45,
                              height: 45,
                              borderRadius: 22.5,
                              fallback: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F7FA),
                                  border: Border.all(color: const Color(0xFF26C6DA).withValues(alpha: 0.2)),
                                  borderRadius: BorderRadius.circular(22.5),
                                ),
                                child: Center(
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Color(0xFF00ACC1), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Linked System Badge (Optional)
                    if (post.linkedSystemName != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.solar_power_outlined, size: 14, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${post.linkedSystemName} (${post.linkedSystemCapacity}kW)',
                                style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Post Content
                    if (post.content != null && post.content!.isNotEmpty)
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          post.content!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                          textAlign: TextAlign.start,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Images (Centered, Clickable)
                    if (post.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: post.imageUrls.map((url) {
                            return GestureDetector(
                              onTap: () => _openFullscreenImage(url),
                              child: StoreImage(
                                url: url,
                                width: post.imageUrls.length == 1 ? 250 : 100,
                                height: post.imageUrls.length == 1 ? 180 : 100,
                                borderRadius: 12,
                                fit: BoxFit.cover,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Footer: Comments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Flags in Footer
                        if (post.postType == 'issue')
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'issue_flag'.tr,
                              style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (isCompany)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              'official_flag'.tr,
                              style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Get.to(() => PostDetailsPage(post: post)),
                          child: const Icon(AntDesign.comment_outline, size: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openFullscreenImage(String url) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: StoreImage(url: url, width: double.infinity, fit: BoxFit.contain),
          ),
        ),
      ),
      fullscreenDialog: true,
    );
  }
}
