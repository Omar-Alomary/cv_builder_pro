import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Gradient skill level with native progress semantics and a stable text value.
class SkillLevelIndicator extends StatelessWidget {
  const SkillLevelIndicator({
    super.key,
    required this.name,
    required this.level,
  });
  final String name;
  final int level;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: AppRadii.chip,
      child: ColoredBox(
        color: scheme.primaryContainer,
        child: ShaderMask(
          shaderCallback: (bounds) => AppColors.coolGradient.createShader(
            bounds,
            textDirection: Directionality.of(context),
          ),
          blendMode: BlendMode.srcIn,
          child: LinearProgressIndicator(
            minHeight: AppSpacing.sm,
            value: level.clamp(1, 5) / 5,
            color: AppColors.lightSurface,
            backgroundColor: AppColors.transparent,
            semanticsLabel: name,
            semanticsValue: '$level/5',
          ),
        ),
      ),
    );
  }
}
