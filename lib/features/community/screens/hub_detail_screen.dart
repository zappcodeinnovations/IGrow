import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/community_models.dart';
import '../providers/community_provider.dart';

class HubDetailScreen extends ConsumerStatefulWidget {
  const HubDetailScreen({super.key, required this.hubId});

  final String hubId;

  @override
  ConsumerState<HubDetailScreen> createState() => _HubDetailScreenState();
}

class _HubDetailScreenState extends ConsumerState<HubDetailScreen> {
  bool _isRulesExpanded = false;

  @override
  Widget build(BuildContext context) {
    final hubAsync = ref.watch(hubDetailsProvider(widget.hubId));
    final postsAsync = ref.watch(communityPostsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7FAF6),
      body: hubAsync.when(
        data: (hub) {
          return CustomScrollView(
            slivers: [
              // ─── Sliver App Bar with Cover Banner ────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.primaryGreen,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
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
                      // Gradient overlay for contrast
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                      // Title on banner
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: (hub.logo != null && hub.logo!.isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: hub.logo!,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 32),
                                      )
                                    : const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 32),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    hub.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: AppColors.accentOrange, size: 14),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${hub.state} • ${hub.districts.join(", ")}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
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

              // ─── Hub Details Card ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Join / Joined Action & Stats
                      _HubActionHeader(
                        hub: hub,
                        onJoinToggle: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final success = await ref
                              .read(communityHubsProvider.notifier)
                              .toggleJoin(hub.id);
                          if (mounted) {
                            ref.invalidate(hubDetailsProvider(hub.id));
                            if (!success) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Failed to update membership.')),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (hub.description.isNotEmpty) ...[
                        Text(
                          hub.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? const Color(0xFFC0CCC0) : const Color(0xFF3B4837),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Farming Topics Chips
                      if (hub.farmingTopics.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: hub.farmingTopics.map((topic) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF213426) : const Color(0xFFEBF5E7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF334F3A) : const Color(0xFFCEE6C5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.eco_rounded, size: 14, color: AppColors.primaryGreen),
                                  const SizedBox(width: 5),
                                  Text(
                                    topic,
                                    style: const TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Host / Instructor Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.lineDark : const Color(0xFFE0EAE0),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFEAF5E7),
                              backgroundImage: (hub.instructorAvatar != null && hub.instructorAvatar!.isNotEmpty)
                                  ? CachedNetworkImageProvider(hub.instructorAvatar!)
                                  : null,
                              child: (hub.instructorAvatar == null || hub.instructorAvatar!.isEmpty)
                                  ? const Icon(Icons.person, color: AppColors.primaryGreen)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        hub.instructorName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isDark ? Colors.white : AppColors.inkDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: AppColors.primaryGreen, size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Community Host & Agronomy Expert',
                                    style: TextStyle(
                                      color: AppColors.inkSoft,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Rules & Guidelines Section
                      if (hub.rules.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF242F26) : const Color(0xFFF9FBF7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.lineDark : const Color(0xFFE2ECE0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isRulesExpanded = !_isRulesExpanded;
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.gavel_rounded, size: 18, color: AppColors.accentOrange),
                                        SizedBox(width: 8),
                                        Text(
                                          'Community Rules & Guidelines',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      _isRulesExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                      color: AppColors.inkSoft,
                                    ),
                                  ],
                                ),
                              ),
                              if (_isRulesExpanded) ...[
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                Text(
                                  hub.rules,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: isDark ? const Color(0xFFB5C4B5) : const Color(0xFF4C5D47),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Discussions & Updates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.inkDark,
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: () {
                              context.push(RouteNames.createPost);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ─── Feed Posts ──────────────────────────────────────
              postsAsync.when(
                data: (posts) {
                  final hubPosts = posts.where((p) => p.hubId == hub.id).toList();
                  if (hubPosts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2EBE0), width: 1.2),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.forum_outlined, size: 48, color: AppColors.inkSoft),
                            const SizedBox(height: 10),
                            const Text(
                              'No posts in this hub yet',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Be the first to start a conversation in this community!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => context.push(RouteNames.createPost),
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Create First Post'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = hubPosts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _HubPostCard(post: post),
                          );
                        },
                        childCount: hubPosts.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: Text('Failed to load posts: $err')),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
        ),
        error: (err, _) => Scaffold(
          appBar: AppBar(title: const Text('Hub')),
          body: Center(child: Text('Error: $err')),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E690B),
            Color(0xFF4B9C0A),
            Color(0xFF8FD838),
          ],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.15,
          child: const Icon(Icons.agriculture_rounded, size: 140, color: Colors.white),
        ),
      ),
    );
  }
}

class _HubActionHeader extends StatelessWidget {
  const _HubActionHeader({required this.hub, required this.onJoinToggle});

  final CommunityHub hub;
  final VoidCallback onJoinToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.lineDark : const Color(0xFFE2ECE0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.group_rounded, color: AppColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${hub.memberCount} Members',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const Text(
                    'Active community',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: hub.isMember ? const Color(0xFFEAF5E7) : AppColors.primaryGreen,
              foregroundColor: hub.isMember ? AppColors.primaryGreen : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: hub.isMember ? const BorderSide(color: AppColors.primaryGreen, width: 1.2) : BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(hub.isMember ? Icons.check_circle_rounded : Icons.person_add_rounded, size: 18),
            label: Text(
              hub.isMember ? 'Joined' : 'Join Hub',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: onJoinToggle,
          ),
        ],
      ),
    );
  }
}

