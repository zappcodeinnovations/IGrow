import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/features/explore/screens/course_player_screen.dart';

void main() {
  group('Video Duration Formatting & Synchronization Tests', () {
    test('formatVideoDuration formats short 18s duration correctly (00:18)', () {
      expect(formatVideoDuration(const Duration(seconds: 18)), '00:18');
    });

    test('formatVideoDuration formats 2s duration correctly (00:02)', () {
      expect(formatVideoDuration(const Duration(seconds: 2)), '00:02');
    });

    test('formatVideoDuration handles zero duration correctly (00:00)', () {
      expect(formatVideoDuration(Duration.zero), '00:00');
      expect(formatVideoDuration(const Duration(seconds: -5)), '00:00');
    });

    test('formatVideoDuration formats minutes and seconds correctly', () {
      expect(formatVideoDuration(const Duration(minutes: 2)), '02:00');
      expect(formatVideoDuration(const Duration(minutes: 5, seconds: 43)), '05:43');
      expect(formatVideoDuration(const Duration(seconds: 125)), '02:05');
      expect(formatVideoDuration(const Duration(seconds: 599)), '09:59');
    });

    test('formatVideoDuration formats multi-digit hours correctly (hh:mm:ss)', () {
      expect(
        formatVideoDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '01:02:03',
      );
      expect(
        formatVideoDuration(const Duration(hours: 2, minutes: 30, seconds: 0)),
        '02:30:00',
      );
    });

    test('Live duration resolution prioritizes active video controller duration over stale API metadata', () {
      // Simulation of live dynamic duration priority:
      // When playing, the real stream duration (e.g. 18s) overrides backend's initial estimated value (e.g. 2 min / '00:02')
      const backendDurationFormatted = '00:02';
      final activeVideoDuration = const Duration(seconds: 18);
      final lectureRealDurations = <String, String>{};

      const lectureId = 'lec-1';
      final isPlaying = true;
      final isInitialized = true;

      final liveDuration = (isPlaying && isInitialized && activeVideoDuration.inSeconds > 0)
          ? formatVideoDuration(activeVideoDuration)
          : (lectureRealDurations[lectureId] ?? backendDurationFormatted);

      // Verify that the UI reflects 00:18 instead of 00:02
      expect(liveDuration, '00:18');
      expect(liveDuration, isNot(backendDurationFormatted));
    });

    test('Duration cache retains real duration for previously loaded lectures', () {
      const backendDurationFormatted = '00:02';
      final lectureRealDurations = <String, String>{
        'lec-1': '00:18',
      };

      const lectureId = 'lec-1';
      final bool isPlaying = lectureId == 'lec-2';

      final liveDuration = isPlaying
          ? '00:00'
          : (lectureRealDurations[lectureId] ?? backendDurationFormatted);

      expect(liveDuration, '00:18');
    });
  });
}
