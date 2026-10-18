import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/community_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/community_provider.dart';

/// Community screen — with Regional Hubs, Location Filter, Rich Posts & Threaded Comments.
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  String _selectedFilter = 'ALL'; // 'ALL', 'SEMINARS', 'MEETINGS', 'ADVISORY'

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
    final currentState = ref.watch(selectedStateProvider);
    final currentDistrict = ref.watch(selectedDistrictProvider);
    final hubsAsync = ref.watch(communityHubsProvider);
    final postsAsync = ref.watch(communityPostsProvider);
    final currentUser = ref.watch(authProvider).user;
    final isInstructor = currentUser?.isInstructor == true || currentUser?.isAdmin == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF7FAF6),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async {
            await Future.wait([
              ref.read(communityHubsProvider.notifier).fetchHubs(),
              ref.read(communityPostsProvider.notifier).refreshPosts(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ─── Header: Title & Action Buttons ───────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Community',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                  letterSpacing: -0.5,
                                ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Connect with local farmers & experts',
                            style: TextStyle(
                              color: AppColors.inkSoft,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isInstructor) ...[
                            IconButton.filledTonal(
                              tooltip: 'Create Hub',
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF263B2B) : const Color(0xFFEAF5E7),
                                foregroundColor: AppColors.primaryGreen,
                              ),
                              icon: const Icon(Icons.hub_rounded, size: 20),
                              onPressed: () => context.push(RouteNames.createHub),
                            ),
                            const SizedBox(width: 8),
                          ],
                          GestureDetector(
                            onTap: () => context.push(RouteNames.createPost),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Location Selector Bar ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF5E7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.location_on_rounded, color: AppColors.primaryGreen, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Regional Hub Area',
                                style: TextStyle(color: AppColors.inkSoft, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '$currentDistrict, $currentState',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _showLocationPicker(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF263B2B) : const Color(0xFFEBF5E7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFCCE4C5), width: 1),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Change',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 2),
                                Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primaryGreen),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Regional Community Hubs Carousel ────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Regional Hubs ($currentDistrict)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.inkDark,
                            ),
                          ),
                          hubsAsync.maybeWhen(
                            data: (hubs) => Text(
                              '${hubs.length} Active',
                              style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 145,
                      child: hubsAsync.when(
                        data: (hubs) {
                          if (hubs.isEmpty) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDark : AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFE2EBE0), width: 1),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.inkSoft),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'No specific hubs registered for $currentDistrict yet. You can still see all discussions below!',
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: hubs.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final hub = hubs[index];
                              return _HubCarouselCard(hub: hub);
                            },
                          );
                        },
                        loading: () => ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, __) => const ShimmerContainer(width: 250, height: 145, borderRadius: 16),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Filter Pills ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Discussions',
                          icon: Icons.forum_rounded,
                          isSelected: _selectedFilter == 'ALL',
                          onTap: () => setState(() => _selectedFilter = 'ALL'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Seminars',
                          icon: Icons.event_rounded,
                          color: const Color(0xFF2E7D32),
                          isSelected: _selectedFilter == 'SEMINARS',
                          onTap: () => setState(() => _selectedFilter = 'SEMINARS'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Webinars',
                          icon: Icons.videocam_rounded,
                          color: const Color(0xFF1565C0),
                          isSelected: _selectedFilter == 'MEETINGS',
                          onTap: () => setState(() => _selectedFilter = 'MEETINGS'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Advisories',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFE65100),
                          isSelected: _selectedFilter == 'ADVISORY',
                          onTap: () => setState(() => _selectedFilter = 'ADVISORY'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── Discussion Feed ─────────────────────────────────
              postsAsync.when(
                data: (posts) {
                  var filteredPosts = posts;
                  if (_selectedFilter == 'SEMINARS') {
                    filteredPosts = posts.where((p) => p.postType == 'OFFLINE_SEMINAR').toList();
                  } else if (_selectedFilter == 'MEETINGS') {
                    filteredPosts = posts.where((p) => p.postType == 'ONLINE_MEETING').toList();
                  } else if (_selectedFilter == 'ADVISORY') {
                    filteredPosts = posts.where((p) => p.postType == 'ADVISORY').toList();
                  }

                  if (filteredPosts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.forum_outlined,
                                size: 54,
                                color: AppColors.inkSoft.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No posts in this category yet',
                                style: TextStyle(
                                  color: AppColors.inkDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tap the + button to share updates with the community!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = filteredPosts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _PostCard(
                              post: post,
                              onLike: () async {
                                final success = await ref
                                    .read(communityPostsProvider.notifier)
                                    .toggleLike(post.id);
                                if (context.mounted && !success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to like post. Check connection.'),
                                      duration: Duration(milliseconds: 1500),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        childCount: filteredPosts.length,
                      ),
                    ),
                  );
                },
                loading: () => SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 14),
                        child: _ShimmerPostCard(),
                      ),
                      childCount: 3,
                    ),
                  ),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Column(
                        children: [
                          Text('Failed to load posts: $err', style: const TextStyle(color: AppColors.error)),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => ref.read(communityPostsProvider.notifier).refreshPosts(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Regional Hub Carousel Card ────────────────────────────────────

class _HubCarouselCard extends ConsumerWidget {
  const _HubCarouselCard({required this.hub});
  final CommunityHub hub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        context.push(RouteNames.hubDetails.replaceAll(':id', hub.id));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.lineDark : const Color(0xFFE0EAE0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5E7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFCEE6C5)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: (hub.logo != null && hub.logo!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: hub.logo!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(Icons.agriculture, color: AppColors.primaryGreen),
                          )
                        : const Icon(Icons.agriculture, color: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hub.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${hub.memberCount} Members',
                        style: const TextStyle(
                          color: AppColors.inkSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hub.farmingTopics.isNotEmpty)
              Text(
                '🌾 ${hub.farmingTopics.take(2).join(", ")}',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hub.districts.isNotEmpty ? hub.districts.first : hub.state,
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.inkSoft),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await ref.read(communityHubsProvider.notifier).toggleJoin(hub.id);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: hub.isMember ? const Color(0xFFEAF5E7) : AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: hub.isMember ? Border.all(color: AppColors.primaryGreen) : null,
                    ),
                    child: Text(
                      hub.isMember ? 'Joined' : 'Join',
                      style: TextStyle(
                        color: hub.isMember ? AppColors.primaryGreen : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Chip Widget ────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.color = AppColors.primaryGreen,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : (isDark ? AppColors.cardDark : AppColors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : (isDark ? AppColors.lineDark : const Color(0xFFE0EAE0)),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.inkDark),
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Picker Bottom Sheet ──────────────────────────────────

class _LocationPickerSheet extends ConsumerStatefulWidget {
  const _LocationPickerSheet();

  @override
  ConsumerState<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<_LocationPickerSheet> {
  final List<String> _states = ['Maharashtra', 'Gujarat', 'Karnataka', 'Madhya Pradesh', 'Punjab', 'Rajasthan'];
  final Map<String, List<String>> _districtsByState = {
    'Maharashtra': ['Pune', 'Nashik', 'Nagpur', 'Kolhapur', 'Satara', 'Ahmednagar', 'Solapur', 'Aurangabad'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Rajkot', 'Vadodara', 'Bhavnagar'],
    'Karnataka': ['Bangalore', 'Belagavi', 'Mysuru', 'Dharwad', 'Hubli'],
    'Madhya Pradesh': ['Indore', 'Bhopal', 'Ujjain', 'Jabalpur'],
    'Punjab': ['Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Kota', 'Bikaner'],
  };

  late String _tempState;
  late String _tempDistrict;

  @override
  void initState() {
    super.initState();
    _tempState = ref.read(selectedStateProvider);
    _tempDistrict = ref.read(selectedDistrictProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final districts = _districtsByState[_tempState] ?? ['Default'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primaryGreen, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Select Your Region',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Switching region shows hubs and localized farming advisories for that area.',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 12.5),
            ),
            const SizedBox(height: 18),

            // State Selector
            const Text('State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE6DA)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _states.contains(_tempState) ? _tempState : _states.first,
                  items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _tempState = val;
                        _tempDistrict = (_districtsByState[val] ?? ['Central']).first;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // District Selector
            const Text('District', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDCE6DA)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: districts.contains(_tempDistrict) ? _tempDistrict : districts.first,
                  items: districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _tempDistrict = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                ref.read(selectedStateProvider.notifier).state = _tempState;
                ref.read(selectedDistrictProvider.notifier).state = _tempDistrict;
                Navigator.pop(context);
              },
              child: const Text('Apply Region Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Post Card Component with Rich Post Types ──────────────────────

class _PostCard extends ConsumerWidget {
  const _PostCard({
    required this.post,
    required this.onLike,
  });

  final CommunityPost post;
  final VoidCallback onLike;

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Post deleted.' : 'Failed to delete post.'),
                    backgroundColor: success ? AppColors.primaryGreen : AppColors.error,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(authProvider).user;
    final isAuthor = (currentUser != null && currentUser.id == post.author.id) ||
        currentUser?.isAdmin == true ||
        currentUser?.isInstructor == true;

    final isAdvisory = post.postType == 'ADVISORY';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAdvisory
              ? const Color(0xFFFFB74D)
              : (isDark ? AppColors.lineDark : const Color(0xFFE2EBE0)),
          width: isAdvisory ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAdvisory
                ? Colors.orange.withValues(alpha: 0.08)
                : AppColors.primaryGreen.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: post.author.isExpert
                    ? AppColors.accentOrange.withValues(alpha: 0.15)
                    : const Color(0xFFEAF5E7),
                backgroundImage: post.author.avatarUrl != null
                    ? CachedNetworkImageProvider(post.author.avatarUrl!)
                    : null,
                child: post.author.avatarUrl == null
                    ? Icon(
                        post.author.isExpert ? Icons.verified_user_rounded : Icons.person_rounded,
                        color: post.author.isExpert ? AppColors.accentOrange : AppColors.primaryGreen,
                        size: 20,
                      )
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
                            post.author.fullName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.inkDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.author.isExpert) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 14, color: AppColors.accentOrange),
                        ],
                      ],
                    ),
                    Text(
                      timeago.format(post.createdAt),
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _PostTypeBadge(postType: post.postType),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.inkSoft),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (val) {
                  if (val == 'delete') {
                    _confirmDelete(context, ref);
                  } else if (val == 'share') {
                    _sharePost(context, post);
                  }
                },
                itemBuilder: (ctx) => [
                  if (isAuthor)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                          SizedBox(width: 8),
                          Text('Delete Post', style: TextStyle(color: AppColors.error, fontSize: 13)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
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
          const SizedBox(height: 12),

          // Title & Body
          if (post.title.isNotEmpty) ...[
            Text(
              post.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.5,
                color: isDark ? Colors.white : AppColors.inkDark,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            post.content,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: isDark ? const Color(0xFFCAD6CA) : const Color(0xFF2C392A),
            ),
          ),

          // ─── Rich Specialized CTA Cards ──────────────────────────
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
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: post.image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerContainer(width: double.infinity, height: 200, borderRadius: 14),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Footer Actions
          Row(
            children: [
              InkWell(
                onTap: onLike,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: post.isLikedByMe ? Colors.red : AppColors.inkSoft,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: post.isLikedByMe ? Colors.red : AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 18),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _ThreadedCommentsSheet(post: post),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.inkSoft, size: 19),
                      const SizedBox(width: 5),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 19, color: AppColors.inkSoft),
                onPressed: () => _sharePost(context, post),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Post Type Badges & Banners ────────────────────────────────────

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
        icon = Icons.chat_bubble_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
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
      margin: const EdgeInsets.only(top: 10, bottom: 4),
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
                  '${post.eventDate!.day}/${post.eventDate!.month}/${post.eventDate!.year} • ${post.eventDate!.hour}:${post.eventDate!.minute.toString().padLeft(2, '0')}',
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
      margin: const EdgeInsets.only(top: 10, bottom: 4),
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
      margin: const EdgeInsets.only(top: 10, bottom: 4),
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
            label: const Text('Enroll', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: onEnroll,
          ),
        ],
      ),
    );
  }
}

// ─── Threaded & Nested Comments Modal Sheet ────────────────────────

class _ThreadedCommentsSheet extends ConsumerStatefulWidget {
  const _ThreadedCommentsSheet({required this.post});
  final CommunityPost post;

  @override
  ConsumerState<_ThreadedCommentsSheet> createState() => _ThreadedCommentsSheetState();
}

class _ThreadedCommentsSheetState extends ConsumerState<_ThreadedCommentsSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  CommunityComment? _replyingToComment;
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
          : 'Farmer',
      isExpert: currentUser?.isInstructor == true || currentUser?.isAdmin == true,
      avatarUrl: currentUser?.avatarUrl,
      role: (currentUser?.isInstructor == true) ? 'INSTRUCTOR' : 'STUDENT',
    );

    setState(() => _isSubmitting = true);
    final parentId = _replyingToComment?.id;

    _commentController.clear();
    setState(() => _replyingToComment = null);

    try {
      await ref.read(postCommentsProvider(widget.post.id).notifier).addComment(
            text: text,
            author: author,
            parentId: parentId,
          );
      ref.read(communityPostsProvider.notifier).incrementCommentsCount(widget.post.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e')),
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Comments & Discussion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF5E7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.post.commentsCount}',
                        style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.inkSoft),
                          SizedBox(height: 10),
                          Text('No comments yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 4),
                          Text('Be the first to ask a question or leave advice!', style: TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  );
                }

                // Partition comments into parent and children
                final parentComments = comments.where((c) => c.parentId == null || c.parentId!.isEmpty).toList();

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: parentComments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final parent = parentComments[index];
                    final replies = comments.where((c) => c.parentId == parent.id).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CommentItem(
                          comment: parent,
                          isReply: false,
                          onReplyTap: () {
                            setState(() => _replyingToComment = parent);
                          },
                        ),
                        if (replies.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Column(
                              children: replies.map((reply) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _CommentItem(
                                    comment: reply,
                                    isReply: true,
                                    onReplyTap: () {
                                      setState(() => _replyingToComment = parent);
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),

          // Active Reply Banner (If user tapped reply)
          if (_replyingToComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? const Color(0xFF233526) : const Color(0xFFEBF5E7),
              child: Row(
                children: [
                  const Icon(Icons.reply_rounded, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Replying to @${_replyingToComment!.author.fullName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primaryGreen),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => setState(() => _replyingToComment = null),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.white,
              border: Border(top: BorderSide(color: isDark ? AppColors.lineDark : const Color(0xFFE2EBE0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: _replyingToComment != null
                          ? 'Write a reply...'
                          : 'Write a comment or advice...',
                      hintStyle: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                      filled: true,
                      fillColor: isDark ? AppColors.bgDark : const Color(0xFFF1F5EF),
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

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.isReply,
    required this.onReplyTap,
  });

  final CommunityComment comment;
  final bool isReply;
  final VoidCallback onReplyTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isInstructor = comment.authorRole == 'INSTRUCTOR' || comment.author.isExpert;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isReply ? 14 : 17,
          backgroundColor: isInstructor ? const Color(0xFFFFF3E0) : const Color(0xFFEAF5E7),
          backgroundImage: comment.author.avatarUrl != null ? CachedNetworkImageProvider(comment.author.avatarUrl!) : null,
          child: comment.author.avatarUrl == null
              ? Icon(
                  isInstructor ? Icons.verified : Icons.person,
                  color: isInstructor ? AppColors.accentOrange : AppColors.primaryGreen,
                  size: isReply ? 14 : 17,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : (isReply ? const Color(0xFFF6FAF4) : const Color(0xFFF2F6F1)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isInstructor
                    ? const Color(0xFFFFCC80)
                    : (isDark ? AppColors.lineDark : const Color(0xFFE0EAE0)),
                width: 1,
              ),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (isInstructor) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Expert', style: TextStyle(color: AppColors.accentOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      timeago.format(comment.createdAt),
                      style: const TextStyle(color: AppColors.inkSoft, fontSize: 10.5),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFD3E0D3) : const Color(0xFF2D392B),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onReplyTap,
                  child: const Text(
                    'Reply',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _sharePost(BuildContext context, CommunityPost post) async {
  final title = post.title.isNotEmpty ? post.title : 'Agricultural Update';
  final text = '$title\n\n${post.content}\n\nShared via iAgrow App';

  try {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: title),
    );
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied post to clipboard!')),
      );
    }
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
          ShimmerContainer(width: 180, height: 14),
        ],
      ),
    );
  }
}