class _HubPostCard extends ConsumerWidget {
  const _HubPostCard({required this.post});
  final CommunityPost post;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: post.postType == 'ADVISORY'
              ? const Color(0xFFFFB74D)
              : (isDark ? AppColors.lineDark : const Color(0xFFE2EBE0)),
          width: post.postType == 'ADVISORY' ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: post.postType == 'ADVISORY'
                ? Colors.orange.withValues(alpha: 0.08)
                : AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author & Type badge
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFEAF5E7),
                backgroundImage: post.author.avatarUrl != null ? CachedNetworkImageProvider(post.author.avatarUrl!) : null,
                child: post.author.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primaryGreen, size: 20) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      timeago.format(post.createdAt),
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _PostTypeBadge(postType: post.postType),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Content
          if (post.title.isNotEmpty) ...[
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            post.content,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? const Color(0xFFCBD6CB) : const Color(0xFF2C392A),
            ),
          ),
          const SizedBox(height: 12),

          // Specialized Rich Card CTAs
          if (post.postType == 'OFFLINE_SEMINAR')
            _SeminarBanner(post: post, onDirections: () => post.link != null ? _launchUrl(post.link!) : null),
          if (post.postType == 'ONLINE_MEETING')
            _MeetingBanner(post: post, onJoin: () => post.link != null ? _launchUrl(post.link!) : null),
          if (post.postType == 'COURSE_LAUNCH')
            _CourseBanner(
              post: post,
              onEnroll: () {
                if (post.courseId != null) {
                  context.push('/farmer/course/${post.courseId}');
                }
              },
            ),

          if (post.image != null && post.image!.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: post.image!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Actions: Like, Comment
          Row(
            children: [
              InkWell(
                onTap: () {
                  ref.read(communityPostsProvider.notifier).toggleLike(post.id);
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: post.isLikedByMe ? Colors.red : AppColors.inkSoft,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text('${post.likesCount}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.inkSoft, size: 19),
                  const SizedBox(width: 5),
                  Text('${post.commentsCount}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostTypeBadge extends StatelessWidget {
  const _PostTypeBadge({required this.postType});
  final String postType;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (postType) {
      case 'OFFLINE_SEMINAR':
        bg = const Color(0xFFEAF7E4);
        fg = const Color(0xFF2E7D32);
        label = 'Seminar';
        icon = Icons.event_rounded;
        break;
      case 'ONLINE_MEETING':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        label = 'Webinar';
        icon = Icons.videocam_rounded;
        break;
      case 'COURSE_LAUNCH':
        bg = const Color(0xFFF3E5F5);
        fg = const Color(0xFF7B1FA2);
        label = 'Course';
        icon = Icons.school_rounded;
        break;
      case 'ADVISORY':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        label = 'Advisory';
        icon = Icons.warning_amber_rounded;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
        label = 'General';
        icon = Icons.tag_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SeminarBanner extends StatelessWidget {
  const _SeminarBanner({required this.post, required this.onDirections});
  final CommunityPost post;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCEE8C6), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.eventDate != null)
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 16, color: Color(0xFF2E7D32)),
                const SizedBox(width: 6),
                Text(
                  post.formattedEventDateTime ?? '${post.eventDate!.day}/${post.eventDate!.month}/${post.eventDate!.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF2E7D32)),
                ),
              ],
            ),
          if (post.venueAddress != null && post.venueAddress!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_rounded, size: 16, color: AppColors.accentOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    post.venueAddress!,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF354432)),
                  ),
                ),
              ],
            ),
          ],
          if (post.link != null && post.link!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.directions_rounded, size: 16),
                label: const Text('Get Directions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: onDirections,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeetingBanner extends StatelessWidget {
  const _MeetingBanner({required this.post, required this.onJoin});
  final CommunityPost post;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7E0FF), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.video_call_rounded, color: Color(0xFF1565C0), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Online Webinar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1565C0))),
                  if (post.eventDate != null)
                    Text(
                      '${post.eventDate!.day}/${post.eventDate!.month} at ${post.eventDate!.hour}:${post.eventDate!.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 11, color: AppColors.inkSoft),
                    ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.link_rounded, size: 16),
            label: const Text('Join', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: onJoin,
          ),
        ],
      ),
    );
  }
}

class _CourseBanner extends StatelessWidget {
  const _CourseBanner({required this.post, required this.onEnroll});
  final CommunityPost post;
  final VoidCallback onEnroll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF4FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6CFEE), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.school_rounded, color: Color(0xFF7B1FA2), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Featured Course', style: TextStyle(color: Color(0xFF7B1FA2), fontSize: 11, fontWeight: FontWeight.bold)),
                      Text(
                        post.courseName ?? 'New Agricultural Masterclass',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B1FA2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: onEnroll,
          ),
        ],
      ),
    );
  }
}
