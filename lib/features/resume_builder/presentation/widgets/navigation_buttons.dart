import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../../../../app/theme/index.dart';

/// Editor navigation that stacks actions when width or text scale requires it.
class NavigationButtons extends StatelessWidget {
  const NavigationButtons({
    super.key,
    required this.canGoBack,
    required this.isLastStep,
    required this.onPrevious,
    required this.onNext,
    this.busy = false,
  });
  final bool canGoBack;
  final bool isLastStep;
  final bool busy;
  final VoidCallback onPrevious;
  final Future<void> Function() onNext;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final previous = AppButton(
        key: const ValueKey('builder-previous'),
        label: 'previous'.tr,
        icon: Icons.arrow_back,
        fullWidth: true,
        variant: AppButtonVariant.secondary,
        onPressed: busy ? null : onPrevious,
      );
      final next = AppButton(
        key: const ValueKey('builder-next'),
        label: (isLastStep ? 'finish' : 'next').tr,
        icon: isLastStep ? Icons.check : Icons.arrow_forward,
        fullWidth: true,
        onPressed: busy ? null : onNext,
      );
      if (!canGoBack) return next;
      if (constraints.maxWidth < 400 ||
          MediaQuery.textScalerOf(context).scale(14) > 21) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            previous,
            const SizedBox(height: AppSpacing.sm),
            next,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: previous),
          const SizedBox(width: AppSpacing.md),
          Expanded(flex: 2, child: next),
        ],
      );
    },
  );
}
