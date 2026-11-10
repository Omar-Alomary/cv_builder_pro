import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/theme/index.dart';
import 'app_hero.dart';

/// Ring avatar with a readable initial, image-error fallback and camera action.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.name,
    this.image,
    this.size = AppSpacing.avatar,
    this.onTap,
    this.onCameraPressed,
    this.semanticsLabel,
    this.heroTag,
  }) : assert(size > 0);
  final String? name, semanticsLabel;
  final Object? heroTag;
  final ImageProvider<Object>? image;
  final double size;
  final VoidCallback? onTap, onCameraPressed;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = name?.trim() ?? '';
    final fallback = text.isEmpty
        ? null
        : String.fromCharCode(text.runes.first).toUpperCase();
    Widget initial() => ColoredBox(
      color: scheme.primaryContainer,
      child: Center(
        child: fallback == null
            ? Icon(Icons.person_outline, color: scheme.primary, size: size * .4)
            : Text(
                fallback,
                textScaler: TextScaler.noScaling,
                style: AppTextStyles.h3.copyWith(
                  fontSize: size * .36,
                  color: scheme.primary,
                ),
              ),
      ),
    );
    final dimension = math.max(
      size,
      onTap != null || onCameraPressed != null
          ? AppSpacing.touchTarget
          : AppSpacing.none,
    );
    final avatar = SizedBox.square(
      dimension: dimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Semantics(
            label: semanticsLabel ?? (text.isEmpty ? 'personal_info'.tr : text),
            image: true,
            button: onTap != null,
            child: Container(
              width: size,
              height: size,
              padding: const EdgeInsets.all(AppSpacing.focusStroke),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Material(
                color: scheme.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: ClipOval(
                      child: ExcludeSemantics(
                        child: image == null
                            ? initial()
                            : Image(
                                image: image!,
                                width: size,
                                height: size,
                                fit: BoxFit.cover,
                                errorBuilder: (_, error, stackTrace) =>
                                    initial(),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (onCameraPressed != null)
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: IconButton(
                tooltip: 'change_profile_image'.tr,
                alignment: AlignmentDirectional.bottomEnd,
                padding: EdgeInsets.zero,
                onPressed: onCameraPressed,
                icon: Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.lightSurface,
                    size: AppSpacing.icon,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return heroTag == null ? avatar : AppHero(tag: heroTag!, child: avatar);
  }
}
