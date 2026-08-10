import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_provider.dart';
import '../../../data/models/api_models/community_models.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/widgets/shimmer_placeholders.dart';
/// Community screen — shared between farmer & instructor roles.
class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityPostsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Community', style: Theme.of(context).textTheme.displaySmall),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post creation coming soon!')),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const Center(
                        child: Text('No community posts yet.'),
                      );
                    }
                    return ListView.separated(
                      itemCount: posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _PostCard(
                          post: post,
                          onLike: () async {
                            final success = await ref.read(communityPostsProvider.notifier).toggleLike(post.id);
                            if (context.mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to like post. Backend might be unavailable.')),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                  loading: () => ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) => const _ShimmerPostCard(),
                  ),
                  error: (err, st) => Center(
                    child: Text(
                      err.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerPostCard extends StatelessWidget {
  const _ShimmerPostCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerContainer(width: 40, height: 40, borderRadius: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerContainer(width: 120, height: 14),
                    SizedBox(height: 6),
                    ShimmerContainer(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          ShimmerContainer(width: double.infinity, height: 14),
          SizedBox(height: 6),
          ShimmerContainer(width: double.infinity, height: 14),
          SizedBox(height: 6),
          ShimmerContainer(width: 150, height: 14),
          SizedBox(height: 14),
          Row(
            children: [
              ShimmerContainer(width: 40, height: 14),
              SizedBox(width: 20),
              ShimmerContainer(width: 40, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}


class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.onLike,
  });

  final CommunityPost post;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final author = post.author.fullName;
    final isExpert = post.author.isExpert;
    final time = timeago.format(post.createdAt);
    final avatarUrl = post.author.avatarUrl;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isExpert
                    ? AppColors.accentOrange.withValues(alpha: 0.15)
                    : AppColors.primaryGreen.withValues(alpha: 0.15),
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Icon(
                        isExpert ? Icons.verified_rounded : Icons.person_rounded,
                        color: isExpert ? AppColors.accentOrange : AppColors.primaryGreen,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(author, style: Theme.of(context).textTheme.titleSmall),
                        if (isExpert) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 14, color: AppColors.accentOrange),
                        ],
                      ],
                    ),
                    Text(time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft)),
                  ],
                ),
              ),
              if (post.tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.tag,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.primaryGreen,),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: onLike,
                child: Row(
                  children: [
                    Icon(
                      post.isLikedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18,
                      color: post.isLikedByMe ? Colors.red : AppColors.inkSoft,
                    ),
                    const SizedBox(width: 4),
                    Text('${post.likesCount}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comments section coming soon!')),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 18, color: AppColors.inkSoft),
                    const SizedBox(width: 4),
                    Text('${post.commentsCount}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
                child: Icon(Icons.share_outlined, size: 18, color: AppColors.inkSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

