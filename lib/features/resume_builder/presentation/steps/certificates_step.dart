import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/certificate.dart';
import '../../../../shared_widgets/index.dart';
import '../dialogs/certificate_dialog.dart';
import '../widgets/resume_entry_card.dart';
import '../widgets/resume_reorderable_list.dart';
import '../../../../app/theme/index.dart';

/// Certificate list supporting isolated dialog edits and reactive CRUD updates.
class CertificatesStep extends StatefulWidget {
  const CertificatesStep({super.key});
  @override
  State<CertificatesStep> createState() => _CertificatesStepState();
}

class _CertificatesStepState extends State<CertificatesStep> {
  final _resumes = Get.find<ResumeController>();
  bool _dialogOpen = false;
  Future<void> _edit([int? index]) async {
    if (_dialogOpen) return;
    final target = _resumes.currentResume.value;
    if (target == null ||
        (index != null && index >= target.certificates.length)) {
      return;
    }
    _dialogOpen = true;
    try {
      final result = await showDialog<Certificate>(
        context: context,
        builder: (_) => CertificateDialog(
          certificate: index == null ? null : target.certificates[index],
        ),
      );
      if (result == null ||
          !mounted ||
          !identical(target, _resumes.currentResume.value)) {
        return;
      }
      if (index == null) {
        target.certificates.add(result);
      } else if (index < target.certificates.length) {
        target.certificates[index] = result;
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
    final entries = target?.certificates ?? <Certificate>[];
    return ResumeReorderableList(
      key: const PageStorageKey('certificates-scroll'),

      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            key: const ValueKey('add-certificates'),
            label: 'add_certificate'.tr,
            icon: Icons.verified_outlined,
            fullWidth: true,
            onPressed: _edit,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (entries.isEmpty)
            AppEmptyState(
              title: 'no_certificates_added'.tr,
              icon: Icons.verified_outlined,
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
            entryKey: 'certificate-$index',
            title: entries[index].name,
            details: [
              entries[index].organization,
              entries[index].year,
              entries[index].credentialId ?? '',
            ],
            onEdit: () {
              _edit(index);
            },
            onDelete: () {
              target!.certificates.removeAt(index);
              _resumes.currentResume.refresh();
            },
          ),
      ],
    );
  });
}
