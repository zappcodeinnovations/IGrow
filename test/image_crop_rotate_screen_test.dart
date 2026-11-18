import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:krushi_siksha/core/widgets/image_crop_rotate_screen.dart';

final kTransparentPngBytes = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  late File tempFile;

  setUp(() async {
    tempFile = File('${Directory.systemTemp.path}/test_sig_${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(kTransparentPngBytes);
  });

  tearDown(() async {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  group('ImageCropRotateScreen Widget Tests', () {
    testWidgets('renders crop and rotate UI controls properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImageCropRotateScreen(
            imageFile: tempFile,
            title: 'Crop & Rotate Signature',
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Verify title is rendered
      expect(find.text('Crop & Rotate Signature'), findsOneWidget);

      // Verify action buttons are rendered
      expect(find.text('Rotate Left'), findsOneWidget);
      expect(find.text('Rotate Right'), findsOneWidget);
      expect(find.text('Flip 180°'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // Verify Aspect Ratio pills are rendered
      expect(find.text('Free'), findsOneWidget);
      expect(find.text('1:1'), findsOneWidget);
      expect(find.text('4:3'), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);

      // Tap Rotate Right button
      await tester.tap(find.text('Rotate Right'));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap Rotate Left button
      await tester.tap(find.text('Rotate Left'));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap Flip 180° button
      await tester.tap(find.text('Flip 180°'));
      await tester.pump(const Duration(milliseconds: 50));

      // Select 1:1 Aspect ratio
      await tester.tap(find.text('1:1'));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap Reset icon
      await tester.tap(find.byTooltip('Reset'));
      await tester.pump(const Duration(milliseconds: 50));

      // Tap Cancel / Close button
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
