import 'package:flutter/material.dart';
import '../../../../app/theme/index.dart';

/// Numbered stages with completion checks, connectors and native selection.
class StepIndicator extends StatefulWidget {
  const StepIndicator({
    super.key,
    required this.labels,
    required this.currentStep,
    required this.onSelected,
  });
  final List<String> labels;
  final int currentStep;
  final ValueChanged<int>? onSelected;
  @override
  State<StepIndicator> createState() => _StepIndicatorState();
}

class _StepIndicatorState extends State<StepIndicator> {
  final _scroll = ScrollController();
  final _targets = <GlobalKey>[];
  void _reveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_scroll.hasClients ||
          widget.currentStep >= _targets.length) {
        return;
      }
      final target = _targets[widget.currentStep].currentContext
          ?.findRenderObject();
      if (target == null) return;
      _scroll.position.ensureVisible(
        target,
        alignment: .5,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : AppTheme.motionDuration,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(covariant StepIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep ||
        oldWidget.labels.length != widget.labels.length) {
      _reveal();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.labels;
    final currentStep = widget.currentStep;
    final onSelected = widget.onSelected;
    while (_targets.length < labels.length) {
      _targets.add(GlobalKey());
    }
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < labels.length; index++) ...[
            KeyedSubtree(
              key: _targets[index],
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(canvasColor: Colors.transparent),
                child: ChoiceChip(
                  key: ValueKey('builder-step-$index'),
                  selected: currentStep == index,
                  showCheckmark: false,
                  side: BorderSide.none,
                  backgroundColor: AppColors.transparent,
                  selectedColor: AppColors.transparent,
                  color: const WidgetStatePropertyAll(Colors.transparent),
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  pressElevation: 0,
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  label: SizedBox(
                    width: AppSpacing.xxxl * 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: AppSpacing.touchTarget,
                          height: AppSpacing.touchTarget,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: index <= currentStep
                                ? AppColors.primaryGradient
                                : null,
                            color: index > currentStep
                                ? scheme.primaryContainer
                                : null,
                            border: Border.all(
                              color: index <= currentStep
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                            ),
                          ),
                          child: index < currentStep
                              ? const Icon(
                                  Icons.check,
                                  color: AppColors.lightSurface,
                                  size: AppSpacing.xl,
                                )
                              : Text(
                                  '${index + 1}',
                                  textScaler: TextScaler.noScaling,
                                  style: AppTextStyles.h4.copyWith(
                                    color: index == currentStep
                                        ? AppColors.lightSurface
                                        : scheme.primary,
                                  ),
                                ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          labels[index],
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTextStyles.resolve(
                                context,
                                AppTextStyles.caption,
                              ).copyWith(
                                color: index == currentStep
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  onSelected: onSelected == null
                      ? null
                      : (_) => onSelected(index),
                ),
              ),
            ),
            if (index < labels.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Container(
                  width: AppSpacing.xl,
                  height: AppSpacing.focusStroke,
                  color: index < currentStep
                      ? scheme.primary
                      : scheme.outlineVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
