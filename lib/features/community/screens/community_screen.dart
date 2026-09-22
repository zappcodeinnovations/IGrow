import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';

import '../../../core/router/route_names.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';

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
                      context.push(RouteNames.createPost);
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
                      return RefreshIndicator(
                        color: AppColors.primaryGreen,
                        onRefresh: () async {
                          await ref.read(communityPostsProvider.notifier).refreshPosts();
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.forum_outlined,
                                    size: 56,
                                    color: AppColors.inkSoft,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No community posts yet.',
                                    style: TextStyle(
                                      color: AppColors.inkSoft,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Tap the + button to share the first post!',
                                    style: TextStyle(
                                      color: AppColors.inkSoft,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: AppColors.primaryGreen,
                      onRefresh: () async {
                        await ref.read(communityPostsProvider.notifier).refreshPosts();
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: posts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return _PostCard(
                            post: post,
                            onLike: () async {
                              final success = await ref
                                  .read(communityPostsProvider.notifier)
                                  .toggleLike(post.id);
                              if (context.mounted && !success) {
                                final messenger = ScaffoldMessenger.of(context);
                                messenger.clearSnackBars();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to like post. Please check connection.'),
                                    duration: Duration(milliseconds: 1800),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) => const _ShimmerPostCard(),
                  ),
                  error: (err, st) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            ref.read(communityPostsProvider.notifier).refreshPosts();
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
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

class _PostCard extends ConsumerWidget {
  const _PostCard({
    required this.post,
    required this.onLike,
  });

  final CommunityPost post;
  final VoidCallback onLike;

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final success = await ref
                  .read(communityPostsProvider.notifier)
                  .deletePost(post.id);
              if (context.mounted) {
                final messenger = ScaffoldMessenger.of(context);
                messenger.clearSnackBars();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Post deleted successfully.'
                          : 'Failed to delete post. Please try again.',
                    ),
                    backgroundColor:
                        success ? AppColors.primaryGreen : AppColors.error,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final author = post.author.fullName;
    final isExpert = post.author.isExpert;
    final time = timeago.format(post.createdAt);
    final avatarUrl = post.author.avatarUrl;

    final currentUser = ref.watch(authProvider).user;
    final currentUserId = currentUser?.id.toString().trim().toLowerCase() ?? '';
    final currentUserName = currentUser?.fullName.trim().toLowerCase() ?? '';
    final currentUserEmail = currentUser?.email.trim().toLowerCase() ?? '';
    final authorId = post.author.id.trim().toLowerCase();
    final authorName = post.author.fullName.trim().toLowerCase();

    // Permissive author check: ID, fullName, email prefix, admin, or instructor
    final isAuthor = (currentUserId.isNotEmpty && authorId.isNotEmpty && authorId == currentUserId) ||
        (currentUserName.isNotEmpty && authorName.isNotEmpty && (authorName == currentUserName || authorName.contains(currentUserName) || currentUserName.contains(authorName))) ||
        (currentUserEmail.isNotEmpty && (currentUserEmail.startsWith(authorName) || authorName.contains(currentUserEmail.split('@').first))) ||
        (currentUser?.isAdmin == true) ||
        (currentUser?.isInstructor == true);

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
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.inkSoft),
                    ),
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                  ),
                ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: AppColors.inkSoft),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Post Options',
                onSelected: (value) {
                  if (value == 'delete') {
                    _confirmDelete(context, ref);
                  } else if (value == 'share') {
                    _sharePost(context, post);
                  }
                },
                itemBuilder: (context) => [
                  if (isAuthor)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              color: AppColors.error, size: 18),
                          SizedBox(width: 8),
                          Text('Delete Post',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share_outlined, size: 18, color: AppColors.inkSoft),
                        SizedBox(width: 8),
                        Text('Share', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (post.title.isNotEmpty) ...[
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (post.image != null && post.image!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => const ShimmerContainer(
                  width: double.infinity,
                  height: 200,
                  borderRadius: 12,
                ),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
          ],
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
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _PostCommentsSheet(post: post),
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
                onTap: () => _sharePost(context, post),
                child: const Tooltip(
                  message: 'Share Post',
                  child: Icon(Icons.share_outlined, size: 18, color: AppColors.inkSoft),
                ),
              ),
              if (isAuthor) ...[
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => _confirmDelete(context, ref),
                  child: const Tooltip(
                    message: 'Delete Post',
                    child: Icon(Icons.delete_outline_rounded, size: 19, color: AppColors.error),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _sharePost(BuildContext context, CommunityPost post) async {
  final title = post.title.isNotEmpty ? post.title : 'Agriculture Community Post';
  final content = post.content;
  final shareText = '$title\n\n$content\n\nShared via IGrow App (https://iagrow.zappcode.in)';

  try {
    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: title,
      ),
    );
  } catch (e) {
    await Clipboard.setData(ClipboardData(text: shareText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post copied to clipboard!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }
}

class _PostCommentsSheet extends ConsumerStatefulWidget {
  const _PostCommentsSheet({required this.post});

  final CommunityPost post;

  @override
  ConsumerState<_PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends ConsumerState<_PostCommentsSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    final currentUser = ref.read(authProvider).user;
    final author = CommunityAuthor(
      id: currentUser?.id.toString() ?? 'me',
      fullName: (currentUser?.fullName != null && currentUser!.fullName.trim().isNotEmpty)
          ? currentUser.fullName
          : 'You',
      isExpert: currentUser?.isInstructor == true || currentUser?.isAdmin == true,
      avatarUrl: currentUser?.avatarUrl,
    );

    setState(() => _isSubmitting = true);
    _commentController.clear();

    try {
      await ref.read(postCommentsProvider(widget.post.id).notifier).addComment(
            text: text,
            author: author,
          );
      ref.read(communityPostsProvider.notifier).incrementCommentsCount(widget.post.id);

      // Smoothly scroll to the newly posted comment
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commentsAsync = ref.watch(postCommentsProvider(widget.post.id));
    final commentsCount = commentsAsync.value?.length ?? widget.post.commentsCount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$commentsCount',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Comments List
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: AppColors.inkSoft.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No comments yet',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Be the first to share your thoughts on this post!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: comment.author.isExpert
                              ? AppColors.accentOrange.withValues(alpha: 0.15)
                              : AppColors.primaryGreen.withValues(alpha: 0.15),
                          backgroundImage: comment.author.avatarUrl != null
                              ? NetworkImage(comment.author.avatarUrl!)
                              : null,
                          child: comment.author.avatarUrl == null
                              ? Icon(
                                  comment.author.isExpert
                                      ? Icons.verified_rounded
                                      : Icons.person_rounded,
                                  color: comment.author.isExpert
                                      ? AppColors.accentOrange
                                      : AppColors.primaryGreen,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.cardDark
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.author.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                        if (comment.author.isExpert) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified,
                                              size: 12, color: AppColors.accentOrange),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      timeago.format(comment.createdAt),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment.content,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load comments'),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => ref.read(postCommentsProvider(widget.post.id).notifier).fetchComments(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.lineDark : AppColors.lineLight,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? AppColors.bgDark : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isSubmitting ? null : _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
