import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared_widgets/index.dart';

/// Slim neutral profile header with a framed photo and localized type scale.
class SettingsProfileHeader extends StatefulWidget {
  const SettingsProfileHeader({
    super.key,
    this.imagePath,
    required this.onPick,
  });
  final String? imagePath;
  final Future<void> Function() onPick;
  @override
  State<SettingsProfileHeader> createState() => _SettingsProfileHeaderState();
}

class _SettingsProfileHeaderState extends State<SettingsProfileHeader> {
  bool _picking = false;
  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      await widget.onPick();
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'profile_image_failed'.tr);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            scheme.surface,
            Color.lerp(scheme.surface, AppColors.border(brightness), .22)!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightSurface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ProfileAvatar(
              imagePath: widget.imagePath,
              size: 72,
              onTap: _picking ? null : _pick,
              label: 'change_profile_image'.tr,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.resolve(context, AppTextStyles.h4)
                      .copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text(brightness),
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'professional_resume_builder'.tr,
                  style: AppTextStyles.resolve(context, AppTextStyles.caption)
                      .copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary(brightness),
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                OutlinedButton(
                  key: const ValueKey('pick-profile-image'),
                  onPressed: _pick,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    side: BorderSide(
                      color: scheme.primary.withValues(alpha: .3),
                    ),
                    textStyle: AppTextStyles.resolve(
                      context,
                      AppTextStyles.button,
                    ).copyWith(fontSize: 12),
                  ),
                  child: _picking
                      ? const SizedBox.square(
                          dimension: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt_outlined, size: 14),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'change_photo_short'.tr,
                                style: AppTextStyles.resolve(
                                  context,
                                  AppTextStyles.button,
                                ).copyWith(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
