import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:watt/src/utils/helper_methods.dart';
import 'package:watt/src/core/widgets/branded_empty_state.dart';
import 'package:watt/src/core/widgets/loading_widgets.dart';
import 'package:watt/src/features/community/presentation/providers/community_providers.dart';
import 'package:watt/src/features/community/presentation/screens/create_post_screen.dart';

class CommunityFeedScreen extends ConsumerStatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  ConsumerState<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends ConsumerState<CommunityFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(communityPostsProvider(1));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const BrandedEmptyState(
              icon: Iconsax.message_text,
              title: 'No Posts Yet',
              subtitle: 'Be the first to share something with the community!',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(communityPostsProvider(1));
              await ref.read(communityPostsProvider(1).future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 16, bottom: 100),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: post.authorInfo.image != null 
                                ? CachedNetworkImageProvider(resolveImageUrl(post.authorInfo.image)!) 
                                : null,
                              child: post.authorInfo.image == null ? const Icon(Iconsax.user) : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(post.authorInfo.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    post.createdAt.toString(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (post.content != null && post.content!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(post.content!),
                        ],
                        if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: resolveImageUrl(post.imageUrl) ?? '',
                              errorWidget: (context, url, error) => const SizedBox(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Iconsax.heart, size: 20),
                            const SizedBox(width: 4),
                            Text('${post.likesCount}'),
                            const SizedBox(width: 16),
                            const Icon(Iconsax.message, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => Center(child: LoadingWidget.widget(context: context)),
        error: (error, stackTrace) => Center(child: Text(error.toString())),
      ),
    );
  }
}
