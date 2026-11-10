import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/index.dart';

/// Keyboard-aware editor dialog with an icon header and reachable form actions.
class ResumeFormDialog extends StatelessWidget {
  const ResumeFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    this.icon = Icons.edit_note_outlined,
  });
  final String title;
  final Widget child;
  final VoidCallback onSave;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.dialog),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        key: const ValueKey('resume-form-dialog-surface'),
        constraints: BoxConstraints(
          maxWidth: Responsive.value<double>(
            context: context,
            mobile: 500,
            tablet: 600,
            desktop: 650,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Icon(
                        icon,
                        color: scheme.primary,
                        size: AppSpacing.xl,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: AppTextStyles.resolve(context, AppTextStyles.h4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              child,
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const ValueKey('save-resume-entry'),
                label: 'save'.tr,
                icon: Icons.check,
                fullWidth: true,
                onPressed: onSave,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'cancel'.tr,
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
