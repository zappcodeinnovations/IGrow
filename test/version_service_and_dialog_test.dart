import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:krushi_siksha/core/widgets/app_update_dialog.dart';
import 'package:krushi_siksha/data/models/api_models/app_version_model.dart';

void main() {
  group('AppVersionModel & Logic Tests', () {
    test('parses JSON response correctly', () {
      final jsonStr = '''
      {
        "success": true,
        "data": {
          "android": {
            "min_version": "1.0.0",
            "min_build_number": 7,
            "latest_version": "1.0.1",
            "latest_build_number": 8,
            "force_update": true,
            "store_url": "https://play.google.com/store/apps/details?id=com.zappkode.igrow",
            "update_title": "Update Available",
            "update_message": "Please update."
          }
        }
      }
      ''';

      final model = AppVersionResponse.fromJson(json.decode(jsonStr));
      expect(model.success, isTrue);
      expect(model.data?.android?.minBuildNumber, 7);
      expect(model.data?.android?.latestBuildNumber, 8);
      expect(model.data?.android?.forceUpdate, isTrue);
    });

    testWidgets('AppUpdateDialog renders correctly without exit button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppUpdateDialog(
              currentVersion: '1.0.0',
              newVersion: '1.0.1',
              storeUrl: 'https://play.google.com/store/apps/details?id=com.zappkode.igrow',
              title: 'Update Required',
              message: 'A newer version is available. Please update.',
            ),
          ),
        ),
      );

      // Verify Title and Subtitle are present
      expect(find.text('Update Required'), findsOneWidget);
      expect(find.text('A newer version is available. Please update.'), findsOneWidget);

      // Verify versions are shown
      expect(find.text('v1.0.0'), findsOneWidget);
      expect(find.text('v1.0.1'), findsOneWidget);

      // Verify "Update Now" button exists
      expect(find.text('Update Now'), findsOneWidget);

      // Verify NO close (X) or Cancel or Exit button exists
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.text('Cancel'), findsNothing);
      expect(find.text('Exit'), findsNothing);
      expect(find.text('Skip'), findsNothing);
    });
  });
}
