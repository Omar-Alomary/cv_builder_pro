import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';

/// Gradient score ring with a readable numeric and spoken equivalent.
class AtsScoreGauge extends StatelessWidget {
  const AtsScoreGauge({super.key, required this.score});
  final int score;
  @override
  Widget build(BuildContext context) {
    final value = score.clamp(0, 100);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'ats_score_out_of'.trParams({'score': '$value'}),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ats_score'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.resolve(context, AppTextStyles.h4),
            ),
            const SizedBox(height: AppSpacing.xl),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = math.min(
                  AppSpacing.xxxl * 5,
                  constraints.maxWidth,
                );
                return SizedBox.square(
                  dimension: width,
                  child: CustomPaint(
                    painter: _GaugePainter(value, scheme.outlineVariant),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$value',
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.display,
                            ).copyWith(color: scheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'ats_score_out_of'.trParams({'score': '$value'}),
              textAlign: TextAlign.center,
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.bodySmall,
              ).copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.score, this.background);
  final int score;
  final Color background;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(AppSpacing.md);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = AppSpacing.md
      ..strokeCap = StrokeCap.round
      ..color = background;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, paint);
    if (score <= 0) return;
    final orange = Color.lerp(AppColors.error, AppColors.accent, .5)!;
    final tone = score < 25
        ? Color.lerp(AppColors.error, orange, score / 25)!
        : score < 50
        ? Color.lerp(orange, AppColors.accent, (score - 25) / 25)!
        : Color.lerp(
            AppColors.accent,
            AppColors.success,
            ((score - 50) / 25).clamp(0.0, 1.0),
          )!;
    paint.shader = SweepGradient(
      transform: const GradientRotation(-math.pi / 2),
      colors: [tone, Color.lerp(tone, AppColors.lightSurface, .2)!, tone],
    ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * score / 100, false, paint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      score != oldDelegate.score || background != oldDelegate.background;
}
