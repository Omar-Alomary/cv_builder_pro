import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';

/// Filled or bordered appearance for reusable labels and selectable chips.
enum AppChipVariant { filled, outlined }

/// Native keyboard-accessible chip supporting selection, actions and removal.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.selected = false,
    this.variant = AppChipVariant.filled,
  }) : assert(onSelected == null || onPressed == null);
  final String label;
  final IconData? icon;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onPressed, onDeleted;
  final bool selected;
  final AppChipVariant variant;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelWidget = Text(
      label,
      style: AppTextStyles.resolve(
        context,
        AppTextStyles.label,
      ).copyWith(color: scheme.onPrimaryContainer),
    );
    final avatar = icon == null
        ? null
        : Icon(icon, size: AppSpacing.icon, color: scheme.primary);
    final background = variant == AppChipVariant.filled
        ? scheme.primaryContainer
        : scheme.surface;
    final side = BorderSide(
      color: variant == AppChipVariant.outlined
          ? scheme.outline
          : AppColors.transparent,
    );
    if (onSelected == null && onPressed == null && onDeleted == null) {
      return Chip(
        label: labelWidget,
        avatar: avatar,
        backgroundColor: background,
        side: side,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.chip),
      );
    }
    return InputChip(
      label: Text(
        label,
        style: AppTextStyles.resolve(context, AppTextStyles.label),
      ),
      avatar: icon == null
          ? null
          : Icon(icon, size: AppSpacing.icon, color: scheme.primary),
      selected: selected,
      showCheckmark: icon == null,
      onSelected: onSelected,
      onPressed: onPressed,
      onDeleted: onDeleted,
      deleteButtonTooltipMessage: 'delete'.tr,
      backgroundColor: variant == AppChipVariant.filled
          ? scheme.primaryContainer
          : scheme.surface,
      selectedColor: scheme.primaryContainer,
      side: BorderSide(
        color: variant == AppChipVariant.outlined
            ? scheme.outline
            : AppColors.transparent,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.chip),
    );
  }
}
