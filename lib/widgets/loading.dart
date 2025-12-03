import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Loading extends StatefulWidget {
  const Loading({
    super.key,
    required this.text,
  });

  final String text;

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.greenAccent,
                  ),
                  child: SvgPicture.asset(
                    'images/ai-avatar.svg',
                    height: 30,
                    width: 30,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: isDark
                              ? theme.colorScheme.onSurface
                              : FcColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 14,
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: _WaveDotsPainter(
                                progress: _controller.value,
                                isDark: isDark,
                                color: isDark
                                    ? theme.colorScheme.onSurface
                                    : FcColors.black,
                              ),
                              size: Size(MediaQuery.of(context).size.width, 14),
                            );
                          },
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
    );
  }
}

class _WaveDotsPainter extends CustomPainter {
  const _WaveDotsPainter({
    required this.progress,
    this.isDark = false,
    this.color = Colors.black,
  });

  final double progress;
  final bool isDark;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dotCount = 5;
    const dotSize = 6.0;
    const spacing = 12.0;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final startX = (size.width - ((dotCount - 1) * spacing) - dotSize) / 2;
    final baseY = size.height / 2;
    const amplitude = 6.0;

    for (var i = 0; i < dotCount; i++) {
      final phase = (progress * 2 * math.pi) + (i * 0.6);
      final yOffset = math.sin(phase) * amplitude;

      final dx = startX + (i * spacing);
      final dy = baseY - yOffset;

      canvas.drawCircle(Offset(dx, dy), dotSize / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveDotsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
