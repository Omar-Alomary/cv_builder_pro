import '../../../../app/theme/index.dart';
import 'interests_step.dart';
import 'achievements_step.dart';
import 'projects_step.dart';
import 'languages_step.dart';
import 'certificates_step.dart';
import 'courses_step.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/template_fields.dart';
import '../../../../shared_widgets/index.dart';

/// Controlled additional sections with direct selection and reversible navigation.
class AdditionalInfoStep extends StatelessWidget {
  const AdditionalInfoStep({
    super.key,
    required this.fields,
    required this.selectedIndex,
    required this.onSelected,
  });
  final TemplateFields fields;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static List<String> sectionKeys(TemplateFields fields) => [
    if (fields.showCourses) 'courses',
    if (fields.showCertificates) 'certificates',
    if (fields.showLanguages) 'languages',
    if (fields.showProjects) 'projects',
    if (fields.showAchievements) 'achievements',
    if (fields.showInterests) 'interests',
  ];
  @override
  Widget build(BuildContext context) {
    final sections = sectionKeys(fields);
    if (sections.isEmpty) {
      return AppEmptyState(title: 'no_additional_sections'.tr);
    }
    final selected = selectedIndex.clamp(0, sections.length - 1);
    final child = switch (sections[selected]) {
      'courses' => const CoursesStep(),
      'certificates' => const CertificatesStep(),
      'languages' => const LanguagesStep(),
      'projects' => const ProjectsStep(),
      'achievements' => const AchievementsStep(),
      _ => const InterestsStep(),
    };
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              for (var index = 0; index < sections.length; index++)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
                  child: ChoiceChip(
                    key: ValueKey('additional-${sections[index]}'),
                    selected: selected == index,
                    label: Text(sections[index].tr),
                    onSelected: (_) => onSelected(index),
                  ),
                ),
            ],
          ),
        ),
        Text(
          'builder_section_position'.trParams({
            'current': '${selected + 1}',
            'total': '${sections.length}',
          }),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : AppTheme.motionDuration,
            layoutBuilder: (current, previous) =>
                Stack(fit: StackFit.expand, children: [...previous, ?current]),
            child: KeyedSubtree(
              key: ValueKey(sections[selected]),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
