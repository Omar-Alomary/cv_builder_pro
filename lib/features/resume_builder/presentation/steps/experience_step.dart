import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/experience.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/experience_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Work history list with localized current employment and complete descriptions.
class ExperienceStep extends StatefulWidget {
  const ExperienceStep({super.key});
  @override
  State<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends State<ExperienceStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null ||
        (index != null && index >= target.experience.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Experience>(
        context: context,
        builder: (_) => ExperienceDialog(
          experience: index == null ? null : target.experience[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.experience.add(result);
      } else if (index < target.experience.length) {
        target.experience[index] = result;
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
    final entries = target?.experience ?? <Experience>[];
    return ResumeReorderableList(
      key: const PageStorageKey('experience-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-experience'),
            label: 'add_experience'.tr,
            icon: Icons.work_outline,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_experience_added'.tr,
              icon: Icons.work_outline,
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
            entryKey: 'experience-$index',
            title: entries[index].jobTitle,
            details: [
              entries[index].company,
              '${entries[index].startDate} - ${entries[index].isCurrent ? 'builder_present'.tr : entries[index].endDate ?? ''}',
              entries[index].description ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.experience.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}
