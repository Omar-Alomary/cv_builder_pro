import 'package:flutter/material.dart';
import '../app/theme/index.dart';
import 'app_hero.dart';
import '../core/constants/app_constants.dart';

/// Stable template icon shared between the catalog and the resume editor.
class AppTemplateIcon extends StatelessWidget {
  const AppTemplateIcon({
    super.key,
    required this.templateId,
    this.size = AppSpacing.xxl,
  });
  final String templateId;
  final double size;
  @override
  Widget build(BuildContext context) => AppHero(
    tag: 'cv-template-$templateId',
    child: Icon(
      switch (AppConstants.templateType(templateId)) {
        'modern' => Icons.auto_awesome_outlined,
        'business' => Icons.business_center_outlined,
        'technical' => Icons.code,
        'ats' => Icons.fact_check_outlined,
        _ => Icons.description_outlined,
      },
      color: Theme.of(context).colorScheme.primary,
      size: size,
    ),
  );
}
