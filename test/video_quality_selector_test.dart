import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/features/explore/screens/course_player_screen.dart';

void main() {
  group('Video Quality Stream URL Resolution Tests', () {
    const masterPlaylistUrl =
        'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/playlist.m3u8';

    test('resolveQualityStreamUrl returns master playlist for Auto', () {
      final result = resolveQualityStreamUrl(masterPlaylistUrl, 'Auto');
      expect(result, masterPlaylistUrl);

      final resultLower = resolveQualityStreamUrl(masterPlaylistUrl, 'auto');
      expect(resultLower, masterPlaylistUrl);

      final resultEmpty = resolveQualityStreamUrl(masterPlaylistUrl, '');
      expect(resultEmpty, masterPlaylistUrl);
    });

    test('resolveQualityStreamUrl switches to 480p video.m3u8', () {
      final result = resolveQualityStreamUrl(masterPlaylistUrl, '480p');
      expect(
        result,
        'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/480p/video.m3u8',
      );
    });

    test('resolveQualityStreamUrl switches to 360p video.m3u8', () {
      final result = resolveQualityStreamUrl(masterPlaylistUrl, '360p');
      expect(
        result,
        'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/360p/video.m3u8',
      );
    });

    test('resolveQualityStreamUrl switches to 240p video.m3u8', () {
      final result = resolveQualityStreamUrl(masterPlaylistUrl, '240p');
      expect(
        result,
        'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/240p/video.m3u8',
      );
    });

    test('resolveQualityStreamUrl switches between resolutions seamlessly', () {
      const current360p =
          'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/360p/video.m3u8';

      // 360p -> 720p
      final to720p = resolveQualityStreamUrl(current360p, '720p');
      expect(
        to720p,
        'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/720p/video.m3u8',
      );

      // 360p -> Auto (reverts to master playlist.m3u8)
      final toAuto = resolveQualityStreamUrl(current360p, 'Auto');
      expect(toAuto, masterPlaylistUrl);
    });

    test('resolveQualityStreamUrl handles direct MP4 renditions', () {
      const mp4Url =
          'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/play_480p.mp4';
      final to240p = resolveQualityStreamUrl(mp4Url, '240p');
      expect(
        to240p,
        'https://vz-752796.b-cdn.net/aecc4138-479f-43d0-b5c0-f7e0c56d4024/play_240p.mp4',
      );
    });

    test('resolveQualityStreamUrl safely leaves generic URLs unchanged', () {
      const genericUrl = 'https://example.com/videos/sample.mp4';
      final result = resolveQualityStreamUrl(genericUrl, '360p');
      expect(result, genericUrl);
    });
  });

  group('Video Quality Selector UI & Modal Tests', () {
    testWidgets('Quality Selection Modal Sheet displays all resolution tiers and allows selection', (tester) async {
      String currentQuality = 'Auto';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      final qualities = [
                        {
                          'value': 'Auto',
                          'title': 'Auto (Recommended)',
                          'desc': 'Adjusts resolution dynamically based on network',
                        },
                        {
                          'value': '480p',
                          'title': '480p (High)',
                          'desc': 'Clear picture quality, best on Wi-Fi',
                        },
                        {
                          'value': '360p',
                          'title': '360p (Standard)',
                          'desc': 'Balanced video quality & data usage',
                        },
                        {
                          'value': '240p',
                          'title': '240p (Data Saver)',
                          'desc': 'Lowest data usage, suitable for weak cellular',
                        },
                      ];

                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Video Playback Quality'),
                                ...qualities.map((item) {
                                  final val = item['value']!;
                                  return ListTile(
                                    key: Key('quality_$val'),
                                    title: Text(item['title']!),
                                    subtitle: Text(item['desc']!),
                                    trailing: currentQuality == val
                                        ? const Icon(Icons.check_circle, key: Key('selected_check'))
                                        : null,
                                    onTap: () {
                                      setState(() {
                                        currentQuality = val;
                                      });
                                      Navigator.pop(ctx);
                                    },
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text('Quality: $currentQuality'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state is Auto
      expect(find.text('Quality: Auto'), findsOneWidget);

      // Open quality selection modal
      await tester.tap(find.text('Quality: Auto'));
      await tester.pumpAndSettle();

      // Verify all options are present
      expect(find.text('Video Playback Quality'), findsOneWidget);
      expect(find.text('Auto (Recommended)'), findsOneWidget);
      expect(find.text('480p (High)'), findsOneWidget);
      expect(find.text('360p (Standard)'), findsOneWidget);
      expect(find.text('240p (Data Saver)'), findsOneWidget);
      expect(find.byKey(const Key('selected_check')), findsOneWidget);

      // Tap 360p (Standard)
      await tester.tap(find.byKey(const Key('quality_360p')));
      await tester.pumpAndSettle();

      // Modal closed and quality updated
      expect(find.text('Video Playback Quality'), findsNothing);
      expect(find.text('Quality: 360p'), findsOneWidget);
    });
  });
}
