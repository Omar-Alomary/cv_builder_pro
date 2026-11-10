import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/achievement.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/achievement_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Achievement list supporting isolated dialog edits and reactive CRUD updates.
class AchievementsStep extends StatefulWidget {
  const AchievementsStep({super.key});
  @override
  State<AchievementsStep> createState() => _AchievementsStepState();
}

class _AchievementsStepState extends State<AchievementsStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null ||
        (index != null && index >= target.achievements.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Achievement>(
        context: context,
        builder: (_) => AchievementDialog(
          achievement: index == null ? null : target.achievements[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.achievements.add(result);
      } else if (index < target.achievements.length) {
        target.achievements[index] = result;
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
    final entries = target?.achievements ?? <Achievement>[];
    return ResumeReorderableList(
      key: const PageStorageKey('achievements-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-achievements'),
            label: 'add_achievement'.tr,
            icon: Icons.emoji_events_outlined,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_achievements_added'.tr,
              icon: Icons.emoji_events_outlined,
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
            entryKey: 'achievement-$index',
            title: entries[index].name,
            details: [
              entries[index].description,
              entries[index].date,
              entries[index].organization ?? '',
              entries[index].category ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.achievements.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}
