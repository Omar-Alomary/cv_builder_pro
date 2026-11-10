import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/services/resume_export_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';

/// Reusable editor and preview export action using an independent draft copy.
class ResumeJsonExportButton extends StatefulWidget {
  const ResumeJsonExportButton({super.key, required this.resume, this.service});
  final ResumeModel? Function() resume;
  final ResumeExportService? service;
  @override
  State<ResumeJsonExportButton> createState() => _ResumeJsonExportButtonState();
}

class _ResumeJsonExportButtonState extends State<ResumeJsonExportButton> {
  bool _open = false;
  Future<void> _show() async {
    if (_open) return;
    setState(() => _open = true);
    try {
      final resume = widget.resume()?.copyWith();
      if (resume == null) {
        AppSnackbar.warning(context, 'export_no_resume'.tr);
        return;
      }
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ExportDialog(
          resume: resume,
          service: widget.service ?? ResumeExportService(),
        ),
      );
      if (!mounted) return;
      if (result == 'saved') {
        AppSnackbar.success(context, 'export_json_saved'.tr);
      }
      if (result == 'shared') {
        AppSnackbar.info(context, 'export_json_shared'.tr);
      }
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'export_json_invalid'.tr);
    } finally {
      if (mounted) setState(() => _open = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'export_json'.tr,
    onPressed: _open ? null : _show,
    icon: const Icon(Icons.data_object),
  );
}

class _ExportDialog extends StatefulWidget {
  const _ExportDialog({required this.resume, required this.service});
  final ResumeModel resume;
  final ResumeExportService service;
  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  bool _working = false;
  String? _error;
  Future<void> _run({required bool share, BuildContext? anchor}) async {
    if (_working) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      String? result;
      if (share) {
        final box = anchor!.findRenderObject() as RenderBox;
        final shared = await widget.service.shareJson(
          widget.resume,
          origin: box.localToGlobal(Offset.zero) & box.size,
        );
        if (shared.status != ShareResultStatus.dismissed) result = 'shared';
      } else {
        final saved = await widget.service.saveJson(widget.resume);
        if (saved != null) result = 'saved';
      }
      if (result != null && mounted) Navigator.of(context).pop(result);
    } on ExportException catch (error) {
      if (mounted) setState(() => _error = error.messageKey);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = share
              ? 'export_json_share_failed'
              : 'export_json_save_failed',
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_working,
    child: Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.value<double>(
            context: context,
            mobile: 500,
            tablet: 600,
            desktop: 650,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSectionHeader(
                title: 'export_json'.tr,
                subtitle: 'export_json_description'.tr,
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _error!.tr,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                key: const ValueKey('save-resume-json'),
                label: 'export_json_save'.tr,
                fullWidth: true,
                icon: Icons.save_alt,
                onPressed: _working ? null : () => _run(share: false),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (anchor) => AppButton(
                  key: const ValueKey('share-resume-json'),
                  label: 'export_json_share'.tr,
                  fullWidth: true,
                  icon: Icons.share_outlined,
                  variant: AppButtonVariant.outlined,
                  onPressed: _working
                      ? null
                      : () => _run(share: true, anchor: anchor),
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'cancel'.tr,
                fullWidth: true,
                variant: AppButtonVariant.text,
                onPressed: _working ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
