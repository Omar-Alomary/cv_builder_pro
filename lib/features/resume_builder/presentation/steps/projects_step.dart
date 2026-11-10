import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/project.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/project_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Project list supporting isolated dialog edits and reactive CRUD updates.
class ProjectsStep extends StatefulWidget {
  const ProjectsStep({super.key});
  @override
  State<ProjectsStep> createState() => _ProjectsStepState();
}

class _ProjectsStepState extends State<ProjectsStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null || (index != null && index >= target.projects.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Project>(
        context: context,
        builder: (_) => ProjectDialog(
          project: index == null ? null : target.projects[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.projects.add(result);
      } else if (index < target.projects.length) {
        target.projects[index] = result;
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
    final entries = target?.projects ?? <Project>[];
    return ResumeReorderableList(
      key: const PageStorageKey('projects-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-projects'),
            label: 'add_project'.tr,
            icon: Icons.code,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(title: 'no_projects_added'.tr, icon: Icons.code),
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
            entryKey: 'project-$index',
            title: entries[index].name,
            details: [
              entries[index].description,
              '${entries[index].startDate} — ${entries[index].isCurrent ? 'builder_present'.tr : entries[index].endDate ?? ''}',
              entries[index].technologies.join(', '),
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.projects.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}
