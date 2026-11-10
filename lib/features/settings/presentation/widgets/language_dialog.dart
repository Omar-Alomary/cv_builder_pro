import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Returns a selected language so the caller can persist it after closing.
class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key, required this.selectedLanguage});
  final String selectedLanguage;
  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
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
            Icon(
              Icons.translate,
              color: Theme.of(context).colorScheme.primary,
              size: AppSpacing.xxl,
            ),
            const SizedBox(height: AppSpacing.md),
            AppSectionHeader(title: 'select_language'.tr),
            const SizedBox(height: AppSpacing.xl),
            for (final code in ['en', 'ar'])
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppButton(
                  key: ValueKey('settings-language-$code'),
                  label: (code == 'ar' ? 'language_arabic' : 'language_english')
                      .tr,
                  icon: selectedLanguage == code
                      ? Icons.check_circle
                      : Icons.language,
                  fullWidth: true,
                  variant: selectedLanguage == code
                      ? AppButtonVariant.primary
                      : AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(code),
                ),
              ),
            AppButton(
              label: 'cancel'.tr,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
