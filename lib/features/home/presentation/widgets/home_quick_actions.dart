import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Three guarded shortcut actions with high-contrast gradient backgrounds.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.onCreate});
  final Future<void> Function() onCreate;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale =
          MediaQuery.textScalerOf(
            context,
          ).scale(AppTextStyles.button.fontSize!) /
          AppTextStyles.button.fontSize!;
      final values = [
        (
          'create-resume',
          'create_new',
          Icons.add,
          AppColors.primaryGradient,
          onCreate,
        ),
        (
          'import-resume',
          'import_resume',
          Icons.upload_file_outlined,
          AppColors.successGradient,
          () async {
            await Get.toNamed<void>(AppRoutes.importResume);
          },
        ),
        (
          'check-ats',
          'ats_checker',
          Icons.fact_check_outlined,
          AppColors.warmGradient,
          () async {
            await Get.toNamed<void>(AppRoutes.atsChecker);
          },
        ),
      ];
      Widget action(int index) => AppButton(
        key: ValueKey(values[index].$1),
        label: values[index].$2.tr,
        icon: values[index].$3,
        gradient: values[index].$4,
        iconOnTop: scale <= 1.3,
        size: AppButtonSize.sm,
        fullWidth: true,
        onPressed: values[index].$5,
      );
      if (scale > 1.3 || constraints.maxWidth < 300) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < values.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              action(i),
            ],
          ],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < values.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: action(i)),
            ],
          ],
        ),
      );
    },
  );
}
