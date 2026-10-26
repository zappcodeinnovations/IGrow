import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Centralized Organic Nature Background for IGrow.
///
/// Features dynamic watercolor waves, floating botanical leaves, soft ambient
/// particles, and starburst sparks. Seamlessly adapts between Light and Dark themes.
class OrganicBackground extends StatelessWidget {
  const OrganicBackground({
    super.key,
    required this.child,
    this.showTopBlobs = true,
    this.showBottomBlobs = true,
    this.showLeaves = true,
    this.showSparks = true,
  });

  final Widget child;
  final bool showTopBlobs;
  final bool showBottomBlobs;
  final bool showLeaves;
  final bool showSparks;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? const Color(0xFF101913) : const Color(0xFFFAFBF8),
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.organicCanvasLight,
        body: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                size: Size(screenSize.width, screenSize.height),
                painter: OrganicBackgroundPainter(
                  isDark: isDark,
                  showTopBlobs: showTopBlobs,
                  showBottomBlobs: showBottomBlobs,
                  showLeaves: showLeaves,
                  showSparks: showSparks,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// Custom painter for organic watercolor waves, botanical leaves, and sparks.
class OrganicBackgroundPainter extends CustomPainter {
  final bool isDark;
  final bool showTopBlobs;
  final bool showBottomBlobs;
  final bool showLeaves;
  final bool showSparks;

  const OrganicBackgroundPainter({
    this.isDark = false,
    this.showTopBlobs = true,
    this.showBottomBlobs = true,
    this.showLeaves = true,
    this.showSparks = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Canvas
    final bgRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? const [
                Color(0xFF14201A),
                Color(0xFF101C16),
                Color(0xFF0C1611),
              ]
            : const [
                Color(0xFFFCFDFB),
                Color(0xFFF7FAF4),
                Color(0xFFF1F5ED),
              ],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, bgPaint);

    // 2. Top-Right Organic Fluid Shapes
    if (showTopBlobs) {
      // Layer 1: Warm biscuit/amber wash
      final trBeigePath = Path()
        ..moveTo(size.width * 0.62, 0)
        ..cubicTo(
          size.width * 0.72,
          size.height * 0.15,
          size.width * 0.78,
          size.height * 0.32,
          size.width,
          size.height * 0.45,
        )
        ..lineTo(size.width, 0)
        ..close();
      canvas.drawPath(
        trBeigePath,
        Paint()
          ..color = isDark ? const Color(0x22F59500) : const Color(0x73EFE3D3)
          ..isAntiAlias = true,
      );

      // Layer 2: Translucent broad sage watercolor wave
      final trSagePath = Path()
        ..moveTo(size.width * 0.46, 0)
        ..cubicTo(
          size.width * 0.58,
          size.height * 0.08,
          size.width * 0.68,
          size.height * 0.10,
          size.width * 0.84,
          size.height * 0.18,
        )
        ..cubicTo(
          size.width * 0.92,
          size.height * 0.22,
          size.width * 0.98,
          size.height * 0.25,
          size.width,
          size.height * 0.28,
        )
        ..lineTo(size.width, 0)
        ..close();

      final trSageShader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0x353B6E44), Color(0x20244F2C)]
            : const [Color(0x999EC19B), Color(0x667AA678)],
      ).createShader(Rect.fromLTWH(
        size.width * 0.46,
        0,
        size.width * 0.54,
        size.height * 0.28,
      ));

      canvas.drawPath(
        trSagePath,
        Paint()
          ..shader = trSageShader
          ..isAntiAlias = true,
      );

      // Layer 3: Lush watercolor sage fluid wave
      final trGreenPath = Path()
        ..moveTo(size.width * 0.54, 0)
        ..cubicTo(
          size.width * 0.64,
          size.height * 0.04,
          size.width * 0.74,
          size.height * 0.08,
          size.width * 0.88,
          size.height * 0.09,
        )
        ..cubicTo(
          size.width * 0.94,
          size.height * 0.10,
          size.width * 0.98,
          size.height * 0.14,
          size.width,
          size.height * 0.18,
        )
        ..lineTo(size.width, 0)
        ..close();

      final trGreenShader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0x55285731), Color(0x40366D3E), Color(0x2B4B8055)]
            : const [Color(0xE65B8C61), Color(0xCC72A478), Color(0xB38EB894)],
      ).createShader(Rect.fromLTWH(
        size.width * 0.54,
        0,
        size.width * 0.46,
        size.height * 0.18,
      ));

      canvas.drawPath(
        trGreenPath,
        Paint()
          ..shader = trGreenShader
          ..isAntiAlias = true,
      );
    }

    // 3. Bottom-Left Organic Fluid Shapes
    if (showBottomBlobs) {
      // Layer 1: Warm sand/khaki underlayer
      final blBeigePath = Path()
        ..moveTo(0, size.height * 0.56)
        ..cubicTo(
          size.width * 0.18,
          size.height * 0.58,
          size.width * 0.42,
          size.height * 0.74,
          size.width * 0.46,
          size.height,
        )
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(
        blBeigePath,
        Paint()
          ..color = isDark ? const Color(0x1F4D3C22) : const Color(0x8CEAE1CF)
          ..isAntiAlias = true,
      );

      // Layer 2: Soft olive/sage fluid blob
      final blSagePath = Path()
        ..moveTo(0, size.height * 0.60)
        ..cubicTo(
          size.width * 0.16,
          size.height * 0.62,
          size.width * 0.28,
          size.height * 0.68,
          size.width * 0.30,
          size.height * 0.82,
        )
        ..cubicTo(
          size.width * 0.31,
          size.height * 0.90,
          size.width * 0.34,
          size.height * 0.96,
          size.width * 0.38,
          size.height,
        )
        ..lineTo(0, size.height)
        ..close();

      final blSageShader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomRight,
        colors: isDark
            ? const [Color(0x442C5435), Color(0x333F6E47)]
            : const [Color(0xD983A580), Color(0xCCA2BE9E)],
      ).createShader(Rect.fromLTWH(
        0,
        size.height * 0.60,
        size.width * 0.38,
        size.height * 0.40,
      ));

      canvas.drawPath(
        blSagePath,
        Paint()
          ..shader = blSageShader
          ..isAntiAlias = true,
      );
    }

    // 4. Floating Botanical Leaves
    if (showLeaves) {
      _drawLeaf(
        canvas,
        center: Offset(size.width * 0.81, size.height * 0.19),
        width: 20,
        length: 34,
        rotationAngle: -0.65,
        color: isDark ? const Color(0xFF5CB766) : const Color(0xFF558752),
      );

      _drawLeaf(
        canvas,
        center: Offset(size.width * 0.865, size.height * 0.205),
        width: 14,
        length: 24,
        rotationAngle: -0.28,
        color: isDark ? const Color(0xFF75C77F) : const Color(0xFF6B9968),
      );

      _drawLeaf(
        canvas,
        center: Offset(size.width * 0.36, size.height * 0.715),
        width: 16,
        length: 28,
        rotationAngle: 0.75,
        color: isDark ? const Color(0xFF62BC6C) : const Color(0xFF5A8857),
      );
    }

    // 5. Floating Soft Orbs & Celebration Sparks
    if (showSparks) {
      canvas.drawCircle(
        Offset(size.width * 0.615, size.height * 0.138),
        7.5,
        Paint()
          ..color = isDark ? const Color(0x8075C31A) : const Color(0xFF5C895A)
          ..isAntiAlias = true,
      );

      canvas.drawCircle(
        Offset(size.width * 0.485, size.height * 0.058),
        5.0,
        Paint()
          ..color = isDark ? const Color(0x709BD955) : const Color(0xFF7D9F7B)
          ..isAntiAlias = true,
      );

      canvas.drawCircle(
        Offset(size.width * 0.33, size.height * 0.645),
        5.5,
        Paint()
          ..color = isDark ? const Color(0x60F59500) : const Color(0xFFD8CCA8)
          ..isAntiAlias = true,
      );

      _drawStarburst(
        canvas,
        center: Offset(size.width * 0.905, size.height * 0.082),
        innerRadius: 4.5,
        outerRadius: 10.5,
        strokeWidth: 2.2,
        color: isDark ? const Color(0x9984D357) : const Color(0xFF8BA889),
      );

      _drawStarburst(
        canvas,
        center: Offset(size.width * 0.905, size.height * 0.292),
        innerRadius: 4.5,
        outerRadius: 10.5,
        strokeWidth: 2.2,
        color: isDark ? const Color(0x889AE06C) : const Color(0xFF99B596),
      );
    }
  }

  void _drawLeaf(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double length,
    required double rotationAngle,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final path = Path();
    path.moveTo(0, -length / 2);
    path.quadraticBezierTo(width / 1.5, 0, 0, length / 2);
    path.quadraticBezierTo(-width / 1.5, 0, 0, -length / 2);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = true
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  void _drawStarburst(
    Canvas canvas, {
    required Offset center,
    required double innerRadius,
    required double outerRadius,
    required double strokeWidth,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = i * (math.pi / 4);
      final p1 = Offset(
        center.dx + math.cos(angle) * innerRadius,
        center.dy + math.sin(angle) * innerRadius,
      );
      final p2 = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant OrganicBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.showTopBlobs != showTopBlobs ||
      oldDelegate.showBottomBlobs != showBottomBlobs ||
      oldDelegate.showLeaves != showLeaves ||
      oldDelegate.showSparks != showSparks;
}

/// Celebration Sparkles around Clapping Emoji (👏)
class EmojiCelebrationPainter extends CustomPainter {
  final bool isDark;
  const EmojiCelebrationPainter({this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF8CD848) : const Color(0xFF6E866D)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(3, 10), const Offset(0, 5), paint);
    canvas.drawLine(const Offset(8, 7), const Offset(8, 2), paint);
    canvas.drawLine(const Offset(13, 8), const Offset(17, 4), paint);
    canvas.drawLine(const Offset(14, 13), const Offset(19, 13), paint);
  }

  @override
  bool shouldRepaint(covariant EmojiCelebrationPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
