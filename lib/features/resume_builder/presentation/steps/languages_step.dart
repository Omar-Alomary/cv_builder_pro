import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/language.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/language_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Language list supporting isolated dialog edits and reactive CRUD updates.
class LanguagesStep extends StatefulWidget {
  const LanguagesStep({super.key});
  @override
  State<LanguagesStep> createState() => _LanguagesStepState();
}

class _LanguagesStepState extends State<LanguagesStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null || (index != null && index >= target.languages.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Language>(
        context: context,
        builder: (_) => ResumeLanguageDialog(
          language: index == null ? null : target.languages[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.languages.add(result);
      } else if (index < target.languages.length) {
        target.languages[index] = result;
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
    final entries = target?.languages ?? <Language>[];
    return ResumeReorderableList(
      key: const PageStorageKey('languages-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-languages'),
            label: 'add_language'.tr,
            icon: Icons.translate,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_languages_added'.tr,
              icon: Icons.translate,
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
            entryKey: 'language-$index',
            title: entries[index].name,
            details: [ResumeLanguageDialog.levelLabel(entries[index].level)],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.languages.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}
