import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';
import 'full_screen_image_viewer.dart';

class RichPostCard extends ConsumerStatefulWidget {
  const RichPostCard({
    super.key,
    required this.post,
    this.hubId,
    this.isInstructorView = false,
  });

  final CommunityPost post;
  final String? hubId;
  final bool isInstructorView;

  @override
  ConsumerState<RichPostCard> createState() => _RichPostCardState();
}

class _RichPostCardState extends ConsumerState<RichPostCard> with SingleTickerProviderStateMixin {
  bool _isEmojiPickerOpen = false;
  late AnimationController _pickerAnimController;
  late Animation<double> _pickerScaleAnim;

  @override
  void initState() {
    super.initState();
    _pickerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _pickerScaleAnim = CurvedAnimation(
      parent: _pickerAnimController,
      curve: Curves.easeOutBack,
    );

    // Record view automatically on appearance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (widget.hubId != null && widget.hubId!.isNotEmpty) {
          ref.read(communityHubPostsProvider(widget.hubId!).notifier).recordView(widget.post.id);
        } else {
          ref.read(communityPostsProvider.notifier).recordView(widget.post.id);
        }
      }
    });
  }

  @override
  void dispose() {
    _pickerAnimController.dispose();
    super.dispose();
  }

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerOpen = !_isEmojiPickerOpen;
      if (_isEmojiPickerOpen) {
        _pickerAnimController.forward();
      } else {
        _pickerAnimController.reverse();
      }
    });
  }

  void _onReact(String reaction) {
    _pickerAnimController.reverse();
    setState(() => _isEmojiPickerOpen = false);
    if (widget.hubId != null && widget.hubId!.isNotEmpty) {
      ref.read(communityHubPostsProvider(widget.hubId!).notifier).reactToPost(widget.post.id, reaction);
    } else {
      ref.read(communityPostsProvider.notifier).reactToPost(widget.post.id, reaction);
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('Are you sure you want to delete this community update?'),
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
      if (widget.hubId != null && widget.hubId!.isNotEmpty) {
        await ref.read(communityHubPostsProvider(widget.hubId!).notifier).deletePost(widget.post.id);
      } else {
        await ref.read(communityPostsProvider.notifier).deletePost(widget.post.id);
      }
    }
  }

  Future<void> _openLink(String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;
    try {
      final uri = Uri.parse(urlString.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link')),
          );
        }
      }
    } catch (_) {}
  }

  void _showImageViewer(BuildContext context, String imageUrl) {
    FullScreenImageViewer.show(
      context,
      imageUrl,
      title: widget.post.title.isNotEmpty ? widget.post.title : null,
    );
  }

  void _openCourseDetails(BuildContext context) {
    final embed = widget.post.courseEmbed;
    if (embed != null && !embed.isApproved) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final isSheetDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isSheetDark ? const Color(0xFF1B2B20) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: isSheetDark ? AppColors.lineDark : const Color(0xFFE2EBE0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  'Course Under Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isSheetDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This course has been announced by the instructor and is currently under review by the team. It will be open for enrollment as soon as review is completed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isSheetDark ? Colors.white70 : AppColors.inkSoft,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    final rawCourseId = (embed != null && embed.id.isNotEmpty)
        ? embed.id
        : widget.post.courseId;
    final cleanId = rawCourseId?.trim();
    if (cleanId != null && cleanId.isNotEmpty) {
      context.push('/farmer/course/$cleanId');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course details not available'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).user;
    final isAuthorOrInstructor = widget.isInstructorView ||
        (currentUser != null && (currentUser.id == widget.post.author.id || currentUser.isInstructor || currentUser.isAdmin));

    // Deep theme-tailored background & gradient
    final cardBg = isDark ? const Color(0xFF16231B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C3E32) : const Color(0xFFE2EBE0);
    final titleColor = isDark ? Colors.white : AppColors.inkDark;
    final bodyColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155);

    final postType = widget.post.postType.toUpperCase();

    // Vibrant Highlighted Badges
    Color badgeColor;
    Color badgeBg;
    IconData badgeIcon;
    String badgeLabel;

    if (postType == 'ANNOUNCEMENT' || postType == 'COURSE_LAUNCH') {
      badgeColor = const Color(0xFF9333EA);
      badgeBg = isDark ? const Color(0xFF35174D) : const Color(0xFFF3E8FF);
      badgeIcon = Icons.campaign_rounded;
      badgeLabel = 'Course Announcement';
    } else if (postType == 'WEBINAR' || postType == 'ONLINE_MEETING') {
      badgeColor = const Color(0xFF2563EB);
      badgeBg = isDark ? const Color(0xFF13284A) : const Color(0xFFEFF6FF);
      badgeIcon = Icons.videocam_rounded;
      badgeLabel = 'Online Webinar';
    } else if (postType == 'SEMINAR' || postType == 'OFFLINE_SEMINAR') {
      badgeColor = const Color(0xFFD97706);
      badgeBg = isDark ? const Color(0xFF3E230B) : const Color(0xFFFEF3C7);
      badgeIcon = Icons.groups_rounded;
      badgeLabel = 'Offline Seminar';
    } else {
      badgeColor = const Color(0xFF16A34A);
      badgeBg = isDark ? const Color(0xFF153820) : const Color(0xFFDCFCE7);
      badgeIcon = Icons.edit_note_rounded;
      badgeLabel = 'General Post';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: Author Info, Verified Tag, Badge & Menu ───────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                // Avatar with Glowing Ring
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.post.author.isExpert ? AppColors.primaryGreen : Colors.transparent,
                      width: 1.8,
                    ),
                  ),
                  child: ClipOval(
                    child: widget.post.author.avatarUrl != null && widget.post.author.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.post.author.avatarUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.person, color: AppColors.primaryGreen),
                          )
                        : const Icon(Icons.person, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 10),
                // Author Name & Timeago
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.post.author.fullName.isNotEmpty ? widget.post.author.fullName : 'Agricultural Expert',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: titleColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.post.author.isExpert) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: AppColors.primaryGreen, size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? Colors.white60 : AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                // Post Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withValues(alpha: isDark ? 0.4 : 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 13, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // More Menu
                if (isAuthorOrInstructor)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, size: 20, color: isDark ? Colors.white70 : AppColors.inkSoft),
                    color: isDark ? const Color(0xFF1E2B22) : Colors.white,
                    onSelected: (value) {
                      if (value == 'delete') _deletePost();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
                            SizedBox(width: 8),
                            Text('Delete Post', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ─── Post Title ──────────────────────────────────────────
          if (widget.post.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              child: Text(
                widget.post.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                  color: titleColor,
                  letterSpacing: -0.2,
                ),
              ),
            ),

          // ─── Post Content ────────────────────────────────────────
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 12),
              child: Text(
                widget.post.content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: bodyColor,
                ),
              ),
            ),

          // ─── 1. WEBINAR EMBED CARD ───────────────────────────────
          if (postType == 'WEBINAR' || postType == 'ONLINE_MEETING') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0F2038), const Color(0xFF142947)]
                        : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.4 : 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.formattedEventDateTime != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.alarm_on_rounded, size: 16, color: Color(0xFF2563EB)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Live: ${widget.post.formattedEventDateTime!}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _openLink(widget.post.link),
                          icon: const Icon(Icons.link_rounded, size: 18),
                          label: const Text('Join Live Webinar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ─── 2. SEMINAR EMBED CARD ───────────────────────────────
          if (postType == 'SEMINAR' || postType == 'OFFLINE_SEMINAR') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2D1B07), const Color(0xFF38230D)]
                        : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD97706).withValues(alpha: isDark ? 0.4 : 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.post.formattedEventDateTime != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.event_available_rounded, size: 16, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Schedule: ${widget.post.formattedEventDateTime!}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (widget.post.venueAddress != null && widget.post.venueAddress!.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.post.venueAddress!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : const Color(0xFF78350F),
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD97706), Color(0xFFB45309)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD97706).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            final mapsUrl = (widget.post.link != null && widget.post.link!.isNotEmpty)
                                ? widget.post.link!
                                : 'https://maps.google.com/?q=${Uri.encodeComponent(widget.post.venueAddress ?? "")}';
                            _openLink(mapsUrl);
                          },
                          icon: const Icon(Icons.map_rounded, size: 18),
                          label: const Text('Open in Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ─── 3. ANNOUNCEMENT COURSE EMBED CARD ────────────────────
          if ((postType == 'ANNOUNCEMENT' || postType == 'COURSE_LAUNCH') &&
              (widget.post.courseEmbed != null || (widget.post.courseId != null && widget.post.courseId!.isNotEmpty))) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _openCourseDetails(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF281338), const Color(0xFF1E0E2B)]
                            : [const Color(0xFFFAF5FF), const Color(0xFFF3E8FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF9333EA).withValues(alpha: isDark ? 0.6 : 0.4),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9333EA).withValues(alpha: isDark ? 0.2 : 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Course Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.post.courseEmbed?.thumbnail != null &&
                                  widget.post.courseEmbed!.thumbnail!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.post.courseEmbed!.thumbnail!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    color: const Color(0xFF9333EA).withValues(alpha: 0.15),
                                    width: 64,
                                    height: 64,
                                    child: const Icon(Icons.school_rounded, color: Color(0xFF9333EA), size: 28),
                                  ),
                                )
                              : Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9333EA).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: Color(0xFF9333EA), size: 28),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Builder(
                          builder: (context) {
                            final isCourseApproved = widget.post.courseEmbed?.isApproved ?? true;
                            return Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isCourseApproved
                                          ? const Color(0xFF9333EA).withValues(alpha: 0.16)
                                          : Colors.amber.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isCourseApproved ? 'PUBLISHED COURSE' : 'COMING SOON',
                                      style: TextStyle(
                                        color: isCourseApproved ? const Color(0xFF9333EA) : Colors.amber[800],
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.post.courseEmbed?.title ?? widget.post.courseName ?? 'Featured Agriculture Course',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: titleColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.post.courseEmbed?.price != null &&
                                      widget.post.courseEmbed!.price!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${widget.post.courseEmbed!.price}',
                                      style: TextStyle(
                                        color: isCourseApproved ? const Color(0xFF9333EA) : Colors.amber[800],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final isCourseApproved = widget.post.courseEmbed?.isApproved ?? true;
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isCourseApproved
                                      ? const [Color(0xFF9333EA), Color(0xFF7E22CE)]
                                      : const [Color(0xFFD97706), Color(0xFFB45309)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isCourseApproved ? const Color(0xFF9333EA) : const Color(0xFFD97706)).withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _openCourseDetails(context),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isCourseApproved ? 'View Course' : 'Coming Soon',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      isCourseApproved ? Icons.arrow_forward_rounded : Icons.schedule_rounded,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ─── 4. GENERAL POST IMAGE ────────────────────────────────
          if (widget.post.image != null && widget.post.image!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: GestureDetector(
                onTap: () => _showImageViewer(context, widget.post.image!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.image!,
                    width: double.infinity,
                    height: 210,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 210,
                      color: isDark ? Colors.white10 : Colors.black12,
                      child: const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen, strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],

          // ─── Animated Floating Emoji Reaction Picker ─────────────
          if (_isEmojiPickerOpen)
            ScaleTransition(
              scale: _pickerScaleAnim,
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF223528) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _EmojiItem(emoji: '👍', label: 'Like', isSelected: widget.post.userReaction == 'LIKE', onTap: () => _onReact('LIKE')),
                    _EmojiItem(emoji: '❤️', label: 'Love', isSelected: widget.post.userReaction == 'LOVE', onTap: () => _onReact('LOVE')),
                    _EmojiItem(emoji: '👏', label: 'Clap', isSelected: widget.post.userReaction == 'CLAP', onTap: () => _onReact('CLAP')),
                    _EmojiItem(emoji: '💡', label: 'Helpful', isSelected: widget.post.userReaction == 'IDEA', onTap: () => _onReact('IDEA')),
                    _EmojiItem(emoji: '🌾', label: 'Farmer', isSelected: widget.post.userReaction == 'FARM', onTap: () => _onReact('FARM')),
                  ],
                ),
              ),
            ),

          Divider(height: 18, color: borderColor),

          // ─── Footer: Views Tally & Emoji Reactions ────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Views Metric
                Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined, size: 16, color: isDark ? Colors.white60 : AppColors.inkSoft),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.post.viewsCount} views',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
                // Emoji Reaction Button & Active Count
                GestureDetector(
                  onTap: _toggleEmojiPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.post.userReaction != null
                          ? (isDark ? const Color(0xFF263B2B) : const Color(0xFFDCFCE7))
                          : (isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: widget.post.userReaction != null
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _getReactionEmoji(widget.post.userReaction) ?? '👍',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.post.reactionsCount}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: widget.post.userReaction != null
                                ? AppColors.primaryGreen
                                : (isDark ? Colors.white70 : AppColors.inkDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _getReactionEmoji(String? reaction) {
    switch (reaction) {
      case 'LIKE':
        return '👍';
      case 'LOVE':
        return '❤️';
      case 'CLAP':
        return '👏';
      case 'IDEA':
        return '💡';
      case 'FARM':
        return '🌾';
      default:
        return null;
    }
  }
}

class _EmojiItem extends StatelessWidget {
  const _EmojiItem({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          emoji,
          style: TextStyle(fontSize: isSelected ? 24 : 20),
        ),
      ),
    );
  }
}
