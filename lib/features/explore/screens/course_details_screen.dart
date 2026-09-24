import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_placeholders.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../../data/models/api_models/wishlist_model.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../providers/explore_provider.dart';
import '../widgets/course_review_modal.dart';

/// Agrilearn Live Course View (Public Landing & Details Screen)
/// Matches Agrilearn website layout:
/// - Deep green canopy Hero Header with category, title, metrics, instructor
/// - Responsive Floating / Sidebar Purchase Card with video preview overlay
/// - "What you'll learn" card with checkmarks
/// - "Course Content" accordion with section & lecture preview playback
/// - "Description" & "Student Feedback"
/// - Role-based guard: only students can purchase/enroll in courses
class CourseDetailsScreen extends ConsumerStatefulWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  /// Resolves raw course video URLs (including Bunny iframe embed/play pages) to direct streamable URLs.
  static Future<({String primaryUrl, String? fallbackUrl, Map<String, String> headers})> resolveVideoStream(
    String rawUrl, {
    String? bunnyId,
    String? authToken,
  }) async {
    const defaultHeaders = {
      'Referer': 'https://iframe.mediadelivery.net/',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    };

    // 1. If URL is a Bunny iframe embed or mediadelivery link, scrape/resolve the direct stream
    if (rawUrl.contains('mediadelivery.net') || rawUrl.contains('/play/') || rawUrl.contains('/embed/')) {
      try {
        final res = await http.get(
          Uri.parse(rawUrl),
          headers: {
            'Referer': 'https://iagrow.zappcode.in/',
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          },
        ).timeout(const Duration(seconds: 4));

        if (res.statusCode >= 200 && res.statusCode < 300) {
          final mp4Match = RegExp(r'<meta[^>]+content="([^"]+\.mp4)"[^>]+property="og:video:url"').firstMatch(res.body) ??
                           RegExp(r'<meta[^>]+property="og:video:url"[^>]+content="([^"]+\.mp4)"').firstMatch(res.body) ??
                           RegExp(r'content="([^"]+\.mp4)"').firstMatch(res.body);
          final m3u8Match = RegExp(r'content-src="([^"]+playlist\.m3u8)"').firstMatch(res.body) ??
                            RegExp(r'"([^"]+playlist\.m3u8)"').firstMatch(res.body);

          String? mp4Url = mp4Match?.group(1);
          String? m3u8Url = m3u8Match?.group(1);

          if (m3u8Url == null && mp4Url != null && mp4Url.contains('/play_')) {
            m3u8Url = mp4Url.replaceFirst(RegExp(r'/play_[^\.]+\.mp4'), '/playlist.m3u8');
          }

          if (m3u8Url != null) {
            return (primaryUrl: m3u8Url, fallbackUrl: mp4Url, headers: defaultHeaders);
          } else if (mp4Url != null) {
            return (primaryUrl: mp4Url, fallbackUrl: null, headers: defaultHeaders);
          }
        }
      } catch (e) {
        debugPrint('⚠️ [CourseDetails] Could not scrape embed page: $e');
      }

      // Regex fallback if scraping timed out
      final playMatch = RegExp(r'/(?:play|embed)/(\d+)/([0-9a-fA-F\-]+)').firstMatch(rawUrl);
      final effectiveId = bunnyId ?? playMatch?.group(2);
      if (playMatch != null && effectiveId != null) {
        final libId = playMatch.group(1);
        final inferredM3u8 = 'https://vz-$libId.b-cdn.net/$effectiveId/playlist.m3u8';
        final fallbackM3u8 = 'https://vz-716870.b-cdn.net/$effectiveId/playlist.m3u8';
        return (primaryUrl: inferredM3u8, fallbackUrl: fallbackM3u8, headers: defaultHeaders);
      }
    }

    // 2. Direct Bunny CDN URLs
    if (rawUrl.contains('b-cdn.net')) {
      return (primaryUrl: rawUrl, fallbackUrl: null, headers: defaultHeaders);
    }

    // 3. Fallback for deprecated Google Cloud Storage sample link
    if (rawUrl.contains('commondatastorage.googleapis.com') && rawUrl.contains('BigBuckBunny.mp4')) {
      return (
        primaryUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4',
        fallbackUrl: null,
        headers: <String, String>{},
      );
    }

    // 4. Standard Direct or backend server URLs
    final Map<String, String> standardHeaders = {};
    if (rawUrl.contains('iagrow.zappcode.in') && authToken != null) {
      standardHeaders['Authorization'] = 'Bearer $authToken';
    }

    return (primaryUrl: rawUrl, fallbackUrl: null, headers: standardHeaders);
  }

  @override
  ConsumerState<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  String? _activeVideoUrl;
  bool _isPlayingVideo = false;
  bool _isLoadingVideo = false;
  bool _isAddingToCart = false;

  // Track expanded state for sections
  final Map<String, bool> _sectionExpanded = {};

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer(
    String videoUrl, {
    bool autoPlay = false,
    String? bunnyId,
  }) async {
    if (_activeVideoUrl == videoUrl && _videoPlayerController != null) {
      if (autoPlay && !_videoPlayerController!.value.isPlaying) {
        _videoPlayerController!.play();
        setState(() => _isPlayingVideo = true);
      }
      return;
    }

    _activeVideoUrl = videoUrl;
    setState(() {
      _isLoadingVideo = true;
      _isPlayingVideo = true;
    });

    final oldChewie = _chewieController;
    final oldPlayer = _videoPlayerController;
    _chewieController = null;
    _videoPlayerController = null;
    oldChewie?.dispose();
    oldPlayer?.dispose();

    try {
      if (videoUrl.startsWith('http')) {
        final token = await ref.read(tokenStorageProvider).getAccessToken();
        final resolved = await CourseDetailsScreen.resolveVideoStream(
          videoUrl,
          bunnyId: bunnyId,
          authToken: token,
        );

        bool initialized = false;

        // Attempt 1: Primary Stream URL with headers
        try {
          _videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(resolved.primaryUrl),
            httpHeaders: resolved.headers,
          );
          await _videoPlayerController!.initialize().timeout(const Duration(seconds: 10));
          initialized = true;
        } catch (e1) {
          debugPrint('⚠️ [CourseDetails] Primary video init failed ($e1). Trying fallback...');
        }

        // Attempt 2: Fallback MP4 URL if primary HLS failed
        if (!initialized && resolved.fallbackUrl != null && resolved.fallbackUrl != resolved.primaryUrl) {
          await _videoPlayerController?.dispose();
          try {
            _videoPlayerController = VideoPlayerController.networkUrl(
              Uri.parse(resolved.fallbackUrl!),
              httpHeaders: resolved.headers,
            );
            await _videoPlayerController!.initialize().timeout(const Duration(seconds: 10));
            initialized = true;
          } catch (e2) {
            debugPrint('⚠️ [CourseDetails] Fallback video init failed: $e2');
          }
        }

        // Attempt 3: No-headers retry if 401/403 occurred with headers
        if (!initialized) {
          await _videoPlayerController?.dispose();
          try {
            _videoPlayerController = VideoPlayerController.networkUrl(
              Uri.parse(resolved.primaryUrl),
            );
            await _videoPlayerController!.initialize().timeout(const Duration(seconds: 10));
            initialized = true;
          } catch (e3) {
            debugPrint('⚠️ [CourseDetails] No-header video init failed: $e3');
          }
        }

        if (!initialized) {
          throw Exception('Failed to load video stream on all attempts.');
        }
      } else {
        _videoPlayerController = VideoPlayerController.file(File(videoUrl));
        await _videoPlayerController!.initialize();
      }

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: autoPlay,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
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
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 32),
                  const SizedBox(height: 6),
                  Text(
                    'Preview stream error: $errorMessage',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      setState(() {
        _isLoadingVideo = false;
        _isPlayingVideo = true;
      });
    } catch (e) {
      debugPrint('❌ [COURSE DETAILS] Error initializing video player: $e');
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
          _isPlayingVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Unable to play preview video. Please try again.')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openFreePreviewModal({
    required BuildContext context,
    required ApiCourseDetail course,
    required ApiLecture lecture,
  }) async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (!context.mounted) return;

    if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.pause();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _FreePreviewModalSheet(
        course: course,
        lecture: lecture,
        token: token,
        onEnroll: () {
          Navigator.pop(modalCtx);
          _handleBuyNow(context, course);
        },
      ),
    );
  }

  // ── Role Guard: Student-Only Purchase ─────────────────────────────────────

  void _showStudentOnlyDialog(BuildContext context) {
    final user = ref.read(authProvider).user;
    final canSwitchToFarmer = user != null && user.grantedRoles.contains(UserRole.farmer);

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.school_outlined, color: AppColors.warning, size: 32),
        ),
        title: const Text(
          'Student Only Action',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sirf student hi is course ko buy kar sakta hai.\n\nInstructors cannot purchase courses. Please switch to your Farmer / Student profile to enroll.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, height: 1.4),
            ),
            if (canSwitchToFarmer) ...[
              const SizedBox(height: 14),
              const Text(
                'Aapke account me Student role available hai. Kya aap switch karna chahte hain?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('OK'),
          ),
          /*
          if (canSwitchToFarmer)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Switch to Student'),
              onPressed: () async {
                Navigator.pop(dialogCtx);
                try {
                  await ref.read(authProvider.notifier).switchRole(UserRole.farmer);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Switched to Student / Farmer mode! Now you can enroll.'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to switch role: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
            ),
          */
        ],
      ),
    );
  }

  Future<void> _handleAddToCart(BuildContext context, ApiCourseDetail course) async {
    final user = ref.read(authProvider).user;
    if (user != null && user.activeRole != UserRole.farmer) {
      _showStudentOnlyDialog(context);
      return;
    }

    setState(() => _isAddingToCart = true);
    debugPrint('🛒 [CourseDetails] Adding course to cart: ${course.title} (ID: ${widget.courseId})');

    try {
      await ref.read(cartProvider.notifier).addToCart(widget.courseId);
      debugPrint('✅ [CourseDetails] Added course to cart SUCCESS: ${course.title}');
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Added to cart! 🛒'),
            duration: Duration(milliseconds: 2000),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [CourseDetails] Add to cart ERROR: $e');
      final errMsg = e.toString().replaceAll('Exception: ', '');
      if (context.mounted) {
        if (errMsg.toLowerCase().contains('already enrolled') ||
            errMsg.toLowerCase().contains('already purchased')) {
          ref.invalidate(studentEnrollmentsProvider);
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('You are already enrolled in this course! Tap Start Learning to begin. 🎓'),
              backgroundColor: AppColors.primaryGreen,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (errMsg.toLowerCase().contains('only student') ||
            (errMsg.toLowerCase().contains('student') && errMsg.toLowerCase().contains('buy'))) {
          _showStudentOnlyDialog(context);
        } else {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.showSnackBar(
            SnackBar(content: Text(errMsg), backgroundColor: AppColors.error),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  void _handleBuyNow(BuildContext context, ApiCourseDetail course) {
    final user = ref.read(authProvider).user;
    if (user != null && user.activeRole != UserRole.farmer) {
      _showStudentOnlyDialog(context);
      return;
    }

    context.push('/checkout?courseId=${widget.courseId}');
  }

  Future<void> _toggleWishlist(ApiCourseDetail course) async {
    try {
      final preview = ApiWishlistItem(
        id: '',
        targetId: widget.courseId,
        type: 'course',
        title: course.title,
        slug: course.slug ?? '',
        thumbnail: course.thumbnail,
        price: course.price ?? '0.00',
        category: course.categoryDisplay ?? course.category ?? 'General',
        rating: 4.8,
      );
      final inWishlist = await ref
          .read(wishlistProvider.notifier)
          .toggleCourse(widget.courseId, previewItem: preview);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(inWishlist ? 'Added to wishlist! ❤️' : 'Removed from wishlist'),
            duration: const Duration(milliseconds: 1800),
            backgroundColor: inWishlist ? AppColors.primaryGreen : AppColors.inkDark,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ── Build Screen ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(RouteNames.farmerHome);
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF9FBF8),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.bgDark : const Color(0xFF0F3D1F),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.farmerHome);
              }
            },
          ),
          title: courseAsync.maybeWhen(
          data: (course) => Text(
            course.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          orElse: () => const Text('Course Details', style: TextStyle(color: Colors.white)),
        ),
        actions: [
          courseAsync.maybeWhen(
            data: (course) {
              final isSaved = ref.watch(isWishlistedProvider(widget.courseId));
              return IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? Colors.redAccent : Colors.white,
                ),
                tooltip: isSaved ? 'Remove from Wishlist' : 'Add to Wishlist',
                onPressed: () => _toggleWishlist(course),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: courseAsync.when(
        data: (course) {
          // Find first available preview video URL and preview lecture (prioritize lecture.isPreview)
          String? videoUrl = course.previewVideoUrl;
          ApiLecture? previewLecture;

          for (var section in course.sections) {
            for (var lecture in section.lectures) {
              if (lecture.isPreview && lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty) {
                if (videoUrl == null || videoUrl.isEmpty) {
                  videoUrl = lecture.videoUrl;
                }
                previewLecture ??= lecture;
                break;
              }
            }
            if (previewLecture != null && videoUrl != null && videoUrl.isNotEmpty) break;
          }

          if (videoUrl == null || videoUrl.isEmpty) {
            for (var section in course.sections) {
              for (var lecture in section.lectures) {
                if (lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty) {
                  videoUrl = lecture.videoUrl;
                  previewLecture ??= lecture;
                  break;
                }
              }
              if (videoUrl != null && videoUrl.isNotEmpty) break;
            }
          }

          final totalLectures = course.sections.fold<int>(0, (sum, s) => sum + s.lectures.length);
          final isEnrolledInList = ref.watch(isCourseEnrolledProvider(widget.courseId)) ||
              (course.slug != null && ref.watch(isCourseEnrolledProvider(course.slug!)));
          final isEnrolled = (course.isEnrolled == true || course.isEnrolled == 1 || course.isEnrolled == 'true') || isEnrolledInList;

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (isWide) {
                // Desktop / Tablet 2-column layout matching Agrilearn website
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroHeader(course, totalLectures),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildWhatYouLearnCard(course, isDark),
                                  const SizedBox(height: 24),
                                  _buildCourseContent(course, isDark, isEnrolled),
                                  const SizedBox(height: 24),
                                  _buildDescriptionSection(course, isDark),
                                  const SizedBox(height: 24),
                                  _buildFeedbackSection(context, course, isDark, isEnrolled),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 380,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 24, right: 24, bottom: 40),
                        child: _buildPurchaseCard(
                          context,
                          course,
                          isDark,
                          isEnrolled,
                          previewVideoUrl: videoUrl,
                          previewBunnyId: previewLecture?.bunnyVideoId,
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Mobile Layout
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(courseDetailProvider(widget.courseId));
                  ref.invalidate(studentEnrollmentsProvider);
                  // Wait briefly so Riverpod re-builds after invalidation
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                color: AppColors.primaryGreen,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeroHeader(course, totalLectures),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPurchaseCard(
                            context,
                            course,
                            isDark,
                            isEnrolled,
                            previewVideoUrl: videoUrl,
                            previewBunnyId: previewLecture?.bunnyVideoId,
                          ),
                          const SizedBox(height: 20),
                          _buildWhatYouLearnCard(course, isDark),
                          const SizedBox(height: 20),
                          _buildCourseContent(course, isDark, isEnrolled),
                          const SizedBox(height: 20),
                          _buildDescriptionSection(course, isDark),
                          const SizedBox(height: 20),
                          _buildFeedbackSection(context, course, isDark, isEnrolled),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ShimmerContainer(width: double.infinity, height: 220, borderRadius: 16),
            SizedBox(height: 16),
            ShimmerContainer(width: 120, height: 24),
            SizedBox(height: 12),
            ShimmerContainer(width: 260, height: 28),
            SizedBox(height: 8),
            ShimmerContainer(width: double.infinity, height: 120, borderRadius: 12),
          ],
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Failed to load course details: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  onPressed: () => ref.invalidate(courseDetailProvider(widget.courseId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: courseAsync.maybeWhen(
        data: (course) {
          final isEnrolledInList = ref.watch(isCourseEnrolledProvider(widget.courseId)) ||
              (course.slug != null && ref.watch(isCourseEnrolledProvider(course.slug!)));
          final isEnrolled = (course.isEnrolled == true || course.isEnrolled == 1 || course.isEnrolled == 'true') || isEnrolledInList;
          if (isEnrolled) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.play_circle_filled),
                  label: const Text(
                    'Start Learning (Enrolled)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: () => context.push('/player/${course.slug ?? widget.courseId}'),
                ),
              ),
            );
          }

          final inCart = ref.watch(isCourseInCartProvider(widget.courseId)) ||
                         (course.slug != null && ref.watch(isCourseInCartProvider(course.slug!)));
          final priceText = course.price == null || course.price == '0' || course.price == '0.00' ? 'Free' : '₹${course.price}';

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
              border: Border(top: BorderSide(color: isDark ? AppColors.lineDark : Colors.grey.shade200)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      Text(
                        priceText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: inCart
                        ? FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFC88528), // Golden-orange matching Screenshot 5
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => context.push('/cart'),
                            icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                            label: const Text(
                              'Go to Cart',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF1B4D2E), width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: _isAddingToCart ? null : () => _handleAddToCart(context, course),
                                  child: _isAddingToCart
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B4D2E)),
                                        )
                                      : const Text(
                                          'Add to Cart',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B4D2E)),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B4D2E),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _handleBuyNow(context, course),
                                  child: const Text(
                                    'Buy Now',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    ),
  );
  }

  // ── Hero Header ─────────────────────────────────────────────────────────────

  Widget _buildHeroHeader(ApiCourseDetail course, int totalLectures) {
    final categoryText = course.categoryDisplay ?? course.category ?? 'AGRIBUSINESS';
    final instructor = course.instructorName ?? 'Instructor';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F3D1F), // Deep forest green matching Agrilearn header
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.5)),
            ),
            child: Text(
              categoryText.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF99E256),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Course Title
          Text(
            course.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),

          // Short Description / Subtitle
          if (course.shortDescription != null && course.shortDescription!.isNotEmpty)
            Text(
              course.shortDescription!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          const SizedBox(height: 16),

          // Metrics / Stat Chips Row
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.signalYellow, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'New (0 reviews)',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              // Lectures count
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.video_collection_outlined, color: Colors.white.withValues(alpha: 0.7), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    '$totalLectures Lectures',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              // Duration
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_rounded, color: Colors.white.withValues(alpha: 0.7), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    course.totalDuration != null && course.totalDuration!.isNotEmpty
                        ? course.totalDuration!
                        : '0 Total Hours',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Instructor Attribution
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGreen,
                backgroundImage: course.instructorAvatar != null && course.instructorAvatar!.isNotEmpty
                    ? NetworkImage(course.instructorAvatar!)
                    : null,
                child: course.instructorAvatar == null || course.instructorAvatar!.isEmpty
                    ? Text(
                        instructor.isNotEmpty ? instructor[0].toUpperCase() : 'I',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created by',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  Text(
                    instructor,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Purchase Card ───────────────────────────────────────────────────────────

  Widget _buildPurchaseCard(
    BuildContext context,
    ApiCourseDetail course,
    bool isDark,
    bool isEnrolled, {
    String? previewVideoUrl,
    String? previewBunnyId,
  }) {
    final priceText = course.price == null || course.price == '0' || course.price == '0.00' ? 'Free' : '₹${course.price}';
    final isSaved = ref.watch(isWishlistedProvider(widget.courseId));
    final inCart = ref.watch(isCourseInCartProvider(widget.courseId)) ||
                   (course.slug != null && ref.watch(isCourseInCartProvider(course.slug!)));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media / Video Preview Header
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _isPlayingVideo &&
                      _chewieController != null &&
                      _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        // Thumbnail
                        course.thumbnail != null && course.thumbnail!.isNotEmpty
                            ? Image.network(
                                course.thumbnail!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF1B2E21),
                                  child: const Icon(Icons.school, size: 48, color: AppColors.primaryGreen),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF1B2E21),
                                child: const Icon(Icons.school, size: 48, color: AppColors.primaryGreen),
                              ),
                        // Dark Gradient Overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                        // Loading indicator or "Preview Course" Play Button Overlay
                        if (_isLoadingVideo)
                          Container(
                            color: Colors.black54,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: AppColors.primaryGreen),
                                  SizedBox(height: 10),
                                  Text(
                                    'Loading preview...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (previewVideoUrl != null && previewVideoUrl.isNotEmpty) {
                                    _initializePlayer(
                                      previewVideoUrl,
                                      autoPlay: true,
                                      bunnyId: previewBunnyId,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No preview video available for this course.')),
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_circle_fill, color: Colors.white, size: 22),
                                      SizedBox(width: 8),
                                      Text(
                                        'Preview Course',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),

          // Price & Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                if (isEnrolled) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.push('/player/${course.slug ?? widget.courseId}'),
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Start Learning (Enrolled)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else if (inCart) ...[
                  // "Go to Cart" button matching Screenshot 5!
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFC88528), // Golden-orange matching Screenshot 5
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        debugPrint('🛒 [CourseDetails] Navigating to cart from Go to Cart button');
                        context.push('/cart');
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text(
                        'Go to Cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ] else ...[
                  // Action Buttons Row: [Add to Cart] [Heart] matching Screenshot 4!
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4D2E), // Deep forest green matching Screenshot 4
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 2,
                            ),
                            onPressed: _isAddingToCart ? null : () => _handleAddToCart(context, course),
                            child: _isAddingToCart
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text(
                                    'Add to Cart',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: isSaved ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
                          border: Border.all(
                            color: isSaved ? Colors.redAccent : (isDark ? AppColors.lineDark : Colors.grey.shade300),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.redAccent : (isDark ? Colors.white70 : Colors.grey.shade700),
                          ),
                          tooltip: isSaved ? 'Remove from Wishlist' : 'Add to Wishlist',
                          onPressed: () => _toggleWishlist(course),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Buy Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1B4D2E), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _handleBuyNow(context, course),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4D2E)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),

                // Perks Checklist (exact from screenshot)
                _buildPerkItem(Icons.all_inclusive_rounded, 'Full lifetime access', isDark),
                _buildPerkItem(Icons.devices_rounded, 'Access on mobile and TV', isDark),
                _buildPerkItem(Icons.workspace_premium_outlined, 'Certificate of completion', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── "What you'll learn" Card ────────────────────────────────────────────────

  Widget _buildWhatYouLearnCard(ApiCourseDetail course, bool isDark) {
    List<String> outcomes = [];
    if (course.whatYouLearn != null && course.whatYouLearn!.trim().isNotEmpty) {
      outcomes = course.whatYouLearn!
          .split('\n')
          .map((s) => s.trim().replaceAll(RegExp(r'^[-*•\d.]\s*'), ''))
          .where((s) => s.isNotEmpty)
          .toList();
    }

    if (outcomes.isEmpty) {
      outcomes = [
        'Understand the fundamentals of this agricultural topic.',
        'Learn practical skills you can apply to your farm today.',
        'Discover modern tools and techniques for better yields.',
        'Gain a certificate upon completion of the course.',
      ];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What you'll learn",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          ...outcomes.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.accentOrange, // Golden checkmark from screenshot
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Course Content Accordion ────────────────────────────────────────────────

  Widget _buildCourseContent(ApiCourseDetail course, bool isDark, bool isEnrolled) {
    final totalSections = course.sections.length;
    final totalLectures = course.sections.fold<int>(0, (sum, s) => sum + s.lectures.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Content',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '$totalSections sections • $totalLectures lectures',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (course.sections.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
            ),
            child: Text(
              'No curriculum sections published yet.',
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 13),
            ),
          )
        else
          ...course.sections.asMap().entries.map((entry) {
            final sIdx = entry.key;
            final section = entry.value;
            final isExpanded = _sectionExpanded[section.id] ?? (sIdx == 0);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Section Header Accordion
                  InkWell(
                    onTap: () {
                      setState(() {
                        _sectionExpanded[section.id] = !isExpanded;
                      });
                    },
                    borderRadius: BorderRadius.vertical(
                      top: const Radius.circular(12),
                      bottom: Radius.circular(isExpanded ? 0 : 12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50,
                        borderRadius: BorderRadius.vertical(
                          top: const Radius.circular(12),
                          bottom: Radius.circular(isExpanded ? 0 : 12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${sIdx + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              section.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Text(
                            '${section.lectures.length} lectures',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 18,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Lectures List
                  if (isExpanded) ...[
                    Divider(height: 1, color: isDark ? AppColors.lineDark : Colors.grey.shade200),
                    if (section.lectures.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          'No lectures in this module.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: section.lectures.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: isDark ? AppColors.lineDark : Colors.grey.shade100,
                        ),
                        itemBuilder: (context, lIdx) {
                          final lecture = section.lectures[lIdx];
                          return _buildLectureItem(lecture, isDark, isEnrolled, course: course);
                        },
                      ),
                  ],
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildLectureItem(
    ApiLecture lecture,
    bool isDark,
    bool isEnrolled, {
    required ApiCourseDetail course,
  }) {
    final hasPreview = lecture.isPreview;
    final canPlay = isEnrolled || hasPreview;

    return InkWell(
      onTap: () {
        if (canPlay) {
          if (isEnrolled) {
            context.push('/player/${widget.courseId}');
          } else if (lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty) {
            _openFreePreviewModal(
              context: context,
              course: course,
              lecture: lecture,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preview video stream is loading...')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔒 This lecture is locked. Enroll in course to unlock full access.'),
              duration: Duration(milliseconds: 2000),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              canPlay ? Icons.play_circle_outline : Icons.lock_outline_rounded,
              size: 18,
              color: canPlay ? AppColors.primaryGreen : Colors.grey.shade500,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lecture.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (hasPreview && !isEnrolled) ...[
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.signalYellow.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.signalYellow.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'Free Preview',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB28700),
                  ),
                ),
              ),
            ],
            if (lecture.durationFormatted != null && lecture.durationFormatted!.isNotEmpty)
              Text(
                lecture.durationFormatted!,
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              )
            else if (lecture.duration != null && lecture.duration! > 0)
              Text(
                '${(lecture.duration! / 60).ceil()}m',
                style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  // ── Description Section ─────────────────────────────────────────────────────

  Widget _buildDescriptionSection(ApiCourseDetail course, bool isDark) {
    final desc = course.description ?? course.shortDescription ?? 'No description provided.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.lineDark : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Student Feedback Section ────────────────────────────────────────────────

  Widget _buildFeedbackSection(
    BuildContext context,
    ApiCourseDetail course,
    bool isDark,
    bool isEnrolled,
  ) {
    final slug = course.slug ?? widget.courseId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Student Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            if (isEnrolled)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                onPressed: () => CourseReviewModal.show(
                  context,
                  courseId: widget.courseId,
                  courseSlug: slug,
                  courseTitle: course.title,
                ),
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Write a Review', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              courseTitle: course.title,
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
    );
  }
}

/// Free Preview Video Player Modal Sheet
/// Provides full mobile playback parity with the Agrilearn web portal.
class _FreePreviewModalSheet extends StatefulWidget {
  const _FreePreviewModalSheet({
    required this.course,
    required this.lecture,
    required this.onEnroll,
    this.token,
  });

  final ApiCourseDetail course;
  final ApiLecture lecture;
  final VoidCallback onEnroll;
  final String? token;

  @override
  State<_FreePreviewModalSheet> createState() => _FreePreviewModalSheetState();
}

class _FreePreviewModalSheetState extends State<_FreePreviewModalSheet> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startPreview();
  }

  Future<void> _startPreview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final videoUrl = widget.lecture.videoUrl;
    if (videoUrl == null || videoUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'No preview video URL available.';
        });
      }
      return;
    }

    try {
      final resolved = await CourseDetailsScreen.resolveVideoStream(
        videoUrl,
        bunnyId: widget.lecture.bunnyVideoId,
        authToken: widget.token,
      );

      bool initialized = false;

      // Attempt 1: Primary Stream URL with headers
      try {
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(resolved.primaryUrl),
          httpHeaders: resolved.headers,
        );
        await _controller!.initialize().timeout(const Duration(seconds: 10));
        initialized = true;
      } catch (e1) {
        debugPrint('⚠️ [PreviewModal] Primary stream init failed: $e1');
      }

      // Attempt 2: Fallback MP4 URL if primary HLS failed
      if (!initialized && resolved.fallbackUrl != null && resolved.fallbackUrl != resolved.primaryUrl) {
        await _controller?.dispose();
        try {
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(resolved.fallbackUrl!),
            httpHeaders: resolved.headers,
          );
          await _controller!.initialize().timeout(const Duration(seconds: 10));
          initialized = true;
        } catch (e2) {
          debugPrint('⚠️ [PreviewModal] Fallback stream init failed: $e2');
        }
      }

      // Attempt 3: No-headers retry
      if (!initialized) {
        await _controller?.dispose();
        try {
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(resolved.primaryUrl),
          );
          await _controller!.initialize().timeout(const Duration(seconds: 10));
          initialized = true;
        } catch (e3) {
          debugPrint('⚠️ [PreviewModal] No-header stream init failed: $e3');
        }
      }

      if (!initialized) {
        throw Exception('Could not stream preview video.');
      }

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryGreen,
          handleColor: AppColors.primaryGreen,
          backgroundColor: AppColors.lineLight,
          bufferedColor: AppColors.canopyStart,
        ),
      );

      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Unable to stream this preview video. Please check your internet connection.';
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priceText = widget.course.price == null || widget.course.price == '0' || widget.course.price == '0.00'
        ? 'Free'
        : '₹${widget.course.price}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      'FREE PREVIEW',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.lecture.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Video Player Area
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryGreen),
                            SizedBox(height: 12),
                            Text(
                              'Loading preview stream...',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.orange, size: 36),
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: _startPreview,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Retry'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _chewieController != null &&
                                _chewieController!.videoPlayerController.value.isInitialized
                            ? Chewie(controller: _chewieController!)
                            : const SizedBox.shrink(),
              ),
            ),
            // Course info & CTA
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.course.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Price: $priceText',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: widget.onEnroll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: const Text('Enroll Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
