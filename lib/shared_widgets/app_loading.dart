import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';

/// Accessible loading feedback with shimmer, determinate progress and reduced motion.
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.message,
    this.progress,
    this.useAnimation = true,
  }) : assert(progress == null || (progress >= 0 && progress <= 1));
  final String? message;
  final double? progress;
  final bool useAnimation;
  @override
  Widget build(BuildContext context) {
    final label = message ?? 'loading'.tr;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final scheme = Theme.of(context).colorScheme;
    final Widget indicator;
    if (progress != null) {
      indicator = CircularProgressIndicator(value: progress);
    } else if (reduced) {
      indicator = Icon(
        Icons.hourglass_empty,
        size: AppSpacing.xxxl,
        color: scheme.primary,
      );
    } else if (useAnimation) {
      indicator = const _LoadingShimmer();
    } else {
      indicator = const CircularProgressIndicator();
    }
    return Semantics(
      liveRegion: true,
      label: label,
      value: progress == null ? null : '${(progress! * 100).round()}%',
      excludeSemantics: true,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.loadingMaxWidth,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                indicator,
                const SizedBox(height: AppSpacing.lg),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.bodySmall,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();
  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context) && !MediaQuery.disableAnimationsOf(context)) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget line(double factor) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: factor,
        child: Container(
          height: AppSpacing.md,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadii.field,
          ),
        ),
      ),
    );
    return SizedBox(
      width: AppSpacing.loadingMaxWidth,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-3 + _controller.value * 4, 0),
            end: Alignment(-1 + _controller.value * 4, 0),
            colors: [
              scheme.surfaceContainerHighest,
              scheme.surface,
              scheme.surfaceContainerHighest,
            ],
          ).createShader(bounds),
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            line(1),
            const SizedBox(height: AppSpacing.md),
            line(.72),
            const SizedBox(height: AppSpacing.md),
            line(.88),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
