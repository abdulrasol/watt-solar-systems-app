import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:solar_hub/models/post_model.dart';

Widget postCard(PostModel post) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    decoration: BoxDecoration(
      color: Get.isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: InkWell(
      onTap: () {
        Get.toNamed('/community/post', arguments: post);
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Hero(
                  tag: 'avatar_${post.id}',
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(Get.context!).primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      post.userName?.isNotEmpty == true ? post.userName![0].toUpperCase() : '?',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(Get.context!).primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.userName ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      if (post.userPhone != null && post.userPhone!.isNotEmpty)
                        Text(
                          post.userPhone!,
                          style: TextStyle(color: Colors.grey[800], fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      Text(post.createdAt.toString().substring(0, 10), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                if (post.postType == 'issue')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text(
                      'Issue',
                      style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Content Preview
            Text(
              post.content,
              style: TextStyle(color: Colors.grey[700], height: 1.4, fontSize: 16, fontWeight: FontWeight.w500),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Footer (Interactions)
            Row(
              children: [
                Icon(Iconsax.message_text_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text("${post.comments.length} Comments", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const Spacer(),
                Icon(Iconsax.arrow_right_3_outline, size: 18, color: Theme.of(Get.context!).primaryColor),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

final shimmerPostCard = Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 100, height: 12, color: Colors.white),
                const SizedBox(height: 4),
                Container(width: 60, height: 10, color: Colors.white),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(width: double.infinity, height: 16, color: Colors.white),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 12, color: Colors.white),
        const SizedBox(height: 4),
        Container(width: 200, height: 12, color: Colors.white),
      ],
    ),
  ),
);
