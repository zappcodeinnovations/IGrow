import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/features/explore/screens/course_details_screen.dart';

void main() {
  group('Course Details Free Preview Stream & Playback Tests', () {
    test('resolveVideoStream properly resolves Bunny iframe embed URL', () async {
      const embedUrl = 'https://iframe.mediadelivery.net/play/752796/aecc4138-479f-43d0-b5c0-f7e0c56d4024';

      final resolved = await CourseDetailsScreen.resolveVideoStream(
        embedUrl,
        bunnyId: 'aecc4138-479f-43d0-b5c0-f7e0c56d4024',
      );

      // Verify resolved URLs
      expect(resolved.primaryUrl, isNotEmpty);
      expect(
        resolved.primaryUrl.contains('.m3u8') || resolved.primaryUrl.contains('.mp4'),
        isTrue,
      );

      // Verify essential mobile APK playback headers for Bunny CDN parity
      expect(resolved.headers['Referer'], contains('mediadelivery.net'));
      expect(resolved.headers['User-Agent'], isNotEmpty);
    });

    test('resolveVideoStream handles direct b-cdn.net stream URLs', () async {
      const directUrl = 'https://vz-716870.b-cdn.net/sample-video/playlist.m3u8';

      final resolved = await CourseDetailsScreen.resolveVideoStream(directUrl);

      expect(resolved.primaryUrl, directUrl);
      expect(resolved.headers['Referer'], 'https://iframe.mediadelivery.net/');
    });

    test('resolveVideoStream fallback handles offline / unreachable embed regex fallback', () async {
      const unreachableEmbed = 'https://iframe.mediadelivery.net/play/999999/11111111-2222-3333-4444-555555555555';

      final resolved = await CourseDetailsScreen.resolveVideoStream(unreachableEmbed);

      expect(resolved.primaryUrl, contains('11111111-2222-3333-4444-555555555555'));
      expect(resolved.primaryUrl, contains('playlist.m3u8'));
      expect(resolved.headers['Referer'], 'https://iframe.mediadelivery.net/');
    });
  });
}
