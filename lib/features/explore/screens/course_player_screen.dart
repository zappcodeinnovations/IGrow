import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/api_models/course_models.dart';
import '../providers/explore_provider.dart';
import '../../home_farmer/providers/student_provider.dart';
import '../../auth/providers/auth_provider.dart';

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
  
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  void _initializePlayer(ApiLecture lecture) async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    setState(() {
      _videoPlayerController = null;
      _chewieController = null;
    });

    if (lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty) {
      if (lecture.videoUrl!.startsWith('http')) {
        final token = await ref.read(tokenStorageProvider).getAccessToken();
        final streamUrl = 'https://iagrow.zappcode.in/api/v1/lectures/${lecture.id}/stream/';
        
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(streamUrl),
          httpHeaders: {
            'Authorization': 'Bearer $token',
          },
        );
      } else {
        _videoPlayerController = VideoPlayerController.file(File(lecture.videoUrl!));
      }
      await _videoPlayerController!.initialize();
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      allowPlaybackSpeedChanging: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryGreen,
        handleColor: AppColors.primaryGreen,
        backgroundColor: AppColors.lineLight,
        bufferedColor: AppColors.canopyStart,
      ),
    );

    setState(() {});
  }

  void _playLecture(ApiLecture lecture) {
    setState(() {
      _currentLecture = lecture;
    });
    if (lecture.videoUrl != null && lecture.videoUrl!.isNotEmpty) {
      _initializePlayer(lecture);
    } else {
      _videoPlayerController?.dispose();
      _chewieController?.dispose();
      setState(() {
        _videoPlayerController = null;
        _chewieController = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Player'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: courseAsync.when(
        data: (course) {
          // If no current lecture, try to set the first available video
          if (_currentLecture == null && course.sections.isNotEmpty) {
            for (var section in course.sections) {
              if (section.lectures.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _playLecture(section.lectures.first);
                });
                break;
              }
            }
          }

          return Column(
            children: [
              // Video Player Area
              Container(
                width: double.infinity,
                height: 250,
                color: Colors.black,
                child: _chewieController != null &&
                        _chewieController!.videoPlayerController.value.isInitialized
                    ? Chewie(controller: _chewieController!)
                    : Center(
                        child: _currentLecture?.videoUrl == null
                            ? const Text(
                                'No Video Available',
                                style: TextStyle(color: Colors.white),
                              )
                            : const CircularProgressIndicator(),
                      ),
              ),
              // Course Info & Lecture List
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: AppColors.primaryGreen,
                        unselectedLabelColor: AppColors.inkSoft,
                        indicatorColor: AppColors.primaryGreen,
                        tabs: const [
                          Tab(text: 'Lectures'),
                          Tab(text: 'Q&A'),
                          Tab(text: 'My Notes'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Lectures
                            ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                Text(
                                  _currentLecture?.title ?? course.title,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _currentLecture?.description ?? course.shortDescription ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.inkSoft),
                                ),
                                const Divider(height: 32),
                                Text(
                                  'Course Content',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                ...course.sections.map((section) {
                                  return ExpansionTile(
                                    title: Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    initiallyExpanded: true,
                                    children: [
                                      ...section.lectures.map((lecture) {
                                        final isPlaying = _currentLecture?.id == lecture.id;
                                        return ListTile(
                                          leading: Icon(
                                            lecture.videoUrl != null ? Icons.play_circle_outline : Icons.article_outlined,
                                            color: isPlaying ? AppColors.primaryGreen : AppColors.inkSoft,
                                          ),
                                          title: Text(
                                            lecture.title,
                                            style: TextStyle(
                                              color: isPlaying ? AppColors.primaryGreen : null,
                                              fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          trailing: lecture.durationFormatted != null
                                              ? Text(lecture.durationFormatted!)
                                              : null,
                                          onTap: () => _playLecture(lecture),
                                        );
                                      }),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.assignment, color: AppColors.accentOrange),
                                        title: const Text('Take Section Quiz', style: TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
                                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.accentOrange),
                                        onTap: () => context.push('/quiz/${section.id}'),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                            // Tab 2: Q&A
                            _CourseQaTab(courseSlug: course.slug ?? widget.courseId),
                            // Tab 3: Notes
                            _CourseNotesTab(
                              courseSlug: course.slug ?? widget.courseId,
                              currentPositionSeconds: _chewieController?.videoPlayerController.value.position.inSeconds ?? 0,
                              onSeek: (seconds) {
                                _chewieController?.videoPlayerController.seekTo(Duration(seconds: seconds));
                              },
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

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
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentRepositoryProvider).postCourseQa(widget.courseSlug, _controller.text.trim());
      _controller.clear();
      ref.invalidate(courseQaProvider(widget.courseSlug));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qaAsync = ref.watch(courseQaProvider(widget.courseSlug));
    return Column(
      children: [
        Expanded(
          child: qaAsync.when(
            data: (questions) {
              if (questions.isEmpty) return const Center(child: Text('No questions yet. Be the first to ask!'));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final q = questions[index];
                  final answer = q['answer'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Q: ${q['question'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (answer != null && answer.toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('A: $answer', style: const TextStyle(color: AppColors.primaryGreen)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Ask a question...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primaryGreen),
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

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

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentRepositoryProvider).postCourseNote(widget.courseSlug, _controller.text.trim(), widget.currentPositionSeconds);
      _controller.clear();
      ref.invalidate(courseNotesProvider(widget.courseSlug));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(courseNotesProvider(widget.courseSlug));
    return Column(
      children: [
        Expanded(
          child: notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) return const Center(child: Text('No notes yet. Create one!'));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final n = notes[index];
                  final timestamp = n['timestamp'] as int? ?? 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: InkWell(
                      onTap: () => widget.onSeek(timestamp),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(_formatTime(timestamp), style: const TextStyle(color: AppColors.accentOrange, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    title: Text(n['note_text'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                      onPressed: () async {
                        try {
                          await ref.read(studentRepositoryProvider).deleteNote(n['id'].toString());
                          ref.invalidate(courseNotesProvider(widget.courseSlug));
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Add note at ${_formatTime(widget.currentPositionSeconds)}...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.accentOrange),
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
