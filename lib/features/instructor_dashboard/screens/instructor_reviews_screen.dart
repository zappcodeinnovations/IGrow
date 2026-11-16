import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../home_instructor/providers/instructor_home_provider.dart';

class InstructorReviewItem {
  final String id;
  final String studentName;
  final String? studentAvatar;
  final String courseTitle;
  final int rating;
  final String date;
  final String content;
  final bool hasReply;
  final String? replyContent;

  const InstructorReviewItem({
    required this.id,
    required this.studentName,
    this.studentAvatar,
    required this.courseTitle,
    required this.rating,
    required this.date,
    required this.content,
    this.hasReply = false,
    this.replyContent,
  });

  static String _formatDate(dynamic dateRaw) {
    if (dateRaw == null) return 'Recently';
    try {
      final dt = DateTime.parse(dateRaw.toString()).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes <= 1 ? 1 : diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return dateRaw.toString();
    }
  }

  factory InstructorReviewItem.fromJson(Map<String, dynamic> json) {
    final rawDate = json['created_at'];
    final reply = (json['instructor_reply'] ?? json['reply'] ?? json['reply_content'])?.toString();
    final hasReply = reply != null && reply.trim().isNotEmpty;

    return InstructorReviewItem(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? 'Student',
      studentAvatar: json['student_avatar'] as String?,
      courseTitle: json['course_title']?.toString() ?? 'Course',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      date: _formatDate(rawDate),
      content: json['comment']?.toString() ?? json['content']?.toString() ?? '',
      hasReply: hasReply,
      replyContent: hasReply ? reply : null,
    );
  }

  InstructorReviewItem copyWith({
    bool? hasReply,
    String? replyContent,
  }) {
    return InstructorReviewItem(
      id: id,
      studentName: studentName,
      studentAvatar: studentAvatar,
      courseTitle: courseTitle,
      rating: rating,
      date: date,
      content: content,
      hasReply: hasReply ?? this.hasReply,
      replyContent: replyContent ?? this.replyContent,
    );
  }
}

class InstructorReviewsScreen extends ConsumerStatefulWidget {
  const InstructorReviewsScreen({super.key});

  @override
  ConsumerState<InstructorReviewsScreen> createState() => _InstructorReviewsScreenState();
}

class _InstructorReviewsScreenState extends ConsumerState<InstructorReviewsScreen> {
  String _selectedFilter = 'ALL';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _replyingToId;
  final _replyController = TextEditingController();
  bool _isSubmittingReply = false;

  @override
  void dispose() {
    _searchController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply(String reviewId) async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSubmittingReply) return;

