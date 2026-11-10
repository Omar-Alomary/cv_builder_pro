import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Deterministic low-contrast particles for the finite splash animation.
class ParticlePainter extends CustomPainter {
  const ParticlePainter({
    required this.progress,
    this.color = AppColors.lightSurface,
  });
  final double progress;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()..color = color.withValues(alpha: .22);
    for (var index = 0; index < 32; index++) {
      final position = Offset(
        size.width * random.nextDouble(),
        size.height * random.nextDouble(),
      );
      final radius =
          AppSpacing.focusStroke *
          random.nextDouble() *
          progress.clamp(0.0, 1.0);
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
