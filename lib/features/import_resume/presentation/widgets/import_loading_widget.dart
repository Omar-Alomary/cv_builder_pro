import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../../../../app/theme/index.dart';

/// Shared animated loading feedback during file selection and decoding.
class ImportLoadingWidget extends StatelessWidget {
  const ImportLoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: AppLoading(message: 'import_loading'.tr),
    ),
  );
}