    setState(() => _isSubmittingReply = true);
    try {
      final repo = ref.read(instructorRepositoryProvider);
      await repo.replyToReview(reviewId, text);
      ref.invalidate(instructorReviewsProvider);

      setState(() {
        _replyingToId = null;
        _replyController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reply posted successfully! 💬'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post reply: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingReply = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reviewsAsync = ref.watch(instructorReviewsProvider);
    final statsAsync = ref.watch(instructorStatsProvider);

    final rawReviews = reviewsAsync.value ?? [];
    final List<InstructorReviewItem> allReviews = rawReviews
        .map((r) => InstructorReviewItem.fromJson(r))
        .toList();

    final totalReviews = allReviews.length;
    final double avgRating = allReviews.isNotEmpty
        ? (allReviews.map((r) => r.rating).reduce((a, b) => a + b) / allReviews.length)
        : ((statsAsync.value?['average_rating'] as num?)?.toDouble() ?? 5.0);

    // Filter reviews
    final filteredReviews = allReviews.where((review) {
      if (_selectedFilter != 'ALL') {
        if (_selectedFilter == 'UNREPLIED' && review.hasReply) return false;
        if (['5', '4', '3', '2', '1'].contains(_selectedFilter) &&
            review.rating != int.tryParse(_selectedFilter)) {
          return false;
        }
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = review.studentName.toLowerCase().contains(q);
        final matchCourse = review.courseTitle.toLowerCase().contains(q);
        final matchContent = review.content.toLowerCase().contains(q);
        if (!matchName && !matchCourse && !matchContent) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF9FBF8),
      appBar: AppBar(
        title: const Text(
          'Reviews & Ratings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: isDark ? AppColors.bgDark : Colors.white,
        foregroundColor: isDark ? Colors.white : AppColors.inkDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Reviews',
            onPressed: () => ref.invalidate(instructorReviewsProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(instructorReviewsProvider);
          await ref.read(instructorReviewsProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── 1. Header Metrics Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitor Student Feedback',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Average Rating',
                            value: '${avgRating.toStringAsFixed(1)} ★',
                            subtitle: 'Across all courses',
                            icon: Icons.star_rounded,
                            iconColor: AppColors.signalYellow,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            title: 'Total Reviews',
                            value: '$totalReviews',
                            subtitle: 'Verified learners',
                            icon: Icons.reviews_outlined,
                            iconColor: AppColors.primaryGreen,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. Search & Filter Bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Search Box
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search reviews by student or course...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : AppColors.inkSoft,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppColors.cardDark : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : AppColors.lineLight,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.white12 : AppColors.lineLight,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', 'All Ratings', isDark),
                          const SizedBox(width: 8),
                          _buildFilterChip('5', '5 Stars ⭐', isDark),
                          const SizedBox(width: 8),
                          _buildFilterChip('4', '4 Stars ⭐', isDark),
                          const SizedBox(width: 8),
                          _buildFilterChip('3', '3 Stars ⭐', isDark),
                          const SizedBox(width: 8),
                          _buildFilterChip('UNREPLIED', 'Unreplied Only', isDark),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 3. Reviews List ──
            if (reviewsAsync.isLoading && allReviews.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                ),
              )
            else if (reviewsAsync.hasError && allReviews.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        const Text(
                          'Unable to load reviews',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          onPressed: () => ref.invalidate(instructorReviewsProvider),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (filteredReviews.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty || _selectedFilter != 'ALL'
                            ? Icons.search_off_rounded
                            : Icons.rate_review_outlined,
                        size: 48,
                        color: isDark ? Colors.white30 : AppColors.inkSoft,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isNotEmpty || _selectedFilter != 'ALL'
                            ? 'No matching reviews found'
                            : 'No student reviews yet',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _searchQuery.isNotEmpty || _selectedFilter != 'ALL'
                            ? 'Try adjusting your search terms or filters.'
                            : 'When enrolled students rate and review your courses, they will appear here.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final review = filteredReviews[index];
                      final isReplying = _replyingToId == review.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white10 : AppColors.lineLight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Avatar, Name, Course Badge, Stars
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                                  child: Text(
                                    review.studentName.isNotEmpty ? review.studentName[0].toUpperCase() : 'S',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            review.studentName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: isDark ? Colors.white : AppColors.inkDark,
                                            ),
                                          ),
                                          Text(
                                            review.date,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.inkSoft,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGreen.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          review.courseTitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Rating Stars
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: i < review.rating ? AppColors.signalYellow : Colors.grey.shade300,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Review Content
                            Text(
                              review.content,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: isDark ? Colors.white70 : AppColors.inkDark,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Existing Instructor Reply (if any)
                            if (review.hasReply && review.replyContent != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.12 : 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.reply_rounded, size: 14, color: AppColors.primaryGreen),
                                        SizedBox(width: 6),
                                        Text(
                                          'Your Reply',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      review.replyContent!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: isDark ? Colors.white70 : AppColors.inkDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Reply Form / Toggle
                            if (isReplying) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? Colors.white12 : AppColors.lineLight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Write a Reply:',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _replyController,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: isDark ? Colors.white : AppColors.inkDark,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Thank the student or address their feedback...',
                                        hintStyle: TextStyle(
                                          fontSize: 12.5,
                                          color: isDark ? Colors.white38 : AppColors.inkSoft,
                                        ),
                                        filled: true,
                                        fillColor: isDark ? AppColors.cardDark : Colors.white,
                                        contentPadding: const EdgeInsets.all(10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: isDark ? Colors.white12 : AppColors.lineLight,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: _isSubmittingReply
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _replyingToId = null;
                                                    _replyController.clear();
                                                  });
                                                },
                                          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.primaryGreen,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          ),
                                          onPressed: _isSubmittingReply
                                              ? null
                                              : () => _sendReply(review.id),
                                          child: _isSubmittingReply
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                )
                                              : const Text('Send Reply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ] else if (!review.hasReply) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primaryGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(Icons.reply_rounded, size: 16),
                                  label: const Text('Reply to Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                  onPressed: () {
                                    setState(() {
                                      _replyingToId = review.id;
                                      _replyController.clear();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    childCount: filteredReviews.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white10 : AppColors.lineLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkSoft,
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.inkDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isDark) {
    final isSelected = _selectedFilter == value;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : AppColors.inkDark),
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = value),
      selectedColor: AppColors.primaryGreen,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      side: BorderSide(
        color: isSelected
            ? AppColors.primaryGreen
            : (isDark ? Colors.white12 : AppColors.lineLight),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }
}
