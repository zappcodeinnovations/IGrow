import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ugc_report_dialog.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';

class PostCommentsBottomSheet extends ConsumerStatefulWidget {
  const PostCommentsBottomSheet({
    super.key,
    required this.postId,
    required this.postAuthorName,
  });

  final String postId;
  final String postAuthorName;

  static void show(BuildContext context, {required String postId, required String postAuthorName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostCommentsBottomSheet(postId: postId, postAuthorName: postAuthorName),
    );
  }

  @override
  ConsumerState<PostCommentsBottomSheet> createState() => _PostCommentsBottomSheetState();
}

class _PostCommentsBottomSheetState extends ConsumerState<PostCommentsBottomSheet> {
  final _commentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(authProvider).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to comment')),
      );
      return;
    }

    setState(() => _isSending = true);
    _commentController.clear();

    final author = CommunityAuthor(
      id: user.id,
      fullName: user.fullName.isNotEmpty ? user.fullName : 'You',
      avatarUrl: user.avatarUrl,
      role: user.activeRole.apiValue,
      isExpert: user.isInstructor || user.isAdmin,
    );

    await ref.read(postCommentsProvider(widget.postId).notifier).addComment(
          text: text,
          author: author,
        );

    ref.read(communityPostsProvider.notifier).incrementCommentsCount(widget.postId);

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  Future<void> _reportComment(CommunityComment comment) async {
    final submitted = await UgcReportDialog.show(
      context,
      itemId: comment.id,
      type: UgcReportType.comment,
      authorName: comment.author.fullName,
    );
    if (submitted == true && mounted) {
      ref.read(postCommentsProvider(widget.postId).notifier).reportComment(
            comment.id,
            reason: 'HARASSMENT',
          );
    }
  }

  Future<void> _blockUser(CommunityComment comment) async {
    final name = comment.author.fullName.isNotEmpty ? comment.author.fullName : 'this user';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block User?'),
        content: Text('Block $name and remove all of their content immediately?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(communityPostsProvider.notifier).blockUserAndRemovePosts(comment.author.id);
      ref.read(postCommentsProvider(widget.postId).notifier).removeCommentLocally(comment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name has been blocked.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));
    final currentUser = ref.watch(authProvider).user;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18261C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag pill
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comments',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Comments List
            Expanded(
              child: commentsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'No comments yet. Be the first to reply!',
                    style: TextStyle(color: isDark ? Colors.white60 : AppColors.inkSoft),
                  ),
                ),
                data: (comments) {
                  if (comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 40,
                            color: isDark ? Colors.white24 : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No comments yet. Be the first to reply!',
                            style: TextStyle(color: isDark ? Colors.white60 : AppColors.inkSoft),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: comments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final c = comments[i];
                      final isMe = currentUser != null && currentUser.id == c.author.id;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2F23) : const Color(0xFFF8FAF7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE5EDE2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                                  child: Text(
                                    c.author.fullName.isNotEmpty
                                        ? c.author.fullName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.author.fullName.isNotEmpty ? c.author.fullName : 'Learner',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isDark ? Colors.white : AppColors.inkDark,
                                        ),
                                      ),
                                      Text(
                                        timeago.format(c.createdAt),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isDark ? Colors.white60 : AppColors.inkSoft,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 3-dots Menu on Comment for Apple Guideline 1.2
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    size: 18,
                                    color: isDark ? Colors.white60 : AppColors.inkSoft,
                                  ),
                                  color: isDark ? const Color(0xFF1E2B22) : Colors.white,
                                  onSelected: (val) {
                                    if (val == 'report') _reportComment(c);
                                    if (val == 'block') _blockUser(c);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          Icon(Icons.flag_outlined, color: Colors.orange, size: 16),
                                          SizedBox(width: 8),
                                          Text('Report Comment'),
                                        ],
                                      ),
                                    ),
                                    if (!isMe)
                                      const PopupMenuItem(
                                        value: 'block',
                                        child: Row(
                                          children: [
                                            Icon(Icons.block_rounded, color: Colors.redAccent, size: 16),
                                            SizedBox(width: 8),
                                            Text('Block User', style: TextStyle(color: Colors.redAccent)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.content,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: isDark ? Colors.white70 : AppColors.inkDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16231B) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE2EADF),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a community comment...',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : AppColors.inkSoft,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E2F23) : const Color(0xFFF1F5F0),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryGreen),
                            )
                          : const Icon(Icons.send_rounded, color: AppColors.primaryGreen),
                      onPressed: _isSending ? null : _submitComment,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
