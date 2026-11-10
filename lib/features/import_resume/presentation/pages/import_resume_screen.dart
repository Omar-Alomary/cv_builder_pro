import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/services/resume_import_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/import_option_card.dart';
import '../widgets/import_preview_widget.dart';
import '../widgets/import_loading_widget.dart';

/// Picks a file or accepts pasted JSON, previews it, and saves an isolated copy.
class ImportResumeScreen extends StatefulWidget {
  const ImportResumeScreen({super.key, this.service});
  final ResumeImportService? service;
  @override
  State<ImportResumeScreen> createState() => _ImportResumeScreenState();
}

class _ImportResumeScreenState extends State<ImportResumeScreen> {
  late final _service = widget.service ?? ResumeImportService();
  final _paste = TextEditingController();
  final _previewKey = GlobalKey();
  ResumeModel? _resume;
  bool _loading = false;
  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  void _preview(ResumeModel resume) {
    setState(() => _resume = resume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _previewKey.currentContext;
      if (mounted && context != null) {
        Scrollable.ensureVisible(context, alignment: 0);
      }
    });
  }

  Future<void> _pick(String extension) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final resume = await _service.pickAndImport(extension);
      if (resume != null && mounted) _preview(resume);
    } on ImportException catch (error) {
      if (mounted) AppSnackbar.error(context, error.messageKey.tr);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'import_read_failed'.tr);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(ResumeModel resume) async {
    // Foreign IDs and local image paths must not overwrite or access local data.
    final copy = resume.copyWith(
      id: null,
      profilePicture: null,
      createdAt: DateTime.now(),
      updatedAt: null,
      isFavorite: false,
    );
    final saved = await Get.find<ResumeController>().saveResume(copy);
    if (saved && mounted) {
      Get.offNamed<void>(AppRoutes.resumeBuilder, arguments: copy.copyWith());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(
        title: Text('import_resume'.tr),
        toolbarHeight:
            AppSpacing.touchTarget +
            AppSpacing.sm +
            math.max(0, scale - 1) * AppSpacing.xxl,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('import-scroll'),
            padding: Responsive.pagePadding(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final options = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final format in ['json', 'pdf', 'txt'])
                      ImportOptionCard(
                        key: ValueKey('import-option-$format'),
                        title: format.toUpperCase(),
                        badgeLabel: format == 'json'
                            ? 'recommended'.tr
                            : format == 'pdf'
                            ? 'ats_severity_warning'.tr
                            : null,
                        recommended: format == 'json',
                        warning: format == 'pdf',
                        description: 'import_${format}_description'.tr,
                        icon: format == 'pdf'
                            ? Icons.picture_as_pdf_outlined
                            : format == 'json'
                            ? Icons.data_object
                            : Icons.text_snippet_outlined,
                        actionLabel: 'import_select_file'.trParams({
                          'format': format.toUpperCase(),
                        }),
                        onSelect: _loading ? null : () => _pick(format),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      key: const ValueKey('paste-resume-json'),
                      controller: _paste,
                      label: 'import_paste_json'.tr,
                      maxLines: 7,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.multiline,
                      enabled: !_loading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      key: const ValueKey('parse-pasted-json'),
                      label: 'import_preview'.tr,
                      icon: Icons.manage_search_outlined,
                      fullWidth: true,
                      onPressed: _loading
                          ? null
                          : () {
                              try {
                                _preview(_service.fromJsonText(_paste.text));
                              } on ImportException catch (error) {
                                AppSnackbar.error(context, error.messageKey.tr);
                              }
                            },
                    ),
                  ],
                );
                final preview = Column(
                  key: _previewKey,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loading) const ImportLoadingWidget(),
                    if (_resume != null)
                      ImportPreviewWidget(
                        key: ObjectKey(_resume),
                        resume: _resume!,
                        onSave: _save,
                        onDiscard: () => setState(() => _resume = null),
                      )
                    else if (!_loading)
                      AppEmptyState(
                        title: 'import_preview_empty'.tr,
                        description: 'import_preview_empty_description'.tr,
                        icon: Icons.upload_file,
                      ),
                  ],
                );
                if (Responsive.isTabletOrLarger(context)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: options),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(child: preview),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    options,
                    const SizedBox(height: AppSpacing.xl),
                    preview,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
