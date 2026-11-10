import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/education.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/education_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Education list supporting isolated dialog edits and reactive CRUD updates.
class EducationStep extends StatefulWidget {
  const EducationStep({super.key});
  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null || (index != null && index >= target.education.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Education>(
        context: context,
        builder: (_) => EducationDialog(
          education: index == null ? null : target.education[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.education.add(result);
      } else if (index < target.education.length) {
        target.education[index] = result;
      }
      _resumes.currentResume.refresh();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
    } finally {
      _dialogOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final target = _resumes.currentResume.value;
    final entries = target?.education ?? <Education>[];
    return ResumeReorderableList(
      key: const PageStorageKey('education-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-education'),
            label: 'add_education'.tr,
            icon: Icons.school_outlined,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_education_added'.tr,
              icon: Icons.school_outlined,
            ),
        ],
      ),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex--;
        entries.insert(newIndex, entries.removeAt(oldIndex));
        _resumes.currentResume.refresh();
      },
      children: [
        for (var index = 0; index < entries.length; index++)
          ResumeEntryCard(
            key: ObjectKey(entries[index]),
            entryKey: 'education-$index',
            title: entries[index].degree,
            details: [
              entries[index].institution,
              entries[index].year,
              if (entries[index].grade?.isNotEmpty ?? false)
                '${'grade'.tr}: ${entries[index].grade}',
              entries[index].description ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.education.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}
