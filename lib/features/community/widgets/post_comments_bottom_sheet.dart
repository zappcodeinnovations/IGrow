import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/widgets/ugc_report_dialog.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';

class PostCommentsBottomSheet extends ConsumerStatefulWidget {
  const PostCommentsBottomSheet({
    super.key,
    required this.postId,
    required this.postAuthorName,
    this.isHubActive = true,
    this.isHostInstructor = false,
  });

  final String postId;
  final String postAuthorName;
  final bool isHubActive;
  final bool isHostInstructor;

  static void show(
    BuildContext context, {
    required String postId,
    required String postAuthorName,
    bool isHubActive = true,
    bool isHostInstructor = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostCommentsBottomSheet(
        postId: postId,
        postAuthorName: postAuthorName,
        isHubActive: isHubActive,
        isHostInstructor: isHostInstructor,
      ),
    );
  }

  @override
  ConsumerState<PostCommentsBottomSheet> createState() => _PostCommentsBottomSheetState();
}

class _PostCommentsBottomSheetState extends ConsumerState<PostCommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSending = false;
  CommunityComment? _replyingToComment;

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startReply(CommunityComment comment) {
    if (!widget.isHubActive) {
      AppToast.show(
        context,
        'This community hub has been deactivated by administration. Replying is disabled.',
        isError: true,
      );
      return;
    }
    setState(() => _replyingToComment = comment);
    _focusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() => _replyingToComment = null);
  }

  Future<void> _submitComment() async {
    if (!widget.isHubActive) {
      AppToast.show(
        context,
        'This community hub has been deactivated by administration. Replying is disabled.',
        isError: true,
      );
      return;
    }

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
    final replyParent = _replyingToComment;
    _commentController.clear();
    setState(() => _replyingToComment = null);

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
          parentId: replyParent?.id,
        );

    ref.read(communityPostsProvider.notifier).incrementCommentsCount(widget.postId);

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(CommunityComment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Comment?'),
        content: const Text('Are you sure you want to delete this reply? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(postCommentsProvider(widget.postId).notifier).deleteComment(comment.id);
      if (mounted) {
        AppToast.show(context, 'Comment deleted successfully.');
      }
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
        height: MediaQuery.of(context).size.height * 0.78,
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
                    'Comments & Replies',
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

            // Inactive Hub notice if disabled
            if (!widget.isHubActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.redAccent.withValues(alpha: 0.12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This community is inactive. Replying and interactions are disabled.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.red.shade200 : Colors.red.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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

                  // Group by parent ID: top-level comments (parentId == null) & replies
                  final topLevel = comments.where((c) => c.parentId == null || c.parentId!.isEmpty).toList();
                  final repliesMap = <String, List<CommunityComment>>{};
                  for (final c in comments) {
                    if (c.parentId != null && c.parentId!.isNotEmpty) {
                      repliesMap.putIfAbsent(c.parentId!, () => []).add(c);
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: topLevel.length,
                    itemBuilder: (ctx, i) {
                      final parent = topLevel[i];
                      final childReplies = repliesMap[parent.id] ?? [];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCommentItem(
                              context: ctx,
                              comment: parent,
                              currentUser: currentUser,
                              isDark: isDark,
                              isNested: false,
                            ),
                            if (childReplies.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 28, top: 8),
                                child: Column(
                                  children: childReplies
                                      .map((reply) => Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: _buildCommentItem(
                                              context: ctx,
                                              comment: reply,
                                              currentUser: currentUser,
                                              isDark: isDark,
                                              isNested: true,
                                            ),
                                          ))
                                      .toList(),
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

            // Replying Indicator Bar
            if (_replyingToComment != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: isDark ? const Color(0xFF223628) : const Color(0xFFEAF5EB),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded, size: 16, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to ${_replyingToComment!.author.fullName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _cancelReply,
                    ),
                  ],
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
                        focusNode: _focusNode,
                        enabled: widget.isHubActive,
                        decoration: InputDecoration(
                          hintText: !widget.isHubActive
                              ? 'Replying is disabled for this inactive hub'
                              : (_replyingToComment != null
                                  ? 'Write a reply to ${_replyingToComment!.author.fullName}...'
                                  : 'Add a comment or question...'),
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
                          : Icon(
                              Icons.send_rounded,
                              color: widget.isHubActive ? AppColors.primaryGreen : Colors.grey,
                            ),
                      onPressed: (_isSending || !widget.isHubActive) ? null : _submitComment,
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

  Widget _buildCommentItem({
    required BuildContext context,
    required CommunityComment comment,
    required dynamic currentUser,
    required bool isDark,
    required bool isNested,
  }) {
    final isMe = currentUser != null && currentUser.id == comment.author.id;
    final canDelete = isMe || widget.isHostInstructor || (currentUser != null && (currentUser.isAdmin == true || currentUser.isInstructor == true));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNested
            ? (isDark ? const Color(0xFF192A1F) : const Color(0xFFF1F6F0))
            : (isDark ? const Color(0xFF1E2F23) : const Color(0xFFF8FAF7)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2E4334) : const Color(0xFFE5EDE2),
          width: isNested ? 1.0 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isNested ? 12 : 14,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                child: Text(
                  comment.author.fullName.isNotEmpty
                      ? comment.author.fullName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: isNested ? 10.5 : 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            comment.author.fullName.isNotEmpty ? comment.author.fullName : 'Learner',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isNested ? 12 : 13,
                              color: isDark ? Colors.white : AppColors.inkDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (comment.authorRole.toUpperCase() == 'INSTRUCTOR' || comment.author.isExpert) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Instructor',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      timeago.format(comment.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              // Moderate / Delete or Report / Block Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: isDark ? Colors.white60 : AppColors.inkSoft,
                ),
                color: isDark ? const Color(0xFF1E2B22) : Colors.white,
                onSelected: (val) {
                  if (val == 'delete') _deleteComment(comment);
                  if (val == 'report') _reportComment(comment);
                  if (val == 'block') _blockUser(comment);
                },
                itemBuilder: (_) => [
                  if (canDelete)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 16),
                          SizedBox(width: 8),
                          Text('Delete Comment', style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
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
            comment.content,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: isDark ? Colors.white70 : AppColors.inkDark,
            ),
          ),
          if (widget.isHubActive) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _startReply(comment),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 14,
                        color: isDark ? const Color(0xFF86EFAC) : AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF86EFAC) : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
