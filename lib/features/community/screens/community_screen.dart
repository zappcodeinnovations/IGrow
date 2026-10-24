import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/services/weather_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_farmer/providers/weather_provider.dart';
import '../providers/community_provider.dart';
import '../widgets/create_post_sheets.dart';
import '../widgets/rich_post_card.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LocationPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final isInstructor = currentUser?.isInstructor == true || currentUser?.isAdmin == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF111C15) : const Color(0xFFF7FAF6),
      body: SafeArea(
        child: isInstructor
            ? const _InstructorCommunityView()
            : _StudentCommunityView(onLocationTap: () => _showLocationPicker(context)),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// 👨‍🏫 INSTRUCTOR APP FLOW (State A & State B)
// ═════════════════════════════════════════════════════════════════════
class _InstructorCommunityView extends ConsumerWidget {
  const _InstructorCommunityView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myHubAsync = ref.watch(myInstructorHubProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return myHubAsync.when(
      data: (myHub) {
        if (myHub == null) {
          return _InstructorStateA(isDark: isDark);
        }
        return _InstructorStateB(hub: myHub, isDark: isDark);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load community: $e',
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkDark),
              ),
              const SizedBox(height: 14),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                onPressed: () => ref.invalidate(myInstructorHubProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── State A: Highlighted Hero Banner to Launch Community ───────────
class _InstructorStateA extends StatelessWidget {
  const _InstructorStateA({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : AppColors.inkDark;
    final subtextColor = isDark ? Colors.white70 : AppColors.inkSoft;

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Hero Glowing Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF172B1E), const Color(0xFF1F3D2B)]
                    : [const Color(0xFFEAF5E7), const Color(0xFFF4FAF1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFCCE4C5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Glowing Icon
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.hub_rounded, size: 48, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Start Your Farming Community',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Connect directly with local farmers and students in your district. Run updates, broadcast webinars, announce courses, and organize physical farmer meetups!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: subtextColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Glowing CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => context.push(RouteNames.createHub),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                      label: const Text(
                        'Create Community & Launch',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          Text(
            'What you can do in your Community:',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 12),

          // Feature Highlight Cards (Responsive Wrap)
          _FeaturePoint(
            icon: Icons.edit_note_rounded,
            color: const Color(0xFF16A34A),
            title: '1. General Posts & Crop Tips',
            desc: 'Publish text guidance and image updates directly into your district feed.',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _FeaturePoint(
            icon: Icons.campaign_rounded,
            color: const Color(0xFF9333EA),
            title: '2. Course Announcements',
            desc: 'Promote live courses with deep links, thumbnail banners, and instant enrollment buttons.',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _FeaturePoint(
            icon: Icons.videocam_rounded,
            color: const Color(0xFF2563EB),
            title: '3. Online Webinars',
            desc: 'Host Zoom/Google Meet sessions with direct countdown and 1-tap join buttons.',
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _FeaturePoint(
            icon: Icons.groups_rounded,
            color: const Color(0xFFD97706),
            title: '4. Offline Melawas & Seminars',
            desc: 'Share venue address with 1-tap Google Maps navigation for farmer meetups.',
            isDark: isDark,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  const _FeaturePoint({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18261E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C3E32) : const Color(0xFFE4EDE1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── State B: Active Instructor Community Hub Feed ───────────────────
class _InstructorStateB extends ConsumerWidget {
  const _InstructorStateB({required this.hub, required this.isDark});
  final CommunityHub hub;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityHubPostsProvider(hub.id));
    final cardBg = isDark ? const Color(0xFF18261E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C3E32) : const Color(0xFFE2EBE0);

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        ref.invalidate(myInstructorHubProvider);
        await ref.read(communityHubPostsProvider(hub.id).notifier).fetchPosts();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── Header: Official Instructor Hub Identity ───────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1B2E21), const Color(0xFF14241A)]
                        : [Colors.white, const Color(0xFFF9FCF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official Badge Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 13, color: AppColors.primaryGreen),
                              SizedBox(width: 4),
                              Text(
                                'OFFICIAL INSTRUCTOR HUB',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.podcasts_rounded, size: 12, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text(
                                'Broadcast Channel',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Hub Logo, Title & Metadata
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen.withValues(alpha: 0.25),
                                AppColors.primaryGreen.withValues(alpha: 0.08),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4), width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: hub.logo != null && hub.logo!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: hub.logo!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 30),
                                  )
                                : const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 30),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hub.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '👥 ${hub.memberCount} Members',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '📍 ${hub.state}, ${hub.districts.isNotEmpty ? hub.districts.first : ""}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? Colors.white70 : AppColors.inkSoft,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Executive Broadcast Action Grid (2x2 Cards) ────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                        child: _QuickActionCard(
                          title: 'General Post',
                          subtitle: 'Tips & photo updates',
                          icon: Icons.edit_note_rounded,
                          color: const Color(0xFF16A34A),
                          isDark: isDark,
                          onTap: () => CreatePostSheets.showGeneralPost(context, ref, hub.id),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Announcement',
                          subtitle: 'Promote live course',
                          icon: Icons.campaign_rounded,
                          color: const Color(0xFF9333EA),
                          isDark: isDark,
                          onTap: () => CreatePostSheets.showAnnouncement(context, ref, hub.id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Live Webinar',
                          subtitle: 'Zoom / Meet session',
                          icon: Icons.videocam_rounded,
                          color: const Color(0xFF2563EB),
                          isDark: isDark,
                          onTap: () => CreatePostSheets.showWebinar(context, ref, hub.id),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickActionCard(
                          title: 'Field Seminar',
                          subtitle: 'Venue & meetup map',
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

          // ─── Feed Section Header ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Row(
                children: [
                  Text(
                    'BROADCAST FEED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white60 : AppColors.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  postsAsync.when(
                    data: (posts) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${posts.length} ${posts.length == 1 ? "Update" : "Updates"}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ─── Channel Feed (Posts List) ───────────────────────────
          postsAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.post_add_rounded, size: 40, color: AppColors.primaryGreen),
                        ),
                        const SizedBox(height: 14),
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
                          'Tap any button above to post advice, announce a course, schedule an online webinar, or host a farmer melawa!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.inkSoft,
                            height: 1.4,
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
                      isInstructorView: true,
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
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  final String title;
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [color.withValues(alpha: 0.18), const Color(0xFF142318)]
                  : [color.withValues(alpha: 0.08), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.45 : 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.15 : 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.28 : 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
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

// ═════════════════════════════════════════════════════════════════════
// 👨‍🌾 STUDENT APP FLOW (Screen 1: Discovery & 3 Segmented Tabs)
// ═════════════════════════════════════════════════════════════════════
class _StudentCommunityView extends ConsumerWidget {
  const _StudentCommunityView({required this.onLocationTap});
  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen for real-time GPS location updates from dashboard weatherProvider
    ref.listen<AsyncValue<WeatherData>>(weatherProvider, (prev, next) {
      final detectedCity = next.valueOrNull?.locationName;
      if (detectedCity != null && detectedCity.trim().isNotEmpty) {
        final profileDistrict = ref.read(authProvider).user?.locationDistrict;
        if (profileDistrict == null || profileDistrict.trim().isEmpty) {
          final curr = ref.read(selectedDistrictProvider);
          if (curr == 'Pune' || curr.isEmpty) {
            ref.read(selectedDistrictProvider.notifier).state = detectedCity.trim();
            ref.read(communityHubsProvider.notifier).fetchHubs();
            ref.invalidate(suggestedHubsProvider);
          }
        }
      }
    });

    final activeTab = ref.watch(studentCommunityTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDistrict = ref.watch(selectedDistrictProvider);
    final profileDistrict = ref.watch(authProvider).user?.locationDistrict;
    final liveGpsCity = ref.watch(weatherProvider).valueOrNull?.locationName ?? WeatherService.lastResolvedCity;

    // Use GPS detected location if profile district is not set and current is default Pune
    final effectiveDistrict = (profileDistrict != null && profileDistrict.trim().isNotEmpty)
        ? profileDistrict.trim()
        : (currentDistrict != 'Pune'
            ? currentDistrict
            : (liveGpsCity != null && liveGpsCity.trim().isNotEmpty ? liveGpsCity.trim() : currentDistrict));

    if (effectiveDistrict != currentDistrict && (profileDistrict == null || profileDistrict.trim().isEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(selectedDistrictProvider) != effectiveDistrict) {
          ref.read(selectedDistrictProvider.notifier).state = effectiveDistrict;
          ref.read(communityHubsProvider.notifier).fetchHubs();
          ref.invalidate(suggestedHubsProvider);
        }
      });
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        ref.invalidate(suggestedHubsProvider);
        await ref.read(communityHubsProvider.notifier).fetchHubs();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── Header: Title & Area Tag ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Hubs',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.inkDark,
                            letterSpacing: -0.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Learn from regional farming instructors',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : AppColors.inkSoft,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 135),
                    child: InkWell(
                      onTap: onLocationTap,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B2A20) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.45 : 0.3),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 14),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                effectiveDistrict,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryGreen, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Top Filter / 3 Segmented Tabs ───────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18261E) : const Color(0xFFE9F2E6),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2C3E32) : const Color(0xFFDAE8D6),
                  ),
                ),
                child: Row(
                  children: [
                    _TabItem(
                      title: 'Recommended',
                      isSelected: activeTab == 0,
                      isDark: isDark,
                      onTap: () => ref.read(studentCommunityTabProvider.notifier).state = 0,
                    ),
                    _TabItem(
                      title: 'All Hubs',
                      isSelected: activeTab == 1,
                      isDark: isDark,
                      onTap: () => ref.read(studentCommunityTabProvider.notifier).state = 1,
                    ),
                    _TabItem(
                      title: 'My Hubs',
                      isSelected: activeTab == 2,
                      isDark: isDark,
                      onTap: () => ref.read(studentCommunityTabProvider.notifier).state = 2,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // ─── Active Tab Content List ──────────────────────────────
          if (activeTab == 0)
            _RecommendedHubsList(district: currentDistrict, isDark: isDark)
          else if (activeTab == 1)
            _AllHubsList(isDark: isDark)
          else
            _MyHubsList(isDark: isDark),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.title,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF263D2E) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? AppColors.primaryGreen
                  : (isDark ? Colors.white70 : AppColors.inkSoft),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 1. RECOMMENDED HUBS LIST ────────────────────────────────────────
class _RecommendedHubsList extends ConsumerWidget {
  const _RecommendedHubsList({required this.district, required this.isDark});
  final String district;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedAsync = ref.watch(suggestedHubsProvider);

    return suggestedAsync.when(
      data: (hubs) {
        if (hubs.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyHubsCard(
              title: 'No community found in $district yet.',
              desc: 'Be the first or explore agricultural communities across other districts in Maharashtra!',
              buttonLabel: 'Explore All Communities',
              isDark: isDark,
              onButtonTap: () => ref.read(studentCommunityTabProvider.notifier).state = 1,
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _CommunityCard(hub: hubs[index], isDark: isDark),
            childCount: hubs.length,
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
        child: Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e'))),
      ),
    );
  }
}

// ─── 2. ALL HUBS LIST ────────────────────────────────────────────────
class _AllHubsList extends ConsumerWidget {
  const _AllHubsList({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubsAsync = ref.watch(communityHubsProvider);

    return hubsAsync.when(
      data: (hubs) {
        if (hubs.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyHubsCard(
              title: 'No communities available right now.',
              desc: 'Check back soon for new instructor-led regional farming hubs!',
              isDark: isDark,
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _CommunityCard(hub: hubs[index], isDark: isDark),
            childCount: hubs.length,
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
        child: Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e'))),
      ),
    );
  }
}

// ─── 3. MY JOINED HUBS LIST ──────────────────────────────────────────
class _MyHubsList extends ConsumerWidget {
  const _MyHubsList({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hubsAsync = ref.watch(communityHubsProvider);

    return hubsAsync.when(
      data: (allHubs) {
        final joinedHubs = allHubs.where((h) => h.isMember).toList();
        if (joinedHubs.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyHubsCard(
              title: "You haven't joined any community yet.",
              desc: "Join your regional hub to get daily expert farming tips, webinar invites, and seminar updates!",
              buttonLabel: 'Explore Recommendations',
              isDark: isDark,
              onButtonTap: () => ref.read(studentCommunityTabProvider.notifier).state = 0,
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _CommunityCard(hub: joinedHubs[index], isDark: isDark),
            childCount: joinedHubs.length,
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
        child: Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e'))),
      ),
    );
  }
}

// ─── Community Card (Student Discovery View) ─────────────────────────
class _CommunityCard extends ConsumerWidget {
  const _CommunityCard({required this.hub, required this.isDark});
  final CommunityHub hub;
  final bool isDark;

  void _confirmLeave(BuildContext context, WidgetRef ref) {
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
              child: Text(
                'Leave Community?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
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
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontWeight: FontWeight.w600),
            ),
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
                    SnackBar(content: Text('Failed to leave community: $e')),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = isDark ? const Color(0xFF2C3E32) : const Color(0xFFE2EBE0);
    final titleColor = isDark ? Colors.white : AppColors.inkDark;

    final cardGradient = isDark
        ? [const Color(0xFF192A1F), const Color(0xFF142219)]
        : [Colors.white, const Color(0xFFF9FCF8)];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            context.push('/community/hub/${hub.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Logo, Name & Instructor
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.12),
                            AppColors.primaryGreen.withValues(alpha: isDark ? 0.08 : 0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.35 : 0.22),
                          width: 1.2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: hub.logo != null && hub.logo!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: hub.logo!,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 28),
                              )
                            : const Icon(Icons.agriculture_rounded, color: AppColors.primaryGreen, size: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hub.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.5,
                              color: titleColor,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  hub.instructorName,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, color: AppColors.primaryGreen, size: 15),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 12),

            // Badges: Location & Farming Topics
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Location Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF263D2E) : const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.4 : 0.2),
                    ),
                  ),
                  child: Text(
                    '📍 ${hub.districts.isNotEmpty ? hub.districts.first : hub.state}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
                // Farming Topics Badges
                ...hub.farmingTopics.take(3).map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Text(
                      '#$topic',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : AppColors.inkDark,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),

            // Bottom Row: Member Count & Single Tap Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '👥 ${hub.memberCount} farmers',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : AppColors.inkSoft,
                  ),
                ),
                SizedBox(
                  height: 38,
                  child: hub.isMember
                      ? OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? const Color(0xFF2E4D37) : const Color(0xFFCCE4C5),
                            ),
                            backgroundColor: isDark ? const Color(0xFF192A1F) : const Color(0xFFF0FDF4),
                            foregroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onPressed: () => _confirmLeave(context, ref),
                          icon: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primaryGreen),
                          label: const Text(
                            'Joined ✓',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        )
                      : DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            onPressed: () async {
                              try {
                                await ref.read(communityHubsProvider.notifier).toggleJoin(
                                      hub.id,
                                      currentIsMember: false,
                                      currentMemberCount: hub.memberCount,
                                    );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Joined "${hub.name}"!'),
                                      action: SnackBarAction(
                                        label: 'View',
                                        onPressed: () {
                                          context.push('/community/hub/${hub.id}');
                                        },
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to join: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text('+ Join Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}

class _EmptyHubsCard extends StatelessWidget {
  const _EmptyHubsCard({
    required this.title,
    required this.desc,
    this.buttonLabel,
    this.onButtonTap,
    required this.isDark,
  });

  final String title;
  final String desc;
  final String? buttonLabel;
  final VoidCallback? onButtonTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18261E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF2C3E32) : const Color(0xFFE2EBE0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore_off_rounded, size: 36, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.inkSoft,
              height: 1.4,
            ),
          ),
          if (buttonLabel != null && onButtonTap != null) ...[
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onButtonTap,
              child: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Location Picker Sheet ───────────────────────────────────────────
class _LocationPickerSheet extends ConsumerStatefulWidget {
  const _LocationPickerSheet();

  @override
  ConsumerState<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  static const _popularDistricts = [
    'Nagpur', 'Wardha', 'Amravati', 'Pune', 'Nashik', 'Chhatrapati Sambhajinagar', 'Kolhapur', 'Solapur', 'Akola', 'Nanded', 'Satara'
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentDistrict = ref.watch(selectedDistrictProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B281F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select District Area',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.inkDark,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white70 : AppColors.inkSoft),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            if (WeatherService.lastResolvedCity != null && WeatherService.lastResolvedCity!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  ref.read(selectedDistrictProvider.notifier).state = WeatherService.lastResolvedCity!.trim();
                  ref.read(communityHubsProvider.notifier).fetchHubs();
                  ref.invalidate(suggestedHubsProvider);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.my_location_rounded, color: AppColors.primaryGreen, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Use GPS Location: ${WeatherService.lastResolvedCity}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularDistricts.map((d) {
                final isSelected = currentDistrict.toLowerCase() == d.toLowerCase();
                return ChoiceChip(
                  label: Text(d),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.inkDark),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: isDark ? Colors.black26 : const Color(0xFFF1F5F9),
                  side: BorderSide(
                    color: isSelected ? AppColors.primaryGreen : (isDark ? const Color(0xFF2C3E32) : Colors.black12),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedDistrictProvider.notifier).state = d;
                      ref.read(communityHubsProvider.notifier).fetchHubs();
                      ref.invalidate(suggestedHubsProvider);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
