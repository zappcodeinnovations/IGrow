import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/community_models.dart';
import '../providers/community_provider.dart';

class HubMembersSheet extends ConsumerStatefulWidget {
  const HubMembersSheet({
    super.key,
    required this.hub,
    this.scrollController,
  });

  final CommunityHub hub;
  final ScrollController? scrollController;

  static void show(BuildContext context, CommunityHub hub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16231A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: HubMembersSheet(
                hub: hub,
                scrollController: scrollController,
              ),
            );
          },
        );
      },
    );
  }

  @override
  ConsumerState<HubMembersSheet> createState() => _HubMembersSheetState();
}

class _HubMembersSheetState extends ConsumerState<HubMembersSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final membersAsync = ref.watch(hubMembersProvider(widget.hub.id));

    return Column(
      children: [
        // Top Drag Handle
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Header Title Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group_rounded,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'Community Members'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.inkDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.hub.memberCount} ${tr(ref, "farmers & learners joined")}',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                color: isDark ? Colors.white70 : Colors.black54,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: TextField(
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim().toLowerCase();
              });
            },
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: tr(ref, 'Search members by name or district...'),
              hintStyle: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white38 : AppColors.inkSoft.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryGreen),
              filled: true,
              fillColor: isDark ? const Color(0xFF1F3124) : const Color(0xFFF1F6F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
        ),

        const Divider(height: 1, thickness: 1),

        // Members List View
        Expanded(
          child: membersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.orange, size: 36),
                    const SizedBox(height: 10),
                    Text(
                      tr(ref, 'Unable to load member list'),
                      style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkDark),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      onPressed: () => ref.invalidate(hubMembersProvider(widget.hub.id)),
                      child: Text(tr(ref, 'Retry')),
                    ),
                  ],
                ),
              ),
            ),
            data: (members) {
              final filtered = members.where((m) {
                if (_searchQuery.isEmpty) return true;
                final nameMatches = m.name.toLowerCase().contains(_searchQuery);
                final locationMatches = m.location?.toLowerCase().contains(_searchQuery) ?? false;
                final roleMatches = m.role.toLowerCase().contains(_searchQuery);
                return nameMatches || locationMatches || roleMatches;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 48,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? tr(ref, 'No members found matching search')
                              : tr(ref, 'No members enrolled yet'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : AppColors.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  height: 14,
                  thickness: 0.8,
                  color: isDark ? const Color(0xFF243628) : const Color(0xFFE8EFE6),
                ),
                itemBuilder: (context, index) {
                  final member = filtered[index];
                  return _MemberTile(member: member, isDark: isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isDark,
  });

  final HubMember member;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
            backgroundImage: member.avatar != null && member.avatar!.isNotEmpty
                ? CachedNetworkImageProvider(member.avatar!)
                : null,
            child: (member.avatar == null || member.avatar!.isEmpty)
                ? Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : 'F',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isHost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Host',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (member.location != null && member.location!.isNotEmpty) ...[
                      Icon(Icons.location_on_outlined, size: 12, color: isDark ? Colors.white60 : AppColors.inkSoft),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          member.location!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : AppColors.inkSoft,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      member.joinedAt != null ? 'Joined ${member.joinedAt}' : 'Active member',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.white38 : AppColors.inkSoft.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Role / Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF223627) : const Color(0xFFEFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              member.role.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
