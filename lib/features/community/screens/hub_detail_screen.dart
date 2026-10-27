import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';
import '../widgets/create_post_sheets.dart';
import '../widgets/rich_post_card.dart';

class HubDetailScreen extends ConsumerStatefulWidget {
  const HubDetailScreen({super.key, required this.hubId});

  final String hubId;

  @override
  ConsumerState<HubDetailScreen> createState() => _HubDetailScreenState();
}

class _HubDetailScreenState extends ConsumerState<HubDetailScreen> {
  void _confirmLeave(BuildContext context, CommunityHub hub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1B281F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.exit_to_app_rounded, color: Colors.red, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Leave Community?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to leave "${hub.name}"? You will no longer receive announcements and updates from this instructor.',
          style: TextStyle(
            fontSize: 13.5,
            color: isDark ? Colors.white70 : AppColors.inkSoft,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(communityHubsProvider.notifier).toggleJoin(
                      hub.id,
                      currentIsMember: true,
                      currentMemberCount: hub.memberCount,
                    );
                ref.invalidate(suggestedHubsProvider);
                ref.invalidate(hubDetailsProvider(hub.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Left "${hub.name}"'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await ref.read(communityHubsProvider.notifier).toggleJoin(
                                hub.id,
                                currentIsMember: false,
                                currentMemberCount: hub.memberCount > 0 ? hub.memberCount - 1 : 0,
                              );
                          ref.invalidate(suggestedHubsProvider);
                          ref.invalidate(hubDetailsProvider(hub.id));
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to leave: $e')),
                  );
                }
              }
            },
            child: const Text('Leave', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRulesSheet(BuildContext context, CommunityHub hub) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1B281F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Community Rules & Guidelines',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : const Color(0xFFF7FAF6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isDark ? AppColors.lineDark : const Color(0xFFDCE8DA)),
                  ),
                  child: Text(
                    hub.rules.isNotEmpty
                        ? hub.rules
                        : '1. Respect all farmers and experts.\n2. No commercial spam or unrelated links.\n3. Keep all queries agricultural and constructive.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : const Color(0xFF2D3748),
                    ),
                  ),
                ),
                if (hub.farmingTopics.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Topics Covered in this Hub:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: hub.farmingTopics.map((topic) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF263B2B) : const Color(0xFFEAF5E7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#$topic',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hubAsync = ref.watch(hubDetailsProvider(widget.hubId));
    final postsAsync = ref.watch(communityHubPostsProvider(widget.hubId));
    final currentUser = ref.watch(authProvider).user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111C15) : const Color(0xFFF7FAF6),
      body: hubAsync.when(
        data: (hub) {
          final isAuthorOrInstructor = (currentUser?.isInstructor == true || currentUser?.isAdmin == true) &&
              (hub.instructorId.isNotEmpty && currentUser?.id == hub.instructorId);

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              ref.invalidate(hubDetailsProvider(widget.hubId));
              await ref.read(communityHubPostsProvider(widget.hubId).notifier).fetchPosts();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ─── Sliver App Bar with Cover Banner ──────────────
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppColors.primaryGreen,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    // Info Icon for Community Rules & Guidelines
                    IconButton(
                      tooltip: 'Community Rules',
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
                      ),
                      onPressed: () => _showRulesSheet(context, hub),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (hub.coverBanner != null && hub.coverBanner!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: hub.coverBanner!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _DefaultCoverBanner(hub: hub),
                          )
                        else
                          _DefaultCoverBanner(hub: hub),
                        // Dark Gradient Overlay for high text contrast
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                        ),
                        // Title & Badges on Cover
                        Positioned(
                          bottom: 14,
                          left: 16,
                          right: 16,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  color: Colors.white,
                                  child: hub.logo != null && hub.logo!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: hub.logo!,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen),
                                        )
                                      : const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 30),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      hub.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '📍 ${hub.state} • ${hub.districts.isNotEmpty ? hub.districts.join(", ") : "District Hub"}',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 11.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── Header Stats & Instructor Profile Bar ─────────
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF18261E) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isDark ? const Color(0xFF2C3E32) : const Color(0xFFE2EBE0), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.15 : 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Instructor Photo
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                          backgroundImage: hub.instructorAvatar != null && hub.instructorAvatar!.isNotEmpty
                              ? CachedNetworkImageProvider(hub.instructorAvatar!)
                              : null,
                          child: (hub.instructorAvatar == null || hub.instructorAvatar!.isEmpty)
                              ? const Icon(Icons.person, color: AppColors.primaryGreen, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      hub.instructorName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : AppColors.inkDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: AppColors.primaryGreen, size: 15),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '👥 ${hub.memberCount} Members',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Join / Leave Button (For learners)
                        if (!isAuthorOrInstructor)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hub.isMember
                                  ? (isDark ? const Color(0xFF24242A) : AppColors.editorialSurfaceContainerLow)
                                  : AppColors.editorialSecondary,
                              foregroundColor: hub.isMember
                                  ? (isDark ? Colors.white70 : AppColors.editorialOnSurface)
                                  : Colors.white,
                              elevation: hub.isMember ? 0 : 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () async {
                              if (hub.isMember) {
                                _confirmLeave(context, hub);
                              } else {
                                await ref.read(communityHubsProvider.notifier).toggleJoin(
                                      hub.id,
                                      currentIsMember: false,
                                      currentMemberCount: hub.memberCount,
                                    );
                              }
                            },
                            child: Text(
                              hub.isMember ? 'Joined ✓' : '+ Join',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ─── If Instructor, Quick Post Bar ─────────────────
                if (isAuthorOrInstructor)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'CREATE BROADCAST UPDATE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: isDark ? Colors.white60 : AppColors.inkSoft,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniActionButton(
                                  label: 'General Post',
                                  subtitle: 'Tips & photos',
                                  icon: Icons.edit_note_rounded,
                                  color: const Color(0xFF16A34A),
                                  isDark: isDark,
                                  onTap: () => CreatePostSheets.showGeneralPost(context, ref, hub.id),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniActionButton(
                                  label: 'Announcement',
                                  subtitle: 'Promote course',
                                  icon: Icons.campaign_rounded,
                                  color: const Color(0xFF9333EA),
                                  isDark: isDark,
                                  onTap: () => CreatePostSheets.showAnnouncement(context, ref, hub.id),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _MiniActionButton(
                                  label: 'Live Webinar',
                                  subtitle: 'Zoom / Meet',
                                  icon: Icons.videocam_rounded,
                                  color: const Color(0xFF2563EB),
                                  isDark: isDark,
                                  onTap: () => CreatePostSheets.showWebinar(context, ref, hub.id),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _MiniActionButton(
                                  label: 'Field Seminar',
                                  subtitle: 'Venue & meetup',
                                  icon: Icons.groups_rounded,
                                  color: const Color(0xFFD97706),
                                  isDark: isDark,
                                  onTap: () => CreatePostSheets.showSeminar(context, ref, hub.id),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // ─── Channel Feed of All Updates ───────────────────
                postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF18261E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF2C3E32) : const Color(0xFFE2EBE0)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.post_add_rounded, size: 42, color: AppColors.primaryGreen),
                              const SizedBox(height: 12),
                              Text(
                                'No updates published in this community yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Check back soon for farm tips, course discounts, webinars, and melawa announcements from your instructor!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return RichPostCard(
                            post: post,
                            hubId: hub.id,
                            isInstructorView: isAuthorOrInstructor,
                          );
                        },
                        childCount: posts.length,
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Error loading feed: $e'),
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (e, _) => Center(
          child: Text('Failed to load community hub: $e'),
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [color.withValues(alpha: 0.18), const Color(0xFF142318)]
                  : [color.withValues(alpha: 0.08), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: isDark ? 0.45 : 0.3)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.15 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.28 : 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.5,
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}

class _DefaultCoverBanner extends StatelessWidget {
  const _DefaultCoverBanner({required this.hub});
  final CommunityHub hub;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E2124),
            const Color(0xFF2B2F33),
            AppColors.editorialSecondary.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.agriculture_rounded,
          size: 72,
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}
