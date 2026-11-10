import 'dart:async';
import 'package:flutter/material.dart';
import '../app/theme/index.dart';
import 'app_button.dart';

/// Scrollable empty state with a tinted illustration and optional primary CTA.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.description_outlined,
    this.actionLabel,
    this.onAction,
  }) : assert((actionLabel == null) == (onAction == null));
  final String title;
  final String? description, actionLabel;
  final IconData icon;
  final FutureOr<void> Function()? onAction;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.emptyMaxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                  ),
                  child: Icon(
                    icon,
                    size: AppSpacing.emptyIcon,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.h4,
                  ).copyWith(color: scheme.onSurface),
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.bodySmall,
                  ).copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              if (actionLabel != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
