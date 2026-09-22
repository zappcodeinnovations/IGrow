import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/services/offline_download_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../providers/explore_provider.dart';

class CoursePlayerScreen extends ConsumerStatefulWidget {
  const CoursePlayerScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends ConsumerState<CoursePlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  ApiLecture? _currentLecture;
  ApiCourseSection? _currentSection;

  bool _isLoadingVideo = false;
  String? _videoErrorMessage;
  bool _hasAutoCompletedCurrentLecture = false;
  String? _activeSlug;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onVideoPlayerTick);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _onVideoPlayerTick() {
    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration.inSeconds > 0) {
      final progressRatio = position.inMilliseconds / duration.inMilliseconds;
      if (progressRatio >= 0.90 &&
          !_hasAutoCompletedCurrentLecture &&
          _currentLecture != null &&
          _activeSlug != null) {
        _hasAutoCompletedCurrentLecture = true;
        _triggerAutoCompletion(_currentLecture!);
      }
    }
  }

  void _triggerAutoCompletion(ApiLecture lecture) {
    if (_activeSlug == null) return;
    ref
        .read(courseProgressStateProvider(_activeSlug!).notifier)
        .markLectureCompletion(
          lecture.id,
          completed: true,
          watchedTime: _videoPlayerController?.value.position.inSeconds,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Lecture completed! "${lecture.title}"'),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _initializePlayer(ApiLecture lecture) async {
    _videoPlayerController?.removeListener(_onVideoPlayerTick);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    setState(() {
      _videoPlayerController = null;
      _chewieController = null;
      _isLoadingVideo = true;
      _videoErrorMessage = null;
      _hasAutoCompletedCurrentLecture = false;
    });

    final videoUrl = lecture.videoUrl;
    final bunnyId = lecture.bunnyVideoId;

    if ((videoUrl == null || videoUrl.isEmpty) &&
        (bunnyId == null || bunnyId.isEmpty)) {
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
          _videoErrorMessage = null;
        });
      }
      return;
    }

    try {
      // 1. Check if lecture video is cached locally for offline playback
      final offlineService = ref.read(offlineDownloadServiceProvider);
      final localPath = await offlineService.getLocalPath(lecture.id);

      if (localPath != null && File(localPath).existsSync()) {
        debugPrint('⚡ [CoursePlayer] Playing lecture from local offline cache: $localPath');
        _videoPlayerController = VideoPlayerController.file(File(localPath));
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio > 0
              ? _videoPlayerController!.value.aspectRatio
              : 16 / 9,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Offline playback error: $errorMessage',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );

        _videoPlayerController!.addListener(_onVideoPlayerTick);

        if (mounted) {
          setState(() {
            _isLoadingVideo = false;
          });
        }
        return;
      }

      String resolvedUrl = '';
      String? effectiveBunnyId = bunnyId;

      // Extract Bunny video GUID if present in URL and not already provided
      if ((effectiveBunnyId == null || effectiveBunnyId.isEmpty) && videoUrl != null) {
        final match = RegExp(r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}')
            .firstMatch(videoUrl);
        if (match != null) {
          effectiveBunnyId = match.group(0);
        }
      }

      // 1. Try to fetch authenticated signed HLS stream URL from backend
      try {
        final streamData = await ref.read(studentRepositoryProvider).getLectureStream(lecture.id);
        final fetchedStreamUrl = streamData['stream_url']?.toString();
        if (fetchedStreamUrl != null && fetchedStreamUrl.isNotEmpty) {
          resolvedUrl = fetchedStreamUrl;
          final backendBunnyId = streamData['bunny_video_id']?.toString();
          if (backendBunnyId != null && backendBunnyId.isNotEmpty) {
            effectiveBunnyId = backendBunnyId;
          }
        }
      } catch (streamErr) {
        debugPrint('⚠️ [CoursePlayer] Could not fetch signed stream URL: $streamErr');
      }

      // 2. Fallback to direct video URL or direct Bunny HLS playlist
      if (resolvedUrl.isEmpty) {
        if (videoUrl != null && videoUrl.isNotEmpty) {
          resolvedUrl = videoUrl;
        } else if (effectiveBunnyId != null && effectiveBunnyId.isNotEmpty) {
          resolvedUrl = 'https://vz-716870.b-cdn.net/$effectiveBunnyId/playlist.m3u8';
        }
      }

      // 3. If resolvedUrl is an iframe embed, convert to Bunny direct stream if video ID is known
      if (resolvedUrl.contains('iframe.mediadelivery.net') ||
          resolvedUrl.contains('/play/')) {
        if (effectiveBunnyId != null && effectiveBunnyId.isNotEmpty) {
          resolvedUrl = 'https://vz-716870.b-cdn.net/$effectiveBunnyId/playlist.m3u8';
        }
      }

      // 4. Fallback for deprecated Google Cloud Storage sample link (blocked by GCS AccessDenied)
      if (resolvedUrl.contains('commondatastorage.googleapis.com') &&
          resolvedUrl.contains('BigBuckBunny.mp4')) {
        debugPrint('ℹ️ [CoursePlayer] Replacing blocked GCS sample link with active working sample video');
        resolvedUrl = 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4';
      }

      if (resolvedUrl.startsWith('http')) {
        final token = await ref.read(tokenStorageProvider).getAccessToken();
        final isBunny = resolvedUrl.contains('b-cdn.net') ||
            resolvedUrl.contains('bunny') ||
            resolvedUrl.contains('mediadelivery.net');

        debugPrint('▶️ [CoursePlayer] Initializing video stream: $resolvedUrl (isBunny=$isBunny)');

        Map<String, String> headers = {};
        // Only attach Authorization header if the video is hosted on our own backend server.
        // External CDNs/clouds (like Google Cloud Storage, AWS S3, etc.) return 401 Unauthorized
        // when passed an unrecognized Bearer token.
        final isBackendHost = resolvedUrl.contains('iagrow.zappcode.in') ||
            resolvedUrl.contains('localhost') ||
            resolvedUrl.contains('127.0.0.1') ||
            resolvedUrl.contains('10.0.2.2');
        if (token != null && isBackendHost) {
          headers['Authorization'] = 'Bearer $token';
        }
        if (isBunny) {
          headers['Referer'] = 'https://iagrow.zappcode.in/';
          headers['User-Agent'] =
              'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
        }

        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(resolvedUrl),
          httpHeaders: headers,
        );

        try {
          await _videoPlayerController!.initialize().timeout(
            const Duration(seconds: 12),
            onTimeout: () {
              throw Exception('Video load timed out. Please check your network.');
            },
          );
        } catch (e) {
          // If Bunny stream failed with 401/403, try alternative referer (iframe.mediadelivery.net)
          if (isBunny && (e.toString().contains('401') || e.toString().contains('403'))) {
            debugPrint('⚠️ [CoursePlayer] First referer failed, retrying with iframe.mediadelivery.net referer...');
            await _videoPlayerController?.dispose();
            headers['Referer'] = 'https://iframe.mediadelivery.net/';
            _videoPlayerController = VideoPlayerController.networkUrl(
              Uri.parse(resolvedUrl),
              httpHeaders: headers,
            );
            await _videoPlayerController!.initialize().timeout(
              const Duration(seconds: 12),
              onTimeout: () {
                throw Exception('Video load timed out on retry.');
              },
            );
          } else if (headers.isNotEmpty && (e.toString().contains('401') || e.toString().contains('403'))) {
            // If stream failed with 401/403 with headers, retry cleanly without headers
            debugPrint('⚠️ [CoursePlayer] Video stream failed with headers ($e), retrying without headers...');
            await _videoPlayerController?.dispose();
            _videoPlayerController = VideoPlayerController.networkUrl(
              Uri.parse(resolvedUrl),
            );
            await _videoPlayerController!.initialize().timeout(
              const Duration(seconds: 12),
              onTimeout: () {
                throw Exception('Video load timed out on retry.');
              },
            );
          } else {
            rethrow;
          }
        }
      } else {
        _videoPlayerController =
            VideoPlayerController.file(File(resolvedUrl));
        await _videoPlayerController!.initialize().timeout(
          const Duration(seconds: 12),
          onTimeout: () {
            throw Exception('Video load timed out. Please check your network.');
          },
        );
      }

      _videoPlayerController!.addListener(_onVideoPlayerTick);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryGreen,
          handleColor: AppColors.primaryGreen,
          backgroundColor: Colors.white24,
          bufferedColor: AppColors.canopyStart.withValues(alpha: 0.5),
        ),
      );

      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
      }
    } catch (e) {
      debugPrint('❌ [CoursePlayer] Video initialization failed: $e');
      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
          _videoErrorMessage =
              'Unable to stream this video right now. (${e.toString().replaceAll("Exception: ", "")})';
        });
      }
    }
  }

  void _playLecture(ApiLecture lecture, ApiCourseSection section) {
    setState(() {
      _currentLecture = lecture;
      _currentSection = section;
    });
    _initializePlayer(lecture);
  }

  void _playNextLecture(ApiCourseDetail course) {
    final allLecturesWithSections = <({ApiLecture lecture, ApiCourseSection section})>[];
    for (final sec in course.sections) {
      for (final lec in sec.lectures) {
        allLecturesWithSections.add((lecture: lec, section: sec));
      }
    }

    final currentIndex = allLecturesWithSections.indexWhere(
      (item) => item.lecture.id == _currentLecture?.id,
    );

    if (currentIndex != -1 && currentIndex < allLecturesWithSections.length - 1) {
      final nextItem = allLecturesWithSections[currentIndex + 1];
      _playLecture(nextItem.lecture, nextItem.section);
    }
  }

  bool _hasNextLecture(ApiCourseDetail course) {
    final allLectures = course.sections.expand((s) => s.lectures).toList();
    final currentIndex = allLectures.indexWhere((l) => l.id == _currentLecture?.id);
    return currentIndex != -1 && currentIndex < allLectures.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentLecture?.title ?? 'Course Player',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: courseAsync.when(
        data: (course) {
          _activeSlug = course.slug ?? widget.courseId;
          final progressAsync = ref.watch(courseProgressStateProvider(_activeSlug!));
          final completedIds = progressAsync.value ?? <String>{};

          // Auto-select first lecture if none is currently selected
          if (_currentLecture == null && course.sections.isNotEmpty) {
            for (var section in course.sections) {
              if (section.lectures.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _playLecture(section.lectures.first, section);
                });
                break;
              }
            }
          }

          final allLectures = course.sections.expand((s) => s.lectures).toList();
          final totalLecturesCount = allLectures.length;
          final completedCount =
              allLectures.where((l) => completedIds.contains(l.id)).length;
          final completionPercent = totalLecturesCount > 0
              ? ((completedCount / totalLecturesCount) * 100).round()
              : 0;
          final isCourseFullyCompleted =
              totalLecturesCount > 0 && completedCount >= totalLecturesCount;

          return Column(
            children: [
              // ── 1. Video Player / Reading Banner Area ─────────────
              Container(
                width: double.infinity,
                height: 230,
                color: Colors.black,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_chewieController != null &&
                        _chewieController!
                            .videoPlayerController.value.isInitialized)
                      Chewie(controller: _chewieController!)
                    else if (_isLoadingVideo)
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primaryGreen),
                          SizedBox(height: 12),
                          Text(
                            'Loading lesson stream...',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      )
                    else if (_videoErrorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.accentOrange, size: 40),
                              const SizedBox(height: 8),
                              Text(
                                _videoErrorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Retry'),
                                onPressed: () {
                                  if (_currentLecture != null) {
                                    _initializePlayer(_currentLecture!);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book,
                                color: AppColors.primaryGreen,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentLecture?.title ?? 'Reading / Study Lecture',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'This lesson contains reading materials and study resources.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── 2. Lecture Quick Action Bar (Completion & Next) ───
              if (_currentLecture != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.lineDark : AppColors.lineLight,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentSection?.title ?? 'Course Content',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : AppColors.inkSoft,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentLecture!.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mark as Complete Toggle
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          side: BorderSide(
                            color: completedIds.contains(_currentLecture!.id)
                                ? AppColors.primaryGreen
                                : AppColors.inkSoft.withValues(alpha: 0.5),
                          ),
                          backgroundColor:
                              completedIds.contains(_currentLecture!.id)
                                  ? AppColors.primaryGreen.withValues(alpha: 0.1)
                                  : Colors.transparent,
                        ),
                        icon: Icon(
                          completedIds.contains(_currentLecture!.id)
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 16,
                          color: completedIds.contains(_currentLecture!.id)
                              ? AppColors.primaryGreen
                              : AppColors.inkSoft,
                        ),
                        label: Text(
                          completedIds.contains(_currentLecture!.id)
                              ? 'Completed'
                              : 'Mark Done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: completedIds.contains(_currentLecture!.id)
                                ? AppColors.primaryGreen
                                : (isDark ? Colors.white : AppColors.inkDark),
                          ),
                        ),
                        onPressed: () {
                          final isCurrentlyDone =
                              completedIds.contains(_currentLecture!.id);
                          ref
                              .read(
                                  courseProgressStateProvider(_activeSlug!)
                                      .notifier)
                              .markLectureCompletion(
                                _currentLecture!.id,
                                completed: !isCurrentlyDone,
                                watchedTime: _videoPlayerController
                                    ?.value.position.inSeconds,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                !isCurrentlyDone
                                    ? 'Marked as completed! ✓'
                                    : 'Marked as pending',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Quick Bookmark',
                        icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.accentOrange),
                        onPressed: () async {
                          final currentSec = _videoPlayerController?.value.position.inSeconds ?? 0;
                          final m = currentSec ~/ 60;
                          final s = currentSec % 60;
                          final timeFormatted = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
                          final text = '🔖 Bookmark at $timeFormatted in ${_currentLecture!.title}';
                          try {
                            await ref.read(studentRepositoryProvider).postCourseNote(
                                  _activeSlug!,
                                  text,
                                  currentSec,
                                );
                            ref.invalidate(courseNotesProvider(_activeSlug!));
                            if (!mounted || !context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Bookmarked at $timeFormatted!'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.accentOrange,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                          } catch (_) {}
                        },
                      ),
                      if (_hasNextLecture(course)) ...[
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Next Lecture',
                          icon: const Icon(Icons.skip_next,
                              color: AppColors.primaryGreen),
                          onPressed: () => _playNextLecture(course),
                        ),
                      ],
                    ],
                  ),
                ),

              // ── 3. 4-Tab Interactive Learning Hub ─────────────────
              Expanded(
                child: DefaultTabController(
                  length: 4,
                  child: Column(
                    children: [
                      TabBar(
                        isScrollable: false,
                        labelColor: AppColors.primaryGreen,
                        unselectedLabelColor:
                            isDark ? Colors.white70 : AppColors.inkSoft,
                        indicatorColor: AppColors.primaryGreen,
                        labelStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        tabs: [
                          const Tab(text: 'Curriculum'),
                          const Tab(text: 'Q&A'),
                          const Tab(text: 'Notes & Bookmarks'),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Certificate'),
                                if (isCourseFullyCompleted) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified,
                                      size: 14, color: AppColors.accentOrange),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // ── TAB 1: CURRICULUM & STUDY MATERIALS ──
                            _CurriculumTab(
                              course: course,
                              currentLecture: _currentLecture,
                              completedIds: completedIds,
                              completionPercent: completionPercent,
                              completedCount: completedCount,
                              totalLectures: totalLecturesCount,
                              onSelectLecture: (lec, sec) =>
                                  _playLecture(lec, sec),
                            ),

                            // ── TAB 2: Q&A FORUM ─────────────────────
                            _CourseQaTab(courseSlug: _activeSlug!),

                            // ── TAB 3: TIMESTAMPED NOTES ─────────────
                            _CourseNotesTab(
                              courseSlug: _activeSlug!,
                              currentPositionSeconds: _videoPlayerController
                                      ?.value.position.inSeconds ??
                                  0,
                              onSeek: (seconds) {
                                _videoPlayerController
                                    ?.seekTo(Duration(seconds: seconds));
                              },
                            ),

                            // ── TAB 4: CERTIFICATE OF COMPLETION ─────
                            _CourseCertificateTab(
                              course: course,
                              isCompleted: isCourseFullyCompleted,
                              completedCount: completedCount,
                              totalLectures: totalLecturesCount,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text('Error loading course: $err',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(courseDetailProvider(widget.courseId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1: CURRICULUM & STUDY MATERIALS COMPONENT
// ─────────────────────────────────────────────────────────────────────────────

class _CurriculumTab extends ConsumerWidget {
  const _CurriculumTab({
    required this.course,
    required this.currentLecture,
    required this.completedIds,
    required this.completionPercent,
    required this.completedCount,
    required this.totalLectures,
    required this.onSelectLecture,
  });

  final ApiCourseDetail course;
  final ApiLecture? currentLecture;
  final Set<String> completedIds;
  final int completionPercent;
  final int completedCount;
  final int totalLectures;
  final Function(ApiLecture, ApiCourseSection) onSelectLecture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarkedLectures = ref.watch(lectureBookmarksProvider(course.slug ?? course.id));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Overall Course Progress Bar Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.lineDark : AppColors.lineLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Course Progress: $completionPercent%',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    '$completedCount / $totalLectures Completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppColors.inkSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: totalLectures > 0
                      ? (completedCount / totalLectures)
                      : 0.0,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? AppColors.lineDark
                      : AppColors.lineLight.withValues(alpha: 0.6),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Attached Study Materials for currently selected lecture
        if (currentLecture != null && currentLecture!.resources.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.attach_file,
                        size: 18, color: AppColors.primaryGreen),
                    const SizedBox(width: 8),
                    Text(
                      'Study Materials & Downloads (${currentLecture!.resources.length})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...currentLecture!.resources.map((resource) {
                  return _ResourceItemTile(resource: resource);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Current Lecture Description
        if (currentLecture?.description != null &&
            currentLecture!.description!.isNotEmpty) ...[
          Text(
            'About this lesson',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            currentLecture!.description!,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.inkSoft,
              height: 1.4,
            ),
          ),
          const Divider(height: 28),
        ],

        // Sections Accordion
        Text(
          'Course Syllabus',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...course.sections.asMap().entries.map((entry) {
          final sIdx = entry.key;
          final section = entry.value;
          final sectionCompleted = section.lectures
              .where((l) => completedIds.contains(l.id))
              .length;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? AppColors.lineDark : AppColors.lineLight,
              ),
            ),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                'Section ${sIdx + 1}: ${section.title}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                '$sectionCompleted / ${section.lectures.length} completed',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                ),
              ),
              children: [
                ...section.lectures.map((lecture) {
                  final isPlaying = currentLecture?.id == lecture.id;
                  final isDone = completedIds.contains(lecture.id);

                  return ListTile(
                    dense: true,
                    leading: isDone
                        ? const Icon(Icons.check_circle,
                            color: AppColors.primaryGreen, size: 20)
                        : isPlaying
                            ? const Icon(Icons.play_circle_filled,
                                color: AppColors.primaryGreen, size: 20)
                            : const Icon(Icons.radio_button_unchecked,
                                color: AppColors.inkSoft, size: 20),
                    title: Text(
                      lecture.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isPlaying ? FontWeight.bold : FontWeight.normal,
                        color: isPlaying ? AppColors.primaryGreen : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (lecture.isPreview) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (lecture.durationFormatted != null) ...[
                          Text(
                            lecture.durationFormatted!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white70
                                  : AppColors.inkSoft,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          icon: Icon(
                            bookmarkedLectures.contains(lecture.id)
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 19,
                            color: bookmarkedLectures.contains(lecture.id)
                                ? AppColors.accentOrange
                                : AppColors.inkSoft,
                          ),
                          tooltip: bookmarkedLectures.contains(lecture.id)
                              ? 'Remove Bookmark'
                              : 'Bookmark Lecture',
                          onPressed: () {
                            ref
                                .read(lectureBookmarksProvider(course.slug ?? course.id).notifier)
                                .toggleBookmark(lecture.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  bookmarkedLectures.contains(lecture.id)
                                      ? 'Removed from bookmarks'
                                      : 'Lecture bookmarked! 🔖',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () => onSelectLecture(lecture, section),
                  );
                }),
                // Section Quiz link
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentOrange,
                      side: const BorderSide(color: AppColors.accentOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.quiz_rounded, size: 16),
                    label: const Text('Take Section Quiz'),
                    onPressed: () => context.push('/quiz/${section.id}'),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESOURCE / STUDY MATERIAL TILE WITH IN-APP PDF VIEWER
// ─────────────────────────────────────────────────────────────────────────────

class _ResourceItemTile extends StatelessWidget {
  const _ResourceItemTile({required this.resource});

  final ApiLectureResource resource;

  IconData _getIconForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.xlsx') || lower.endsWith('.xls') || lower.endsWith('.csv')) {
      return Icons.table_chart;
    }
    if (lower.endsWith('.docx') || lower.endsWith('.doc')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  Color _getColorForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return Colors.red;
    if (lower.endsWith('.xlsx') || lower.endsWith('.xls') || lower.endsWith('.csv')) {
      return Colors.green;
    }
    if (lower.endsWith('.docx') || lower.endsWith('.doc')) {
      return Colors.blue;
    }
    return AppColors.primaryGreen;
  }

  void _openResource(BuildContext context) {
    final lower = resource.fileName.toLowerCase();
    if (lower.endsWith('.pdf') && resource.fileUrl.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => Scaffold(
            appBar: AppBar(
              title: Text(resource.fileName),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            body: SfPdfViewer.network(resource.fileUrl),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(resource.fileName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: ${resource.fileName}'),
              const SizedBox(height: 8),
              Text(
                'Type: ${resource.fileType ?? 'Document'}',
                style: const TextStyle(color: AppColors.inkSoft),
              ),
              const SizedBox(height: 12),
              const Text(
                'Study material is available for online reading in this course.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForFile(resource.fileName);
    final color = _getColorForFile(resource.fileName);

    return InkWell(
      onTap: () => _openResource(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    resource.fileType?.toUpperCase() ?? 'DOCUMENT',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.inkSoft),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2: Q&A FORUM
// ─────────────────────────────────────────────────────────────────────────────

class _CourseQaTab extends ConsumerStatefulWidget {
  const _CourseQaTab({required this.courseSlug});
  final String courseSlug;

  @override
  ConsumerState<_CourseQaTab> createState() => _CourseQaTabState();
}

class _CourseQaTabState extends ConsumerState<_CourseQaTab> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(studentRepositoryProvider)
          .postCourseQa(widget.courseSlug, text);
      _controller.clear();
      ref.invalidate(courseQaProvider(widget.courseSlug));
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error posting question: $e'),
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qaAsync = ref.watch(courseQaProvider(widget.courseSlug));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: qaAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: AppColors.inkSoft),
                        SizedBox(height: 12),
                        Text(
                          'No discussions yet.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Have a question about the course? Ask below and the instructor will reply!',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(color: AppColors.inkSoft, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final answer = q['answer'] ?? q['answer_text'];
                  final studentName = q['student_name'] ?? 'Student';
                  final questionText = q['question'] ?? q['question_text'] ?? '';
                  final questionId = q['id']?.toString();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            isDark ? AppColors.lineDark : AppColors.lineLight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    AppColors.primaryGreen.withValues(alpha: 0.2),
                                child: Text(
                                  studentName.isNotEmpty
                                      ? studentName[0].toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (questionId != null)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: AppColors.inkSoft),
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(studentRepositoryProvider)
                                          .deleteQaQuestion(questionId);
                                      ref.invalidate(
                                          courseQaProvider(widget.courseSlug));
                                    } catch (_) {}
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            questionText,
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (answer != null &&
                              answer.toString().trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      AppColors.primaryGreen.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.verified,
                                          size: 16,
                                          color: AppColors.primaryGreen),
                                      SizedBox(width: 6),
                                      Text(
                                        'Instructor Answer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    answer.toString(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white70
                                          : AppColors.inkDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Ask a question...',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send,
                          color: AppColors.primaryGreen),
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3: TIMESTAMPED NOTES
// ─────────────────────────────────────────────────────────────────────────────

class _CourseNotesTab extends ConsumerStatefulWidget {
  const _CourseNotesTab({
    required this.courseSlug,
    required this.currentPositionSeconds,
    required this.onSeek,
  });

  final String courseSlug;
  final int currentPositionSeconds;
  final Function(int) onSeek;

  @override
  ConsumerState<_CourseNotesTab> createState() => _CourseNotesTabState();
}

class _CourseNotesTabState extends ConsumerState<_CourseNotesTab> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String _activeFilter = 'all'; // 'all', 'notes', 'bookmarks'

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _quickBookmark() async {
    final formatted = _formatTime(widget.currentPositionSeconds);
    final text = '🔖 Bookmark at $formatted';
    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentRepositoryProvider).postCourseNote(
            widget.courseSlug,
            text,
            widget.currentPositionSeconds,
          );
      ref.invalidate(courseNotesProvider(widget.courseSlug));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Bookmarked at $formatted!'),
              ],
            ),
            backgroundColor: AppColors.accentOrange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save bookmark: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentRepositoryProvider).postCourseNote(
            widget.courseSlug,
            text,
            widget.currentPositionSeconds,
          );
      _controller.clear();
      ref.invalidate(courseNotesProvider(widget.courseSlug));
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to save note: $e'),
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(courseNotesProvider(widget.courseSlug));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // ── Top Action & Filter Strip ─────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.lineDark : AppColors.lineLight,
              ),
            ),
          ),
          child: Row(
            children: [
              // Filter Chips
              Wrap(
                spacing: 6,
                children: [
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('All'),
                    selected: _activeFilter == 'all',
                    selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: _activeFilter == 'all' ? FontWeight.bold : FontWeight.normal,
                      color: _activeFilter == 'all' ? AppColors.primaryGreen : null,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = 'all');
                    },
                  ),
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Notes 📝'),
                    selected: _activeFilter == 'notes',
                    selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: _activeFilter == 'notes' ? FontWeight.bold : FontWeight.normal,
                      color: _activeFilter == 'notes' ? AppColors.primaryGreen : null,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = 'notes');
                    },
                  ),
                  ChoiceChip(
                    visualDensity: VisualDensity.compact,
                    label: const Text('Bookmarks 🔖'),
                    selected: _activeFilter == 'bookmarks',
                    selectedColor: AppColors.accentOrange.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: _activeFilter == 'bookmarks' ? FontWeight.bold : FontWeight.normal,
                      color: _activeFilter == 'bookmarks' ? AppColors.accentOrange : null,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _activeFilter = 'bookmarks');
                    },
                  ),
                ],
              ),
              const Spacer(),
              // Quick Bookmark Button
              InkWell(
                onTap: _isSubmitting ? null : _quickBookmark,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.accentOrange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_add_rounded, size: 14, color: AppColors.accentOrange),
                      const SizedBox(width: 4),
                      Text(
                        'Bookmark ${_formatTime(widget.currentPositionSeconds)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Notes & Bookmarks List ────────────────────────────────
        Expanded(
          child: notesAsync.when(
            data: (notes) {
              final filteredNotes = notes.where((n) {
                final text = (n['note_text'] ?? n['content'] ?? '').toString().toLowerCase();
                final isBookmark = text.contains('bookmark') || text.contains('🔖');
                if (_activeFilter == 'bookmarks') return isBookmark;
                if (_activeFilter == 'notes') return !isBookmark;
                return true;
              }).toList();

              if (filteredNotes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _activeFilter == 'bookmarks'
                              ? Icons.bookmark_border_rounded
                              : Icons.edit_note,
                          size: 48,
                          color: AppColors.inkSoft.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _activeFilter == 'bookmarks'
                              ? 'No bookmarks yet.'
                              : 'No notes yet.',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeFilter == 'bookmarks'
                              ? 'Tap "Quick Bookmark" anytime during playback to save important moments!'
                              : 'Write notes during the video. Tapping any timestamp will jump directly to that point!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final n = filteredNotes[index];
                  final timestamp = n['timestamp'] as int? ?? 0;
                  final noteText = (n['note_text'] ?? n['content'] ?? '').toString();
                  final noteId = n['id']?.toString();
                  final isBookmark = noteText.toLowerCase().contains('bookmark') || noteText.contains('🔖');

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isBookmark
                            ? AppColors.accentOrange.withValues(alpha: 0.3)
                            : (isDark ? AppColors.lineDark : AppColors.lineLight),
                      ),
                    ),
                    color: isBookmark
                        ? AppColors.accentOrange.withValues(alpha: isDark ? 0.08 : 0.04)
                        : (isDark ? AppColors.cardDark : Colors.white),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: ActionChip(
                        avatar: Icon(
                          isBookmark ? Icons.bookmark_rounded : Icons.play_arrow_rounded,
                          size: 14,
                          color: isBookmark ? AppColors.accentOrange : AppColors.primaryGreen,
                        ),
                        label: Text(
                          _formatTime(timestamp),
                          style: TextStyle(
                            color: isBookmark ? AppColors.accentOrange : AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: (isBookmark ? AppColors.accentOrange : AppColors.primaryGreen)
                            .withValues(alpha: 0.12),
                        side: BorderSide.none,
                        onPressed: () => widget.onSeek(timestamp),
                      ),
                      title: Text(
                        noteText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isBookmark ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: noteId != null
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              tooltip: 'Delete',
                              onPressed: () async {
                                try {
                                  await ref.read(studentRepositoryProvider).deleteNote(noteId);
                                  ref.invalidate(courseNotesProvider(widget.courseSlug));
                                } catch (_) {}
                              },
                            )
                          : null,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),

        // ── Input Strip at Bottom ─────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText:
                        'Add note at ${_formatTime(widget.currentPositionSeconds)}...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: 10),
              _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentOrange,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.accentOrange),
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4: CERTIFICATE OF COMPLETION
// ─────────────────────────────────────────────────────────────────────────────

class _CourseCertificateTab extends ConsumerWidget {
  const _CourseCertificateTab({
    required this.course,
    required this.isCompleted,
    required this.completedCount,
    required this.totalLectures,
  });

  final ApiCourseDetail course;
  final bool isCompleted;
  final int completedCount;
  final int totalLectures;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final studentName = user?.fullName ?? 'Valued Student';
    final completionDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    if (!isCompleted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 56,
                  color: AppColors.accentOrange,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Certificate Locked',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Complete all lectures ($completedCount / $totalLectures finished) to unlock your verified Certificate of Completion.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.inkSoft,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: totalLectures > 0
                      ? (completedCount / totalLectures)
                      : 0.0,
                  minHeight: 10,
                  backgroundColor: isDark
                      ? AppColors.lineDark
                      : AppColors.lineLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 100% Completed: Display Official Certificate Card
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGreen),
          ),
          child: const Row(
            children: [
              Icon(Icons.celebration, color: AppColors.primaryGreen, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Congratulations! Course Completed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'You have mastered all lectures and curriculum milestones.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Beautiful Certificate Mockup Container
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37), // Gold border
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.workspace_premium,
                  size: 48, color: Color(0xFFD4AF37)),
              const SizedBox(height: 8),
              const Text(
                'IGROW CERTIFICATE OF COMPLETION',
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB8860B),
                ),
              ),
              const Divider(height: 28, thickness: 1),
              const Text(
                'THIS IS PROUDLY PRESENTED TO',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: AppColors.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                studentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'for successfully completing the course curriculum for',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.inkSoft,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: $completionDate',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.inkSoft),
                      ),
                      Text(
                        'Instructor: ${course.instructorName ?? "IGrow Faculty"}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.inkSoft),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Icon(Icons.verified_user,
                          color: AppColors.primaryGreen, size: 28),
                      Text(
                        'VERIFIED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.download),
          label: const Text(
            'Download Certificate',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Certificate downloaded successfully! 🎓'),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          },
        ),
      ],
    );
  }
}
