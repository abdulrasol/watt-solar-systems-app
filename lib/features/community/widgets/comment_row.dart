import 'package:flutter/material.dart';
import 'package:solar_hub/features/store/widgets/store_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentRow extends StatelessWidget {
  const CommentRow({super.key, required this.author, required this.comment});

  final dynamic author;
  final Map<String, dynamic> comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StoreImage(
          url: author?['avatar_url'],
          width: 36,
          height: 36,
          borderRadius: 18,
          fallback: const Icon(Icons.person, size: 24, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(author?['full_name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(timeago.format(DateTime.parse(comment['created_at'])), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(comment['content'] ?? '', style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
