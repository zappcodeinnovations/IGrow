import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/wishlist_model.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/explore_provider.dart';
import '../widgets/course_review_modal.dart';

class CourseDetailsScreen extends ConsumerStatefulWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
  }

  void _initializePlayer(String videoUrl) async {
    if (_videoPlayerController != null) return; // Already initializing or initialized
    
    if (videoUrl.startsWith('http')) {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    } else {
      _videoPlayerController = VideoPlayerController.file(File(videoUrl));
    }
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: true,
      allowFullScreen: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryGreen,
        handleColor: AppColors.primaryGreen,
        backgroundColor: AppColors.lineLight,
        bufferedColor: AppColors.canopyStart,
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isSaved = ref.watch(isWishlistedProvider(widget.courseId));
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? Colors.redAccent : null,
                ),
                tooltip: isSaved ? 'Remove from Wishlist' : 'Add to Wishlist',
                onPressed: () async {
                  try {
                    final course = courseAsync.value;
                    final preview = course != null
                        ? ApiWishlistItem(
                            id: '',
                            targetId: widget.courseId,
                            type: 'course',
                            title: course.title,
                            slug: course.slug ?? '',
                            thumbnail: course.thumbnail,
                            price: course.price ?? '0.00',
                            category: course.categoryDisplay ?? course.category ?? 'General',
                            rating: 4.8,
                          )
                        : null;
                    final inWishlist = await ref
                        .read(wishlistProvider.notifier)
                        .toggleCourse(widget.courseId, previewItem: preview);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(inWishlist
                              ? 'Added to wishlist! ❤️'
                              : 'Removed from wishlist'),
                          duration: const Duration(milliseconds: 1800),
                          backgroundColor: inWishlist
                              ? AppColors.primaryGreen
                              : AppColors.inkDark,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: courseAsync.when(
        data: (course) {
          // Find first available video URL
          String? videoUrl = course.previewVideoUrl;
          if (videoUrl == null || videoUrl.isEmpty) {
            for (var section in course.sections) {
              for (var lecture in section.lectures) {
                if (lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty) {
                  videoUrl = lecture.videoUrl;
                  break;
                }
              }
              if (videoUrl != null && videoUrl.isNotEmpty) break;
            }
          }
          
          if (videoUrl != null && videoUrl.isNotEmpty) {
            _initializePlayer(videoUrl);
          }

          return _buildContent(context, isDark, 
            title: course.title,
            slug: course.slug ?? widget.courseId,
            description: course.shortDescription ?? course.description ?? 'No description available.',
            price: course.price == '0.00' ? 'Free' : '₹${course.price}',
            instructor: course.instructorName ?? 'Unknown Instructor',
            hasVideo: videoUrl != null && videoUrl.isNotEmpty,
            isEnrolled: course.isEnrolled == true,
          );
        },
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerContainer(width: double.infinity, height: 250, borderRadius: 0),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerContainer(width: 100, height: 24),
                  const SizedBox(height: 12),
                  const ShimmerContainer(width: 250, height: 28),
                  const SizedBox(height: 8),
                  const ShimmerContainer(width: 150, height: 16),
                  const SizedBox(height: 16),
                  const ShimmerContainer(width: double.infinity, height: 40),
                  const Divider(height: 40),
                  const ShimmerContainer(width: 150, height: 24),
                  const SizedBox(height: 12),
                  const ShimmerContainer(width: double.infinity, height: 100),
                ],
              ),
            ),
          ],
        ),
        error: (err, _) {
          return Center(child: Text('Error: $err'));
        },
      ),
      bottomNavigationBar: courseAsync.maybeWhen(
        data: (course) {
          final isEnrolled = course.isEnrolled == true;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isEnrolled
                  ? SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.play_circle_filled),
                        label: const Text(
                          'Start Learning (Enrolled)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        onPressed: () =>
                            context.push('/player/${widget.courseId}'),
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await ref
                                    .read(cartProvider.notifier)
                                    .addToCart(widget.courseId);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Course added to cart! 🛒'),
                                      duration: Duration(milliseconds: 1800),
                                      backgroundColor: AppColors.primaryGreen,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e
                                          .toString()
                                          .replaceAll("Exception: ", "")),
                                      duration:
                                          const Duration(milliseconds: 2000),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.push(
                                  '/checkout?courseId=${widget.courseId}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Buy Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, {
    required String title,
    required String slug,
    required String description,
    required String price,
    required String instructor,
    required bool hasVideo,
    required bool isEnrolled,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Preview Area
          if (hasVideo)
            Container(
              width: double.infinity,
              height: 250,
              color: Colors.black,
              child: _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
            )
          else
            Container(
              width: double.infinity,
              height: 250,
              color: AppColors.lineLight,
              child: const Center(
                child: Text('No Preview Available', style: TextStyle(color: AppColors.inkSoft)),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Preview Available',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Instructor: $instructor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.signalYellow, size: 20),
                    const SizedBox(width: 4),
                    const Text('4.8 (120 reviews)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 40),
                Text(
                  'About This Course',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Dummy Course Includes section
                Text(
                  'Course Includes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildIncludeItem(Icons.ondemand_video, '5 hours on-demand video'),
                _buildIncludeItem(Icons.insert_drive_file_outlined, '12 downloadable resources'),
                _buildIncludeItem(Icons.all_inclusive, 'Full lifetime access'),
                _buildIncludeItem(Icons.smartphone, 'Access on mobile and web'),
                _buildIncludeItem(Icons.emoji_events_outlined, 'Certificate of completion'),
                const Divider(height: 40),

                // Student Feedback Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Student Feedback',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isEnrolled)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                        ),
                        onPressed: () => CourseReviewModal.show(
                          context,
                          courseId: widget.courseId,
                          courseSlug: slug,
                          courseTitle: title,
                        ),
                        icon: const Icon(Icons.rate_review_outlined, size: 18),
                        label: const Text(
                          'Write a Review',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer(
                  builder: (context, ref, _) {
                    final reviewsAsync = ref.watch(courseReviewsProvider(slug));
                    return reviewsAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: AppColors.primaryGreen),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (reviews) {
                        if (reviews.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.white10 : AppColors.lineLight),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.inkSoft, size: 32),
                                const SizedBox(height: 8),
                                const Text(
                                  'No reviews yet. Be the first to review after enrolling!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
                                ),
                                if (isEnrolled) ...[
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => CourseReviewModal.show(
                                      context,
                                      courseId: widget.courseId,
                                      courseSlug: slug,
                                      courseTitle: title,
                                    ),
                                    icon: const Icon(Icons.star_rounded, size: 18),
                                    label: const Text('Leave a Review'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: reviews.map((review) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E231F) : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? Colors.white10 : AppColors.lineLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                                        backgroundImage: review.studentAvatar != null && review.studentAvatar!.isNotEmpty
                                            ? NetworkImage(review.studentAvatar!)
                                            : null,
                                        child: review.studentAvatar == null || review.studentAvatar!.isEmpty
                                            ? Text(
                                                review.studentName.isNotEmpty ? review.studentName[0].toUpperCase() : 'U',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryGreen,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review.studentName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            Row(
                                              children: [
                                                ...List.generate(5, (sIdx) {
                                                  return Icon(
                                                    sIdx < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                                    size: 14,
                                                    color: sIdx < review.rating ? const Color(0xFFFFB800) : Colors.grey.shade400,
                                                  );
                                                }),
                                                if (review.createdAt != null) ...[
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    DateFormat.yMMMd().format(review.createdAt!),
                                                    style: const TextStyle(color: AppColors.inkSoft, fontSize: 11),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (review.comment.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      review.comment,
                                      style: TextStyle(
                                        color: isDark ? Colors.white70 : AppColors.inkDark,
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIncludeItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.inkSoft),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : AppColors.inkDark)),
        ],
      ),
    );
  }
}
