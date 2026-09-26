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
import '../../../core/services/course_progress_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/course_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../providers/explore_provider.dart';
import '../../../core/router/route_names.dart';

/// Resolves the effective stream URL for the selected quality (Auto, 240p, 360p, 480p, 720p).
String resolveQualityStreamUrl(String baseStreamUrl, String quality) {
  final cleanQuality = quality.toLowerCase().trim();
  if (cleanQuality == 'auto' || cleanQuality.isEmpty) {
    return baseStreamUrl.replaceAll(RegExp(r'/\d{3,4}p/video\.m3u8'), '/playlist.m3u8');
  }
  // If baseStreamUrl is a Bunny HLS master playlist (playlist.m3u8)
  if (baseStreamUrl.contains('/playlist.m3u8')) {
    return baseStreamUrl.replaceAll('/playlist.m3u8', '/$cleanQuality/video.m3u8');
  }
  // If baseStreamUrl already points to another resolution (e.g. 480p/video.m3u8)
  if (RegExp(r'/\d{3,4}p/video\.m3u8').hasMatch(baseStreamUrl)) {
    return baseStreamUrl.replaceAll(RegExp(r'/\d{3,4}p/video\.m3u8'), '/$cleanQuality/video.m3u8');
  }
  // If direct MP4 renditions (e.g. play_480p.mp4)
  if (baseStreamUrl.contains('play_')) {
    return baseStreamUrl.replaceAll(RegExp(r'play_\d{3,4}p\.mp4'), 'play_$cleanQuality.mp4');
  }
  return baseStreamUrl;
}

/// Formats a Duration object into a clean digital timestamp string (mm:ss or hh:mm:ss).
String formatVideoDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds <= 0) return '00:00';
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

class CoursePlayerScreen extends ConsumerStatefulWidget {
  const CoursePlayerScreen({
    super.key,
    required this.courseId,
    this.fromCheckout = false,
  });

  final String courseId;
  final bool fromCheckout;

  @override
  ConsumerState<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends ConsumerState<CoursePlayerScreen>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  ApiLecture? _currentLecture;
  ApiCourseSection? _currentSection;
  ApiCourseDetail? _currentCourse;

  bool _isLoadingVideo = false;
  String? _videoErrorMessage;
  bool _hasAutoCompletedCurrentLecture = false;
  String? _activeSlug;
  DateTime? _lastProgressUpdateTime;

  // Video Quality Selection State
  String _selectedQuality = 'Auto';
  String? _activeBaseStreamUrl;
  bool _isOfflinePlayback = false;

  // Dynamic live video durations detected from actual media streams
  final Map<String, String> _lectureRealDurations = {};

  // Keyboard visibility — tracked via WidgetsBindingObserver for
  // immediate, reliable updates without any frame delay.
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    // Called by Flutter whenever the window metrics change (e.g. keyboard
    // slides in/out).  We read the bottom view-inset from the first view.
    final bottomInset = WidgetsBinding
        .instance.platformDispatcher.views.first.viewInsets.bottom;
    final keyboardVisible = bottomInset > 0;
    if (keyboardVisible != _isKeyboardVisible && mounted) {
      setState(() => _isKeyboardVisible = keyboardVisible);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flushCurrentProgress();
    _videoPlayerController?.removeListener(_onVideoPlayerTick);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _flushCurrentProgress() {
    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;
    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration.inSeconds > 0) {
      final ratio = position.inMilliseconds / duration.inMilliseconds;
      _savePartialProgress(ratio, position.inSeconds);
    }
  }

  void _onVideoPlayerTick() {
    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration.inSeconds > 0) {
      if (_currentLecture != null && !_lectureRealDurations.containsKey(_currentLecture!.id)) {
        _lectureRealDurations[_currentLecture!.id] = formatVideoDuration(duration);
      }

      final progressRatio = (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

      // 1. Auto-complete current lecture when 90% or more is watched
      if (progressRatio >= 0.90 &&
          !_hasAutoCompletedCurrentLecture &&
          _currentLecture != null &&
          _activeSlug != null) {
        _hasAutoCompletedCurrentLecture = true;
        _triggerAutoCompletion(_currentLecture!);
      }

      // 2. Throttled partial watch progress saving (every 2 seconds)
      final now = DateTime.now();
      if (_lastProgressUpdateTime == null ||
          now.difference(_lastProgressUpdateTime!).inSeconds >= 2) {
        _lastProgressUpdateTime = now;
        _savePartialProgress(progressRatio, position.inSeconds);
      }
    }
  }

