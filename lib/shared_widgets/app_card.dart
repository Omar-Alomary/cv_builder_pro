import 'package:flutter/material.dart';
import '../app/theme/index.dart';

/// Surface card with restrained shadows, focus feedback and optional activation.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.semanticsLabel,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;
  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hover = false, _pressed = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interactive = widget.onTap != null;
    return Semantics(
      button: interactive,
      label: widget.semanticsLabel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: interactive && !MediaQuery.disableAnimationsOf(context)
              ? _pressed
                    ? 0.98
                    : _hover
                    ? 1.02
                    : 1
              : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : AppTheme.motionDuration,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadii.card,
              boxShadow: AppShadows.forBrightness(theme.brightness),
            ),
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: AppRadii.card,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: AppRadii.card,
                onHighlightChanged: (value) => setState(() => _pressed = value),
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
