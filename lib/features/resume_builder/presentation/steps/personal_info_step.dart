import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/index.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared_widgets/index.dart';

/// Responsive personal information form preserving hidden template fields.
class PersonalInfoStep extends StatefulWidget {
  const PersonalInfoStep({super.key, this.imageService});
  final SettingsService? imageService;
  @override
  State<PersonalInfoStep> createState() => PersonalInfoStepState();
}

/// Form state exposing validation to the editor's navigation controls.
class PersonalInfoStepState extends State<PersonalInfoStep> {
  final _form = GlobalKey<FormState>();
  bool _picking = false;
  final _resumes = Get.find<ResumeController>();
  final _controls = <String, TextEditingController>{};
  @override
  void initState() {
    super.initState();
    final json = _resumes.currentResume.value?.toJson() ?? <String, dynamic>{};
    for (final field in [
      'fullName',
      'email',
      'phone',
      'address',
      'summary',
      'linkedin',
      'github',
      'website',
      'portfolio',
    ]) {
      _controls[field] = TextEditingController(
        text: json[field] as String? ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant PersonalInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    final json = _resumes.currentResume.value?.toJson() ?? <String, dynamic>{};
    for (final entry in _controls.entries) {
      final value = json[entry.key] as String? ?? '';
      if (entry.value.text != value) entry.value.text = value;
    }
  }

  bool validate() => _form.currentState?.validate() ?? false;
  void _update(String field, String value) {
    final resume = _resumes.currentResume.value;
    if (resume == null) return;
    final nullable = value.isEmpty ? null : value;
    switch (field) {
      case 'fullName':
        resume.fullName = value;
      case 'email':
        resume.email = value;
      case 'phone':
        resume.phone = value;
      case 'address':
        resume.address = nullable;
      case 'summary':
        resume.summary = nullable;
      case 'linkedin':
        resume.linkedin = nullable;
      case 'github':
        resume.github = nullable;
      case 'website':
        resume.website = nullable;
      case 'portfolio':
        resume.portfolio = nullable;
    }
    _resumes.currentResume.refresh();
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    final resume = _resumes.currentResume.value;
    if (resume == null) return;
    setState(() => _picking = true);
    try {
      final path = await (widget.imageService ?? SettingsService())
          .pickProfileImage();
      if (path == null ||
          !mounted ||
          !identical(resume, _resumes.currentResume.value)) {
        return;
      }
      resume.profilePicture = path;
      _resumes.currentResume.refresh();
      setState(() {});
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'profile_image_failed'.tr);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Widget _field(
    String field,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool ltr = false,
    int lines = 1,
  }) => AppTextField(
    key: ValueKey('personal-$field'),
    controller: _controls[field],
    label: label.tr,
    prefixIcon: Icon(switch (field) {
      'fullName' => Icons.person_outline,
      'email' => Icons.alternate_email,
      'phone' => Icons.phone_outlined,
      'address' => Icons.location_on_outlined,
      'summary' => Icons.notes_outlined,
      _ => Icons.link,
    }),
    validator: validator,
    keyboardType: keyboard,
    textDirection: ltr ? TextDirection.ltr : null,
    maxLines: lines,
    onChanged: (value) => _update(field, value),
  );
  Widget _pair(Widget first, Widget? second) {
    if (second == null) return first;
    if (Responsive.isTabletOrLarger(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: AppSpacing.lg),
          Expanded(child: second),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        first,
        const SizedBox(height: AppSpacing.lg),
        second,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resume = _resumes.currentResume.value;
    if (resume == null) return AppEmptyState(title: 'resume_is_empty'.tr);
    final fields = Get.find<TemplateController>().getFieldsForTemplate(
      resume.templateId,
    );
    return SingleChildScrollView(
      key: const PageStorageKey('personal-scroll'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (fields.showProfilePicture) ...[
              Center(
                child: AppAvatar(
                  heroTag: resume.id == null ? null : 'cv-resume-${resume.id}',
                  name: resume.fullName,
                  size: AppSpacing.avatar + AppSpacing.xl,
                  image: resume.profilePicture?.isNotEmpty == true
                      ? FileImage(File(resume.profilePicture!))
                      : null,
                  onCameraPressed: _picking ? null : _pickImage,
                  semanticsLabel: 'change_profile_image'.tr,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                key: const ValueKey('personal-pick-image'),
                label: 'change_profile_image'.tr,
                icon: Icons.camera_alt_outlined,
                onPressed: _pickImage,
                isLoading: _picking,
                fullWidth: true,
              ),
              if (resume.profilePicture != null)
                AppButton(
                  label: 'builder_remove_photo'.tr,
                  variant: AppButtonVariant.text,
                  onPressed: () {
                    resume.profilePicture = null;
                    _resumes.currentResume.refresh();
                    setState(() {});
                  },
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
            _pair(
              _field(
                'fullName',
                'full_name',
                validator: (value) =>
                    Validators.validateRequired(value, 'full_name'.tr),
              ),
              _field(
                'email',
                'email',
                validator: Validators.validateEmail,
                keyboard: TextInputType.emailAddress,
                ltr: true,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _pair(
              _field(
                'phone',
                'phone',
                validator: Validators.validatePhone,
                keyboard: TextInputType.phone,
                ltr: true,
              ),
              fields.showAddress ? _field('address', 'address') : null,
            ),
            for (final entry in {
              'linkedin': fields.showLinkedin,
              'github': fields.showGithub,
              'website': fields.showWebsite,
              'portfolio': fields.showPortfolio,
            }.entries)
              if (entry.value) ...[
                const SizedBox(height: AppSpacing.lg),
                _field(
                  entry.key,
                  entry.key,
                  validator: Validators.validateUrl,
                  keyboard: TextInputType.url,
                  ltr: true,
                ),
              ],
            if (fields.showSummary) ...[
              const SizedBox(height: AppSpacing.lg),
              _field(
                'summary',
                'summary',
                lines: 5,
                keyboard: TextInputType.multiline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final control in _controls.values) {
      control.dispose();
    }
    super.dispose();
  }
}
