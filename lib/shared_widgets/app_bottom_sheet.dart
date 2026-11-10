import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';
import '../core/utils/responsive.dart';

/// Keyboard-aware modal sheet with a drag handle and a scrollable content area.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });
  final String title;
  final Widget child;
  final IconData? icon;
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder builder,
    IconData? icon,
    bool isDismissible = true,
    bool enableDrag = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: false,
    constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth / 2),
    builder: (sheetContext) =>
        AppBottomSheet(title: title, icon: icon, child: builder(sheetContext)),
  );
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final available = math.max(
      AppSpacing.none,
      media.size.height - media.viewInsets.bottom - media.padding.top,
    );
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: available * .9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: AppSpacing.sm,
                ),
                child: Container(
                  width: AppSpacing.xxxl,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: scheme.outline,
                    borderRadius: AppRadii.chip,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.lg,
                  end: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: AppTextStyles.resolve(
                            context,
                            AppTextStyles.h4,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'close'.tr,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
