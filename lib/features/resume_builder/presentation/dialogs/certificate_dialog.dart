import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../data/models/certificate.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/resume_form_dialog.dart';

/// Edits every certificate field in isolation until the user saves.
class CertificateDialog extends StatefulWidget {
  const CertificateDialog({super.key, this.certificate});
  final Certificate? certificate;
  @override
  State<CertificateDialog> createState() => _CertificateDialogState();
}

class _CertificateDialogState extends State<CertificateDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.certificate?.name ?? '',
  );
  late final _organization = TextEditingController(
    text: widget.certificate?.organization ?? '',
  );
  late final _year = TextEditingController(
    text: widget.certificate?.year ?? '',
  );
  late final _credentialId = TextEditingController(
    text: widget.certificate?.credentialId ?? '',
  );
  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      Certificate(
        name: _name.text.trim(),
        organization: _organization.text.trim(),
        year: DateFormatter.normalizeDigits(_year.text.trim()),
        credentialId: (_credentialId.text.trim().isEmpty
            ? null
            : _credentialId.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ResumeFormDialog(
    icon: Icons.verified_outlined,
    title: (widget.certificate == null ? 'add_certificate' : 'edit_certificate')
        .tr,
    onSave: _save,
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            key: const ValueKey('certificate-name'),
            controller: _name,
            label: 'certificate_name'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'certificate_name'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('certificate-organization'),
            controller: _organization,
            label: 'organization'.tr,
            validator: (value) =>
                Validators.validateRequired(value, 'organization'.tr),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('certificate-year'),
            controller: _year,
            label: 'year'.tr,
            validator: Validators.validateYear,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            hint: 'YYYY',
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            key: const ValueKey('certificate-credentialId'),
            controller: _credentialId,
            label: 'builder_credential_id'.tr,
            validator: null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    for (final control in [_name, _organization, _year, _credentialId]) {
      control.dispose();
    }
    super.dispose();
  }
}
