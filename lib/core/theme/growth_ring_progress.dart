import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// The signature "Growth Ring" progress indicator — a circular arc
/// painted like a tree growth ring, used throughout IGrow for
/// course completion, wallet, streaks, and certificate progress.
///
/// Parameters:
/// - [percent] 0.0–1.0 progress value.
/// - [size] diameter of the ring.
/// - [strokeWidth] thickness of the arc.
/// - [color] fill color of the arc; defaults to [AppColors.primaryGreen].
/// - [backgroundColor] track color behind the arc.
/// - [label] optional text shown in the center.
/// - [sublabel] optional smaller text below [label].
/// - [animated] whether to animate on first render.
/// - [duration] animation duration.
/// - [child] optional widget to place inside the ring.
class GrowthRingProgress extends StatefulWidget {
  const GrowthRingProgress({
    super.key,
    required this.percent,
    this.size = 100,
    this.strokeWidth = 10,
    this.color,
    this.backgroundColor,
    this.label,
    this.sublabel,
    this.animated = true,
    this.duration = const Duration(milliseconds: 1200),
    this.child,
  });

  final double percent;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final String? label;
  final String? sublabel;
  final bool animated;
  final Duration duration;
  final Widget? child;

  @override
  State<GrowthRingProgress> createState() => _GrowthRingProgressState();
}

class _GrowthRingProgressState extends State<GrowthRingProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0, end: widget.percent).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Respect system reduce-motion setting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reduceMotion =
          MediaQuery.of(context).disableAnimations;
      if (widget.animated && !reduceMotion) {
        _controller.forward();
      } else {
        _controller.value = 1.0;
      }
    });
  }

  @override
  void didUpdateWidget(GrowthRingProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.percent,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ringColor = widget.color ?? AppColors.primaryGreen;
    final trackColor = widget.backgroundColor ??
        (isDark
            ? AppColors.lineDark
            : AppColors.lineLight);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _GrowthRingPainter(
              percent: _animation.value,
              strokeWidth: widget.strokeWidth,
              color: ringColor,
              backgroundColor: trackColor,
            ),
            child: child,
          ),
        );
      },
      child: Center(
        child: widget.child ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: AppTypography.headlineSmall(
                      color: isDark ? AppColors.white : AppColors.inkDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (widget.sublabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      widget.sublabel!,
                      style: AppTypography.bodySmall(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.6)
                            : AppColors.inkSoft,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}

class _GrowthRingPainter extends CustomPainter {
  _GrowthRingPainter({
    required this.percent,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  final double percent;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2; // 12 o'clock
    final sweepAngle = 2 * math.pi * percent.clamp(0.0, 1.0);

    // Track ring.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc.
    if (percent > 0) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = color
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GrowthRingPainter oldDelegate) =>
      percent != oldDelegate.percent ||
      color != oldDelegate.color ||
      backgroundColor != oldDelegate.backgroundColor;
}