  Future<void> _savePartialProgress(double ratio, int positionSeconds) async {
    if (_currentLecture == null) return;
    final course = _currentCourse ?? ref.read(courseDetailProvider(widget.courseId)).value;
    final allLectureIds =
        course?.sections.expand((s) => s.lectures).map((l) => l.id).toList() ?? [];

    final slug = _activeSlug ?? course?.slug ?? widget.courseId;
    final courseId = course?.id ?? widget.courseId;

    await CourseProgressService.instance.updateLectureWatchAndRecalculate(
      courseSlugOrId: slug,
      secondaryKey: courseId,
      lectureId: _currentLecture!.id,
      watchRatio: ratio,
      positionSeconds: positionSeconds,
      allLectureIds: allLectureIds.isNotEmpty ? allLectureIds : [_currentLecture!.id],
    );

    // Refresh enrollment & percentage providers so dashboard & player reflect progress immediately
    if (mounted) {
      ref.invalidate(studentEnrollmentsProvider);
      ref.invalidate(coursePercentageProvider(slug));
      if (courseId != slug) {
        ref.invalidate(coursePercentageProvider(courseId));
      }
    }

    // Sync with backend API in background
    try {
      final repo = ref.read(studentRepositoryProvider);
      repo.updateLectureProgress(
        _currentLecture!.id,
        completed: ratio >= 0.90,
        watchedTime: positionSeconds,
      );
    } catch (_) {}
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
        _isOfflinePlayback = true;
        _selectedQuality = 'Offline';
        _videoPlayerController = VideoPlayerController.file(File(localPath));
        await _videoPlayerController!.initialize();

        final offlineSec = _videoPlayerController!.value.duration.inSeconds;
        if (offlineSec > 0) {
          _lectureRealDurations[lecture.id] = formatVideoDuration(_videoPlayerController!.value.duration);
        }

        _chewieController = _createChewieController(_videoPlayerController!);

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

        _isOfflinePlayback = false;
        _activeBaseStreamUrl = resolvedUrl;
        final effectiveStreamUrl = resolveQualityStreamUrl(resolvedUrl, _selectedQuality);

        debugPrint('▶️ [CoursePlayer] Initializing video stream: $effectiveStreamUrl (base: $resolvedUrl, quality: $_selectedQuality, isBunny=$isBunny)');

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
          Uri.parse(effectiveStreamUrl),
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
              Uri.parse(effectiveStreamUrl),
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
              Uri.parse(effectiveStreamUrl),
            );
            await _videoPlayerController!.initialize().timeout(
              const Duration(seconds: 12),
              onTimeout: () {
                throw Exception('Video load timed out on retry.');
              },
            );
          } else {
            // Fallback to base master playlist if quality stream failed
            if (effectiveStreamUrl != resolvedUrl) {
              debugPrint('⚠️ [CoursePlayer] Specific quality failed, falling back to Auto master stream: $e');
              await _videoPlayerController?.dispose();
              _selectedQuality = 'Auto';
              _videoPlayerController = VideoPlayerController.networkUrl(
                Uri.parse(resolvedUrl),
                httpHeaders: headers,
              );
              await _videoPlayerController!.initialize().timeout(
                const Duration(seconds: 12),
                onTimeout: () {
                  throw Exception('Video load timed out on fallback.');
                },
              );
            } else {
              rethrow;
            }
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

      final totalSec = _videoPlayerController!.value.duration.inSeconds;
      if (totalSec > 0) {
        _lectureRealDurations[lecture.id] = formatVideoDuration(_videoPlayerController!.value.duration);
      }

      // Resume video from saved position if user previously watched it
      if (_activeSlug != null) {
        final savedSec = await CourseProgressService.instance
            .getLectureWatchPositionSeconds(_activeSlug!, lecture.id);
        if (savedSec > 5 && totalSec > 0 && savedSec < (totalSec * 0.95)) {
          await _videoPlayerController!.seekTo(Duration(seconds: savedSec));
        }
      }

      _videoPlayerController!.addListener(_onVideoPlayerTick);

      _chewieController = _createChewieController(_videoPlayerController!);

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

  ChewieController _createChewieController(VideoPlayerController playerController) {
    return ChewieController(
      videoPlayerController: playerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
      showControls: true,
      showOptions: true,
      additionalOptions: (context) {
        return [
          OptionItem(
            onTap: (ctx) {
              Navigator.of(ctx).pop();
              _showQualitySelectionSheet(context);
            },
            iconData: Icons.tune_rounded,
            title: 'Quality',
            subtitle: _selectedQuality,
          ),
        ];
      },
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryGreen,
        handleColor: AppColors.primaryGreen,
        backgroundColor: Colors.white24,
        bufferedColor: AppColors.canopyStart.withValues(alpha: 0.5),
      ),
    );
  }

  void _showQualitySelectionSheet(BuildContext sheetContext) {
    final isDark = Theme.of(sheetContext).brightness == Brightness.dark;

    final qualities = [
      {
        'value': 'Auto',
        'title': 'Auto (Recommended)',
        'desc': 'Adjusts resolution dynamically based on network',
        'icon': Icons.auto_awesome_rounded,
      },
      {
        'value': '480p',
        'title': '480p (High)',
        'desc': 'Clear picture quality, best on Wi-Fi',
        'icon': Icons.hd_outlined,
      },
      {
        'value': '360p',
        'title': '360p (Standard)',
        'desc': 'Balanced video quality & data usage',
        'icon': Icons.smart_display_outlined,
      },
      {
        'value': '240p',
        'title': '240p (Data Saver)',
        'desc': 'Lowest data usage, suitable for weak cellular',
        'icon': Icons.data_saver_on_outlined,
      },
    ];

    showModalBottomSheet(
      context: sheetContext,
      useRootNavigator: true,
      backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded,
                            color: AppColors.primaryGreen, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Video Playback Quality',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isOfflinePlayback) ...[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.offline_pin_rounded,
                            color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This video is playing from offline storage at downloaded quality.',
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  ...qualities.map((item) {
                    final value = item['value'] as String;
                    final isSelected = _selectedQuality == value;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (!isSelected) {
                          _changeVideoQuality(value);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.inkSoft,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String,
                                    style: Theme.of(ctx)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.primaryGreen
                                              : null,
                                        ),
                                  ),
                                  Text(
                                    item['desc'] as String,
                                    style: Theme.of(ctx)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontSize: 11,
                                          color: AppColors.inkSoft,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _changeVideoQuality(String newQuality) async {
    if (newQuality == _selectedQuality || _videoPlayerController == null) return;
    if (_isOfflinePlayback || _currentLecture == null || _activeBaseStreamUrl == null) return;

    final previousQuality = _selectedQuality;
    final currentPosition = _videoPlayerController!.value.position;
    final wasPlaying = _videoPlayerController!.value.isPlaying;

    setState(() {
      _selectedQuality = newQuality;
      _isLoadingVideo = true;
    });

    try {
      final targetUrl = resolveQualityStreamUrl(_activeBaseStreamUrl!, newQuality);
      debugPrint('🎛️ [CoursePlayer] Changing video quality to $newQuality: $targetUrl');

      final token = await ref.read(tokenStorageProvider).getAccessToken();
      final isBunny = targetUrl.contains('b-cdn.net') ||
          targetUrl.contains('bunny') ||
          targetUrl.contains('mediadelivery.net');
      Map<String, String> headers = {};
      final isBackendHost = targetUrl.contains('iagrow.zappcode.in') ||
          targetUrl.contains('localhost') ||
          targetUrl.contains('127.0.0.1') ||
          targetUrl.contains('10.0.2.2');
      if (token != null && isBackendHost) {
        headers['Authorization'] = 'Bearer $token';
      }
      if (isBunny) {
        headers['Referer'] = 'https://iframe.mediadelivery.net/';
        headers['User-Agent'] =
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
      }

      VideoPlayerController newController = VideoPlayerController.networkUrl(
        Uri.parse(targetUrl),
        httpHeaders: headers,
      );

      try {
        await newController.initialize().timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception('Quality switch timed out'),
        );
      } catch (err) {
        debugPrint('⚠️ [CoursePlayer] Quality stream failed with primary headers, retrying clean: $err');
        await newController.dispose();
        newController = VideoPlayerController.networkUrl(Uri.parse(targetUrl));
        await newController.initialize().timeout(
          const Duration(seconds: 12),
          onTimeout: () => throw Exception('Quality switch timed out on retry'),
        );
      }

      _videoPlayerController?.removeListener(_onVideoPlayerTick);
      final oldPlayer = _videoPlayerController;
      final oldChewie = _chewieController;

      _videoPlayerController = newController;
      if (currentPosition > Duration.zero) {
        await _videoPlayerController!.seekTo(currentPosition);
      }
      _videoPlayerController!.addListener(_onVideoPlayerTick);

      _chewieController = _createChewieController(_videoPlayerController!);

      oldChewie?.dispose();
      await oldPlayer?.dispose();

      if (wasPlaying) {
        await _videoPlayerController!.play();
      }

      if (mounted) {
        setState(() {
          _isLoadingVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video quality changed to $newQuality'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ [CoursePlayer] Failed to change video quality: $e');
      if (mounted) {
        setState(() {
          _selectedQuality = previousQuality;
          _isLoadingVideo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not switch quality ($e)'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _playLecture(ApiLecture lecture, ApiCourseSection section) {
    _flushCurrentProgress();
    setState(() {
      _currentLecture = lecture;
      _currentSection = section;
      _hasAutoCompletedCurrentLecture = false;
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

  void _handleBackNavigation() {
    // If keyboard is visible, dismiss it first — do NOT navigate away.
    // Use the state variable (updated by WidgetsBindingObserver) which is
    // always in sync; avoids the race-condition of re-reading viewInsets.
    if (_isKeyboardVisible) {
      FocusScope.of(context).unfocus();
      return;
    }
    _videoPlayerController?.pause();
    if (widget.fromCheckout) {
      // After purchase flow, always land on home
      context.go(RouteNames.farmerHome);
    } else if (context.canPop()) {
      // Normal push-navigation: just pop back
      context.pop();
    } else {
      // Player was opened as a top-level route (e.g. from home "Start Learning")
      // — go back to the Course Details screen, NOT the dashboard
      final courseSlug = _activeSlug ?? widget.courseId;
      context.go('/farmer/course/$courseSlug');
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        // IMPORTANT: Keep false so the Scaffold does NOT shrink when the
        // keyboard opens. The video area collapses via AnimatedContainer
        // instead, preventing the double-resize overflow.
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            _currentLecture?.title ?? 'Course Player',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackNavigation,
          ),
        ),
      body: courseAsync.when(
        data: (course) {
          _currentCourse = course;
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
          final discretePercent = totalLecturesCount > 0
              ? ((completedCount / totalLecturesCount) * 100).round()
              : 0;
          final granularPercentAsync = ref.watch(coursePercentageProvider(_activeSlug!));
          final granularPercent = granularPercentAsync.value?.round() ?? 0;
          final completionPercent = granularPercent > discretePercent ? granularPercent : discretePercent;
          return Column(
            children: [
              // ── 1. Video Player / Reading Banner Area ─────────────
              // AnimatedContainer collapses to 0 height when the keyboard
              // is open, avoiding overflow and restoring instantly when
              // the keyboard is dismissed (no frame delay).
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                width: double.infinity,
                height: _isKeyboardVisible ? 0 : 230,
                color: Colors.black,
                clipBehavior: Clip.hardEdge,
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
              if (_currentLecture != null && !_isKeyboardVisible)
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
                      // Responsive Actions Toolbar
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mark as Complete Toggle
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
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
                              size: 15,
                              color: completedIds.contains(_currentLecture!.id)
                                  ? AppColors.primaryGreen
                                  : AppColors.inkSoft,
                            ),
                            label: Text(
                              completedIds.contains(_currentLecture!.id)
                                  ? 'Completed'
                                  : 'Mark Done',
                              style: TextStyle(
                                fontSize: 11,
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
                          const SizedBox(width: 2),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                            padding: const EdgeInsets.all(4),
                            tooltip: 'Quick Bookmark',
                            icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.accentOrange, size: 20),
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
                          const SizedBox(width: 2),
                          // Quality Selector Chip Button
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _showQualitySelectionSheet(context),
                            child: Tooltip(
                              message: 'Playback Quality ($_selectedQuality)',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.35),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.tune_rounded,
                                        size: 13,
                                        color: AppColors.primaryGreen),
                                    const SizedBox(width: 3),
                                    Text(
                                      _selectedQuality,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_hasNextLecture(course)) ...[
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                              padding: const EdgeInsets.all(4),
                              tooltip: 'Next Lecture',
                              icon: const Icon(Icons.skip_next,
                                  color: AppColors.primaryGreen, size: 22),
                              onPressed: () => _playNextLecture(course),
                            ),
                          ],
                        ],
                      ),
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
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                        labelColor: AppColors.primaryGreen,
                        unselectedLabelColor:
                            isDark ? Colors.white70 : AppColors.inkSoft,
                        indicatorColor: AppColors.primaryGreen,
                        labelStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        unselectedLabelStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        tabs: const [
                          Tab(text: 'Curriculum'),
                          Tab(text: 'Q&A'),
                          Tab(text: 'Notes & Bookmarks'),
                          Tab(text: 'Reviews'),
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
                              videoPlayerController: _videoPlayerController,
                              lectureRealDurations: _lectureRealDurations,
                              onSelectLecture: (lec, sec) =>
                                  _playLecture(lec, sec),
                            ),

                            // ── TAB 2: Q&A FORUM ─────────────────────
                            _CourseQaTab(
                              courseSlug: _activeSlug!,
                              lectureId: _currentLecture?.id,
                            ),

                            // ── TAB 3: TIMESTAMPED NOTES ─────────────
                            _CourseNotesTab(
                              courseSlug: _activeSlug!,
                              videoPlayerController: _videoPlayerController,
                              currentPositionSeconds: _videoPlayerController
                                      ?.value.position.inSeconds ??
                                  0,
                              onSeek: (seconds) {
                                _videoPlayerController
                                    ?.seekTo(Duration(seconds: seconds));
                              },
                            ),

                            // ── TAB 4: REVIEWS & RATINGS ─────────────
                            _CourseReviewsTab(
                              courseSlug: _activeSlug!,
                              courseTitle: course.title,
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
    this.videoPlayerController,
    this.lectureRealDurations = const {},
  });

  final ApiCourseDetail course;
  final ApiLecture? currentLecture;
  final Set<String> completedIds;
  final int completionPercent;
  final int completedCount;
  final int totalLectures;
  final Function(ApiLecture, ApiCourseSection) onSelectLecture;
  final VideoPlayerController? videoPlayerController;
  final Map<String, String> lectureRealDurations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookmarkedLectures = ref.watch(lectureBookmarksProvider(course.slug ?? course.id));

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        final slug = course.slug ?? course.id;
        ref.invalidate(courseDetailProvider(slug));
        ref.invalidate(courseProgressProvider(slug));
        try {
          await ref.read(courseDetailProvider(slug).future);
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                    Expanded(
                      child: Text(
                        'Study Materials & Downloads (${currentLecture!.resources.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                  final liveDuration = (isPlaying &&
                          videoPlayerController != null &&
                          videoPlayerController!.value.isInitialized &&
                          videoPlayerController!.value.duration.inSeconds > 0)
                      ? formatVideoDuration(videoPlayerController!.value.duration)
                      : (lectureRealDurations[lecture.id] ?? lecture.durationFormatted);

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
                        if (liveDuration != null && liveDuration.isNotEmpty) ...[
                          Text(
                            liveDuration,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isPlaying ? FontWeight.w600 : FontWeight.normal,
                              color: isPlaying
                                  ? AppColors.primaryGreen
                                  : (isDark ? Colors.white70 : AppColors.inkSoft),
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
                Consumer(
                  builder: (context, ref, _) {
                    final isPassedAsync = ref.watch(sectionQuizPassedProvider(section.id));
                    final isPassed = isPassedAsync.value ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isPassed ? AppColors.primaryGreen : AppColors.accentOrange,
                          side: BorderSide(
                            color: isPassed ? AppColors.primaryGreen : AppColors.accentOrange,
                          ),
                          backgroundColor: isPassed
                              ? AppColors.primaryGreen.withValues(alpha: 0.08)
                              : Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          isPassed ? Icons.check_circle_rounded : Icons.quiz_rounded,
                          size: 16,
                          color: isPassed ? AppColors.primaryGreen : AppColors.accentOrange,
                        ),
                        label: Text(
                          isPassed ? 'Quiz Passed ✅ • Review / Retake' : 'Take Section Quiz',
                          style: TextStyle(
                            fontWeight: isPassed ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                        onPressed: () => context.push('/quiz/${section.id}'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ],
    ),
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
  const _CourseQaTab({
    required this.courseSlug,
    this.lectureId,
  });
  final String courseSlug;
  final String? lectureId;

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
      await ref.read(studentRepositoryProvider).postCourseQa(
            widget.courseSlug,
            text,
            lectureId: widget.lectureId,
          );
      _controller.clear();
      ref.invalidate(courseQaProvider(widget.courseSlug));
      if (mounted) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        String msg = e.toString().replaceAll('Exception: ', '');
        if (msg.contains('"error":')) {
          try {
            final match = RegExp(r'"error"\s*:\s*"([^"]+)"').firstMatch(msg);
            if (match != null) msg = match.group(1)!;
          } catch (_) {}
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
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
          child: RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              ref.invalidate(courseQaProvider(widget.courseSlug));
              await ref.read(courseQaProvider(widget.courseSlug).future).catchError((_) => <Map<String, dynamic>>[]);
            },
            child: qaAsync.when(
              data: (questions) {
                if (questions.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Center(
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
                      ),
                    ],
                  );
                }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
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
      ),
        // ── Input strip — sits above keyboard + safe area bottom ──
        // viewInsets.bottom is needed because resizeToAvoidBottomInset
        // is false on the parent Scaffold.
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 10 +
                MediaQuery.of(context).padding.bottom +
                MediaQuery.of(context).viewInsets.bottom,
          ),
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
                    hintText: 'Ask a question...',
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send_rounded,
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
    this.videoPlayerController,
    required this.onSeek,
  });

  final String courseSlug;
  final int currentPositionSeconds;
  final VideoPlayerController? videoPlayerController;
  final Function(int) onSeek;

  @override
  ConsumerState<_CourseNotesTab> createState() => _CourseNotesTabState();
}

class _CourseNotesTabState extends ConsumerState<_CourseNotesTab> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String _activeFilter = 'all'; // 'all', 'notes', 'bookmarks'

  @override
  void initState() {
    super.initState();
    widget.videoPlayerController?.addListener(_onPlayerTick);
  }

  @override
  void didUpdateWidget(covariant _CourseNotesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoPlayerController != widget.videoPlayerController) {
      oldWidget.videoPlayerController?.removeListener(_onPlayerTick);
      widget.videoPlayerController?.addListener(_onPlayerTick);
    }
  }

  @override
  void dispose() {
    widget.videoPlayerController?.removeListener(_onPlayerTick);
    _controller.dispose();
    super.dispose();
  }

  int _lastTickSec = -1;
  void _onPlayerTick() {
    final sec = widget.videoPlayerController?.value.position.inSeconds ?? 0;
    if (sec != _lastTickSec && mounted) {
      _lastTickSec = sec;
      setState(() {});
    }
  }

  int _getCurrentSeconds() {
    return widget.videoPlayerController?.value.position.inSeconds ?? widget.currentPositionSeconds;
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _quickBookmark() async {
    final sec = _getCurrentSeconds();
    final formatted = _formatTime(sec);
    final text = '🔖 Bookmark at $formatted';
    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentRepositoryProvider).postCourseNote(
            widget.courseSlug,
            text,
            sec,
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

    final sec = _getCurrentSeconds();
    setState(() => _isSubmitting = true);
    // Dismiss keyboard before submitting so screen returns to normal
    if (mounted) FocusScope.of(context).unfocus();
    try {
      await ref.read(studentRepositoryProvider).postCourseNote(
            widget.courseSlug,
            text,
            sec,
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
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filter Chips
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
                const SizedBox(width: 6),
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
                const SizedBox(width: 6),
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
                const SizedBox(width: 10),
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
                  final rawTime = n['timestamp_seconds'] ?? n['timestamp'];
                  final int timestamp = rawTime is int
                      ? rawTime
                      : (rawTime is num
                          ? rawTime.toInt()
                          : (int.tryParse(rawTime?.toString() ?? '') ?? 0));
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
        // viewInsets.bottom is needed because resizeToAvoidBottomInset
        // is false on the parent Scaffold.
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 10 +
                MediaQuery.of(context).padding.bottom +
                MediaQuery.of(context).viewInsets.bottom,
          ),
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
                        'Add note at ${_formatTime(_getCurrentSeconds())}...',
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
                        color: AppColors.accentOrange,
                        width: 1.5,
                      ),
                    ),
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
// TAB 4: REVIEWS & RATINGS (Agrilearn Parity)
// ─────────────────────────────────────────────────────────────────────────────

class _CourseReviewsTab extends ConsumerStatefulWidget {
  const _CourseReviewsTab({
    required this.courseSlug,
    required this.courseTitle,
  });

  final String courseSlug;
  final String courseTitle;

  @override
  ConsumerState<_CourseReviewsTab> createState() => _CourseReviewsTabState();
}

class _CourseReviewsTabState extends ConsumerState<_CourseReviewsTab> {
  int _selectedRating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent! 🌟';
      default:
        return '';
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final repo = ref.read(courseRepositoryProvider);
      await repo.submitCourseReview(
        widget.courseSlug,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      // Invalidate providers so lists refresh
      ref.invalidate(courseReviewsProvider(widget.courseSlug));
      ref.invalidate(courseDetailProvider(widget.courseSlug));

      _commentController.clear();
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your review has been submitted. ⭐'),
            backgroundColor: AppColors.primaryGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reviewsAsync = ref.watch(courseReviewsProvider(widget.courseSlug));

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () async {
        ref.invalidate(courseReviewsProvider(widget.courseSlug));
        try {
          await ref.read(courseReviewsProvider(widget.courseSlug).future);
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
        // ── 1. "Leave a Review" Card (matching Agrilearn CoursePlayerPage) ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : AppColors.lineLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: AppColors.signalYellow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Leave a Review',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Star Selector
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 4,
                children: [
                  ...List.generate(5, (index) {
                    final starVal = index + 1;
                    return InkWell(
                      onTap: () => setState(() => _selectedRating = starVal),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Icon(
                          starVal <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 30,
                          color: starVal <= _selectedRating ? AppColors.signalYellow : (isDark ? Colors.white30 : Colors.grey.shade400),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    _getRatingLabel(_selectedRating),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Comment Input
              TextField(
                controller: _commentController,
                maxLines: 3,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
                decoration: InputDecoration(
                  hintText: 'Tell us what you think about this course (optional)...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : AppColors.inkSoft,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF161A17) : const Color(0xFFF7F9F6),
                  contentPadding: const EdgeInsets.all(12),
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
              // Submit Button
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  ),
                  onPressed: _isSubmitting ? null : _submitReview,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 16),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Review',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── 2. Reviews Header ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Course Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.inkDark,
              ),
            ),
            reviewsAsync.when(
              data: (reviews) => Text(
                '${reviews.length} ${reviews.length == 1 ? "review" : "reviews"}',
                style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, fontWeight: FontWeight.w500),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── 3. Reviews List ──
        reviewsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : AppColors.lineLight),
            ),
            child: Text(
              'Unable to load reviews right now.',
              style: TextStyle(color: isDark ? Colors.white70 : AppColors.inkSoft, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white10 : AppColors.lineLight),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 40,
                      color: isDark ? Colors.white38 : AppColors.inkSoft,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your review helps other students discover great courses!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final review = reviews[index];
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
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                            backgroundImage: review.studentAvatar != null && review.studentAvatar!.isNotEmpty
                                ? NetworkImage(review.studentAvatar!)
                                : null,
                            child: review.studentAvatar == null || review.studentAvatar!.isEmpty
                                ? Text(
                                    review.studentName.isNotEmpty ? review.studentName[0].toUpperCase() : 'S',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreen,
                                      fontSize: 12,
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : AppColors.inkDark,
                                  ),
                                ),
                                Row(
                                  children: [
                                    ...List.generate(5, (sIdx) {
                                      return Icon(
                                        sIdx < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                        size: 14,
                                        color: sIdx < review.rating ? AppColors.signalYellow : Colors.grey.shade400,
                                      );
                                    }),
                                    if (review.createdAt != null) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        DateFormat.yMMMd().format(review.createdAt!),
                                        style: const TextStyle(
                                          color: AppColors.inkSoft,
                                          fontSize: 11,
                                        ),
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
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.inkDark,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
  );
}
}
