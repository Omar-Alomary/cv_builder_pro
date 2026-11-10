import '../../../../app/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';
import '../templates/pdf_template_options.dart';

/// Scrollable customization controls editing a draft instead of persisted data.
class CustomizationPanel extends StatelessWidget {
  const CustomizationPanel({
    super.key,
    required this.options,
    required this.onChanged,
    required this.onSave,
    required this.onReset,
    required this.onPreview,
    this.enabled = true,
    this.dirty = false,
    this.scrollable = true,
  });
  final PdfTemplateOptions options;
  final ValueChanged<PdfTemplateOptions> onChanged;
  final Future<void> Function() onSave;
  final VoidCallback onReset;
  final Future<void> Function() onPreview;
  final bool enabled;
  final bool dirty;
  final bool scrollable;
  Future<void> _choose(BuildContext context, bool primary) async {
    var color = Color(primary ? options.primaryColor : options.secondaryColor);
    final result = await showDialog<Color>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text((primary ? 'primary_color' : 'secondary_color').tr),
                ColorPicker(
                  pickerColor: color,
                  onColorChanged: (value) => color = value,
                  enableAlpha: false,
                  colorPickerWidth:
                      MediaQuery.sizeOf(context).width.clamp(240, 400) - 64,
                ),
                AppButton(
                  label: 'save'.tr,
                  onPressed: () => Navigator.of(context).pop(color),
                ),
                AppButton(
                  label: 'cancel'.tr,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && context.mounted) {
      onChanged(
        primary
            ? options.copyWith(primaryColor: result.toARGB32())
            : options.copyWith(secondaryColor: result.toARGB32()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(title: 'customize_resume'.tr),
          const SizedBox(height: AppSpacing.lg),
          for (final primary in [true, false]) ...[
            Text((primary ? 'primary_color' : 'secondary_color').tr),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in [
                  0xff1565c0,
                  0xff00695c,
                  0xff6a1b9a,
                  0xff212121,
                ])
                  IconButton(
                    key: ValueKey(
                      'color-${primary ? 'primary' : 'secondary'}-$color',
                    ),
                    tooltip:
                        '${(primary ? 'primary_color' : 'secondary_color').tr} #${color.toRadixString(16).substring(2)}',
                    isSelected:
                        color ==
                        (primary
                            ? options.primaryColor
                            : options.secondaryColor),
                    icon: Icon(Icons.circle, color: Color(color)),
                    selectedIcon: Icon(Icons.check_circle, color: Color(color)),
                    onPressed: enabled
                        ? () => onChanged(
                            primary
                                ? options.copyWith(primaryColor: color)
                                : options.copyWith(secondaryColor: color),
                          )
                        : null,
                  ),
              ],
            ),
            AppButton(
              key: ValueKey(
                'custom-color-${primary ? 'primary' : 'secondary'}',
              ),
              label: 'pdf_custom_color'.tr,
              variant: AppButtonVariant.outlined,
              onPressed: enabled ? () => _choose(context, primary) : null,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text('font_family'.tr),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final family in ['Cairo', 'Sukar', 'Poppins'])
                ChoiceChip(
                  key: ValueKey('font-$family'),
                  label: Text(family),
                  selected: options.fontFamily == family,
                  onSelected: enabled
                      ? (_) => onChanged(options.copyWith(fontFamily: family))
                      : null,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('pdf_arabic_font_note'.tr),
          const SizedBox(height: AppSpacing.lg),
          Text('${'font_size'.tr}: ${options.fontSize.toStringAsFixed(0)}'),
          Slider(
            key: const ValueKey('preview-font-size'),
            value: options.fontSize.clamp(8, 16),
            min: 8,
            max: 16,
            divisions: 8,
            label: options.fontSize.toStringAsFixed(0),
            onChanged: enabled
                ? (value) => onChanged(options.copyWith(fontSize: value))
                : null,
          ),
          if (dirty) Text('pdf_unsaved_changes'.tr),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            key: const ValueKey('update-pdf-preview'),
            label: 'update_preview'.tr,
            icon: Icons.refresh,
            fullWidth: true,
            onPressed: enabled ? onPreview : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            key: const ValueKey('save-customization'),
            label: 'save'.tr,
            icon: Icons.save_outlined,
            fullWidth: true,
            onPressed: enabled && dirty ? onSave : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            key: const ValueKey('reset-customization'),
            label: 'pdf_revert_changes'.tr,
            fullWidth: true,
            variant: AppButtonVariant.secondary,
            onPressed: enabled && dirty ? onReset : null,
          ),
        ],
      ),
    );
    return scrollable
        ? SingleChildScrollView(
            key: const ValueKey('customization-scroll'),
            child: content,
          )
        : content;
  }
}
