import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../data/models/template_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../controllers/template_controller.dart';
import '../../../../shared_widgets/index.dart';

/// Saved template preview with a widget-built fallback when loading fails.
class TemplateMiniPreview extends StatelessWidget {
  const TemplateMiniPreview({
    super.key,
    required this.templateId,
    this.previewImage,
  });
  final String templateId;
  final String? previewImage;
  String get _type => AppConstants.templateType(templateId);
  String? get _image =>
      previewImage ??
      (Get.isRegistered<TemplateController>()
          ? Get.find<TemplateController>()
                .getTemplateById(templateId)
                ?.previewImage
          : null);
  Widget _sample(
    String english,
    String arabic, {
    double size = 6,
    Color color = Colors.black,
  }) => Text(
    Get.locale?.languageCode == 'ar' ? arabic : english,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textScaler: TextScaler.noScaling,
    style: TextStyle(
      fontFamily: Get.locale?.languageCode == 'ar' ? 'Cairo' : 'Poppins',
      fontFamilyFallback: const ['Cairo', 'Poppins'],
      fontSize: size,
      color: color,
      height: 1.4,
    ),
  );
  static Future<void> show(
    BuildContext context,
    TemplateModel template,
    Future<void> Function() onUse,
  ) async {
    await AppBottomSheet.show<void>(
      context: context,
      title: template.localizedName,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: math.min(420, MediaQuery.sizeOf(sheetContext).height * .5),
            child: TemplateMiniPreview(
              templateId: template.id,
              previewImage: template.previewImage,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(template.localizedDescription),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'use_template'.tr,
            fullWidth: true,
            onPressed: () async {
              Navigator.of(sheetContext).pop();
              await onUse();
            },
          ),
        ],
      ),
    );
  }

  Widget _lines(
    int count, {
    Color color = AppColors.lightBorder,
    double thickness = 3,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (var i = 0; i < count; i++) ...[
        FractionallySizedBox(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: i.isEven ? 1 : .75,
          child: Container(height: thickness, color: color),
        ),
        const SizedBox(height: 8),
      ],
    ],
  );
  @override
  Widget build(BuildContext context) => Semantics(
    label: '${'preview'.tr}: ${'template_category_$_type'.tr}',
    image: true,
    child: ExcludeSemantics(
      child: Image.asset(
        _image ?? 'assets/templates/$templateId.png',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDrawing(context),
      ),
    ),
  );

  Widget _buildDrawing(BuildContext context) {
    final ats = _type == 'ats';
    final business = _type == 'business';
    final classic = _type == 'classic';
    final modern = _type == 'modern';
    final arabic = Get.locale?.languageCode == 'ar';
    final accent = ats ? Colors.black : const Color(0xff1565c0);
    final sections = _type == 'technical'
        ? [
            ('PROFESSIONAL SUMMARY', 'الملخص المهني'),
            ('SKILLS', 'المهارات'),
            ('PROJECTS', 'المشاريع'),
          ]
        : [
            ('PROFESSIONAL SUMMARY', 'الملخص المهني'),
            ('WORK EXPERIENCE', 'الخبرات'),
            ('EDUCATION', 'التعليم'),
          ];
    return Semantics(
      label: '${'preview'.tr}: ${'template_category_$_type'.tr}',
      image: true,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: 200,
            height: 280,
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: business ? accent : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  alignment: classic
                      ? Alignment.center
                      : arabic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: _sample(
                    'ALEX MORGAN',
                    'عمر العمري',
                    size: 10,
                    color: business ? Colors.white : accent,
                  ),
                ),
                const SizedBox(height: 4),
                _sample('alex@example.com', 'omar@example.com', size: 5),
                const SizedBox(height: 2),
                _sample('+966 500 000 000', '+966 500 000 000', size: 5),
                for (final section in sections) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: business ? accent : null,
                      border: ats || business
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: classic ? Colors.black : accent,
                                width: modern ? 1 : .4,
                              ),
                            ),
                    ),
                    child: _sample(
                      section.$1,
                      ats ? section.$1 : section.$2,
                      size: 5.5,
                      color: business ? Colors.white : accent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: modern && section.$1 == 'WORK EXPERIENCE'
                        ? BoxDecoration(
                            border: arabic
                                ? Border(right: BorderSide(color: accent))
                                : Border(left: BorderSide(color: accent)),
                          )
                        : null,
                    child: _lines(
                      2,
                      thickness: ats ? .5 : 1,
                      color: ats ? Colors.black : const Color(0xff64748b),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
