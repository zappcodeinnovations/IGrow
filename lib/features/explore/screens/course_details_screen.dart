import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../cart/providers/cart_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../providers/explore_provider.dart';
import '../../../core/widgets/shimmer_placeholders.dart';

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
            description: course.shortDescription ?? course.description ?? 'No description available.',
            price: course.price == '0.00' ? 'Free' : '₹${course.price}',
            instructor: course.instructorName ?? 'Unknown Instructor',
            hasVideo: videoUrl != null && videoUrl.isNotEmpty,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(cartProvider.notifier).addToCart(widget.courseId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not add to cart: $e')),
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
                    // Navigate to checkout or player (assuming enrolled for dummy)
                    context.push('/player/${widget.courseId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Enroll Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, {
    required String title,
    required String description,
    required String price,
    required String instructor,
    required bool hasVideo,
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
                    color: AppColors.primaryGreen.withOpacity(0.1),
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
