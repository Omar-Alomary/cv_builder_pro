import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/ats_scorer.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_entry_card.dart';

/// Manages translated suggestions and arbitrary interests without duplicates.
class InterestsStep extends StatefulWidget {
  const InterestsStep({super.key});
  static const suggestions = [
    'Reading',
    'Travel',
    'Music',
    'Sports',
    'Photography',
    'Coding',
    'Art',
    'Gaming',
    'Cooking',
    'Yoga',
    'Chess',
    'Volunteering',
    'Writing',
    'Dancing',
  ];
  @override
  State<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<InterestsStep> {
  final _resumes = Get.find<ResumeController>();
  final _name = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  int? _editing;
  ResumeModel? _editingResume;
  void _reset() {
    _name.clear();
    _form.currentState?.reset();
    setState(() {
      _editing = null;
      _editingResume = null;
    });
  }

  String _normalize(String text) => AtsScorer.normalize(text);
  String _label(String value) => InterestsStep.suggestions.contains(value)
      ? 'builder_interest_${value.toLowerCase()}'.tr
      : value;
  void _add() {
    final target = _resumes.currentResume.value;
    if (target == null || !_form.currentState!.validate()) return;
    final values = [...?target.interests];
    if (_editing != null) {
      if (!identical(target, _editingResume) || _editing! >= values.length) {
        return;
      }
      values[_editing!] = _name.text.trim();
    } else {
      values.add(_name.text.trim());
    }
    target.interests = values;
    _reset();
    _resumes.currentResume.refresh();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final target = _resumes.currentResume.value;
    final interests = target?.interests ?? <String>[];
    return ListView(
      controller: _scroll,
      key: const PageStorageKey('interests-scroll'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Form(
          key: _form,
          child: AppTextField(
            key: const ValueKey('interest-name'),
            controller: _name,
            label: 'builder_interest_name'.tr,
            autovalidateMode: AutovalidateMode.disabled,
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'builder_interest_required'.tr;
              for (var i = 0; i < interests.length; i++) {
                if (i != _editing &&
                    _normalize(interests[i]) == _normalize(name)) {
                  return 'builder_interest_duplicate'.tr;
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          key: const ValueKey('add-interest'),
          label: (_editing == null ? 'builder_add_interest' : 'save').tr,
          icon: Icons.add,
          fullWidth: true,
          onPressed: _add,
        ),
        if (_editing != null)
          AppButton(
            key: const ValueKey('cancel-interest'),
            label: 'cancel'.tr,
            variant: AppButtonVariant.text,
            fullWidth: true,
            onPressed: _reset,
          ),
        const SizedBox(height: AppSpacing.icon),
        AppSectionHeader(title: 'builder_interest_suggestions'.tr),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final suggestion in InterestsStep.suggestions)
              FilterChip(
                key: ValueKey('interest-suggestion-$suggestion'),
                label: Text(_label(suggestion)),
                selected: interests.any(
                  (entry) => _normalize(entry) == _normalize(suggestion),
                ),
                onSelected: (selected) {
                  if (target == null) return;
                  target.interests = selected
                      ? [...interests, suggestion]
                      : interests
                            .where(
                              (entry) =>
                                  _normalize(entry) != _normalize(suggestion),
                            )
                            .toList();
                  _resumes.currentResume.refresh();
                  _reset();
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.icon),
        if (interests.isEmpty)
          AppEmptyState(
            title: 'builder_no_interests'.tr,
            icon: Icons.favorite_outline,
          ),
        for (var index = 0; index < interests.length; index++)
          ResumeEntryCard(
            entryKey: 'interest-$index',
            title: _label(interests[index]),
            details: const [],
            onEdit: () {
              _name.text = interests[index];
              setState(() {
                _editing = index;
                _editingResume = target;
              });
              if (_scroll.hasClients) _scroll.jumpTo(0);
            },
            onDelete: () {
              target!.interests = [...interests]..removeAt(index);
              _resumes.currentResume.refresh();
              _reset();
            },
          ),
      ],
    );
  });
  @override
  void dispose() {
    _name.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
