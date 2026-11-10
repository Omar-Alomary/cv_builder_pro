import '../../../../app/theme/index.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../templates/pdf_template_options.dart';
import '../widgets/customization_panel.dart';
import '../widgets/pdf_preview_view.dart';
import '../widgets/resume_json_export_button.dart';

/// Responsive PDF workspace with isolated appearance drafts and guarded exports.
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, this.exportService, this.previewBuilder});
  final PdfExportService? exportService;
  final Widget Function(Uint8List)? previewBuilder;
  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _resumes = Get.find<ResumeController>();
  late final _export = widget.exportService ?? PdfExportService();
  late PdfTemplateOptions _options;
  late PdfTemplateOptions _baseline;
  PdfExportQuality _quality = PdfExportQuality.standard;
  Uint8List? _bytes;
  ResumeModel? _rendered;
  bool _generating = false;
  bool _working = false;
  bool _showCustomization = false;
  bool _allowPop = false;
  bool _leaving = false;
  int _generation = 0;
  String? _error;
  bool get _ats =>
      AppConstants.templateType(
        _resumes.currentResume.value?.templateId ?? '',
      ) ==
      'ats';
  bool get _dirty => !_ats && _options != _baseline;
  @override
  void initState() {
    super.initState();
    _loadOptions();
    unawaited(_refresh());
  }

  void _loadOptions() {
    _options = PdfTemplateOptions.fromJson(
      _resumes.currentResume.value?.customization,
    );
    _baseline = _options;
  }

  ResumeModel? _snapshot() {
    final resume = _resumes.currentResume.value;
    if (resume == null || resume.fullName.trim().isEmpty) return null;
    return _ats
        ? resume.copyWith()
        : resume.copyWith(
            customization: {...?resume.customization, ..._options.toJson()},
          );
  }

  Future<void> _refresh() async {
    final snapshot = _snapshot();
    final generation = ++_generation;
    if (snapshot == null) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final bytes = await _export.generate(
        snapshot,
        locale: Get.locale?.languageCode ?? 'en',
        quality: _quality,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _bytes = bytes;
        _rendered = snapshot;
      });
    } catch (error) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _bytes = null;
        _error = error is PdfExportException
            ? error.messageKey
            : 'pdf_generation_failed';
      });
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _generating = false);
      }
    }
  }

  Future<void> _save() async {
    if (_working || !_dirty) return;
    final original = _resumes.currentResume.value;
    final candidate = _snapshot();
    if (candidate == null) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      if (!await _resumes.saveResume(candidate)) {
        if (mounted) setState(() => _error = 'pdf_customization_save_failed');
        return;
      }
      if (!mounted || !identical(original, _resumes.currentResume.value)) {
        return;
      }
      _resumes.currentResume.value = candidate;
      _resumes.isEditing.value = candidate.id != null;
      setState(() => _baseline = _options);
      AppSnackbar.success(context, 'customization_saved'.tr);
      await _refresh();
    } catch (_) {
      if (mounted) setState(() => _error = 'pdf_customization_save_failed');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _reset() {
    setState(() {
      _options = _baseline;
      _error = null;
    });
    unawaited(_refresh());
  }

  Future<void> _leave() async {
    if (_working || _leaving || !Navigator.of(context).canPop()) return;
    _leaving = true;
    try {
      if (_dirty) {
        final choice = await showDialog<String>(
          context: context,
          builder: (context) => Dialog(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.icon),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('pdf_leave_changes'.tr),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      key: const ValueKey('preview-leave-save'),
                      label: 'save'.tr,
                      onPressed: () => Navigator.of(context).pop('save'),
                    ),
                    AppButton(
                      key: const ValueKey('preview-leave-discard'),
                      label: 'pdf_discard_changes'.tr,
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop('discard'),
                    ),
                    AppButton(
                      label: 'cancel'.tr,
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        if (!mounted || choice == null) return;
        if (choice == 'save') {
          await _save();
          if (!mounted || _dirty) return;
        }
      }
      if (!mounted) return;
      setState(() => _allowPop = true);
      await Future<void>.delayed(Duration.zero);
      if (mounted) Navigator.of(context).pop();
    } finally {
      _leaving = false;
    }
  }

  Future<void> _atsCheck() async {
    final previous = _resumes.currentResume.value?.templateId;
    await Get.toNamed<void>(AppRoutes.atsChecker);
    if (!mounted) return;
    if (previous != _resumes.currentResume.value?.templateId) {
      setState(_loadOptions);
    }
    await _refresh();
  }

  Future<void> _output(String action, BuildContext anchor) async {
    if (_working || _generating) return;
    final snapshot = _snapshot();
    if (snapshot == null) return;
    final box = anchor.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final bytes = await _export.generate(
        snapshot,
        locale: Get.locale?.languageCode ?? 'en',
        quality: _quality,
      );
      if (!mounted) return;
      final name = _export.fileName(snapshot.fullName);
      String? message;
      if (action == 'save') {
        if (await _export.savePdf(bytes, name: name) != null) {
          message = 'pdf_saved';
        }
      } else if (action == 'print') {
        if (await _export.printPdf(bytes, name: name)) {
          message = 'pdf_print_submitted';
        }
      } else {
        final result = await _export.sharePdf(
          bytes,
          name: name,
          origin: origin,
        );
        if (result.status != ShareResultStatus.dismissed) {
          message = 'pdf_share_opened';
        }
      }
      if (mounted && message != null) AppSnackbar.info(context, message.tr);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PdfExportException
              ? error.messageKey
              : 'pdf_export_failed',
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Widget _previewFrame() => Padding(
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: _preview(),
      ),
    ),
  );
  Widget _preview() {
    if (_generating) return AppLoading(message: 'pdf_preview_loading'.tr);
    if (_bytes == null) {
      return AppEmptyState(
        title: (_error ?? 'failed_to_generate_preview').tr,
        actionLabel: 'retry'.tr,
        onAction: () {
          unawaited(_refresh());
        },
      );
    }
    return widget.previewBuilder?.call(_bytes!) ??
        PdfPreviewView(
          bytes: _bytes!,
          onRetry: () {
            unawaited(_refresh());
          },
        );
  }

  Widget _panel({bool scrollable = true}) => AppCard(
    padding: EdgeInsets.zero,
    child: CustomizationPanel(
      options: _options,
      enabled: !_working,
      dirty: _dirty,
      scrollable: scrollable,
      onChanged: (value) => setState(() => _options = value),
      onSave: _save,
      onReset: _reset,
      onPreview: _refresh,
    ),
  );
  @override
  Widget build(BuildContext context) {
    final resume = _resumes.currentResume.value;
    final missing = resume == null || resume.fullName.trim().isEmpty;
    return PopScope(
      canPop: _allowPop || (!_dirty && !_working),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('preview'.tr),
          leading: BackButton(onPressed: _leave),
          actions: [
            if (!missing && !_ats && Responsive.isMobile(context))
              IconButton(
                key: const ValueKey('toggle-customization'),
                tooltip: 'customize_resume'.tr,
                icon: const Icon(Icons.tune),
                onPressed: _working
                    ? null
                    : () => setState(
                        () => _showCustomization = !_showCustomization,
                      ),
              ),
          ],
        ),
        body: SafeArea(
          child: Responsive.maxWidth(
            child: missing
                ? AppEmptyState(
                    title:
                        (resume == null
                                ? 'export_no_resume'
                                : 'resume_is_empty')
                            .tr,
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final actions = Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppButton(
                              key: const ValueKey('preview-check-ats'),
                              label: 'ats_checker'.tr,
                              icon: Icons.fact_check_outlined,
                              onPressed: _working ? null : _atsCheck,
                            ),
                            ResumeJsonExportButton(
                              key: const ValueKey('preview-export-json'),
                              resume: _snapshot,
                            ),
                            for (final action in ['save', 'print', 'share'])
                              Builder(
                                builder: (anchor) => AppButton(
                                  key: ValueKey('preview-$action-pdf'),
                                  label:
                                      (action == 'save'
                                              ? 'export_pdf'
                                              : action == 'print'
                                              ? 'print_pdf'
                                              : 'share_pdf')
                                          .tr,
                                  icon: action == 'save'
                                      ? Icons.download_outlined
                                      : action == 'print'
                                      ? Icons.print_outlined
                                      : Icons.share_outlined,
                                  onPressed: _working || _generating
                                      ? null
                                      : () => _output(action, anchor),
                                ),
                              ),
                          ],
                        ),
                      );
                      final controls = Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: AppCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              actions,
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    Text('pdf_quality'.tr),
                                    for (final quality
                                        in PdfExportQuality.values)
                                      ChoiceChip(
                                        key: ValueKey(
                                          'pdf-quality-${quality.name}',
                                        ),
                                        label: Text(
                                          'pdf_quality_${quality.name}'.tr,
                                        ),
                                        selected: _quality == quality,
                                        onSelected: _working
                                            ? null
                                            : (_) {
                                                setState(
                                                  () => _quality = quality,
                                                );
                                                unawaited(_refresh());
                                              },
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Text(
                                  (_ats
                                          ? 'pdf_ats_fixed_note'
                                          : 'pdf_quality_note')
                                      .tr,
                                ),
                              ),
                              if (_rendered != null &&
                                  _rendered != _snapshot() &&
                                  !_generating)
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Text('pdf_preview_outdated'.tr),
                                ),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      _error!.tr,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (Responsive.isTabletOrLarger(context)) {
                        return Row(
                          key: const ValueKey('preview-side-by-side'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              width: math.min(360, constraints.maxWidth * .44),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: controls,
                                    ),
                                  ),
                                  if (!_ats) Expanded(child: _panel()),
                                ],
                              ),
                            ),
                            Expanded(child: _previewFrame()),
                          ],
                        );
                      }
                      return SingleChildScrollView(
                        key: const ValueKey('preview-mobile-scroll'),
                        child: Column(
                          children: [
                            SizedBox(
                              height: math.max(
                                360,
                                math.min(
                                  constraints.maxHeight * .8,
                                  (constraints.maxWidth - 32) * 1.414 + 48,
                                ),
                              ),
                              child: _previewFrame(),
                            ),
                            controls,
                            if (_showCustomization && !_ats)
                              _panel(scrollable: false),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }
}
