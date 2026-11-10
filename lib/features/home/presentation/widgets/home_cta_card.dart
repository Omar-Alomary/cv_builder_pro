import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Soft branded CTA with localized typography and three guarded actions.
class HomeCtaCard extends StatefulWidget {
  const HomeCtaCard({
    super.key,
    required this.onCreate,
    required this.onImport,
    required this.onAts,
  });
  final Future<void> Function() onCreate, onImport, onAts;
  @override
  State<HomeCtaCard> createState() => _HomeCtaCardState();
}

class _HomeCtaCardState extends State<HomeCtaCard> {
  bool _busy = false;
  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      unawaited(HapticFeedback.lightImpact().catchError((Object _) {}));
      await action();
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'action_failed'.tr);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            Color.lerp(scheme.surface, AppColors.violet, dark ? .16 : .065)!,
            Color.lerp(scheme.surface, AppColors.info, dark ? .12 : .07)!,
          ],
        ),
        border: Border.all(
          color: scheme.primary.withValues(alpha: dark ? .18 : .07),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: dark ? .025 : .045),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightSurface.withValues(
                    alpha: dark ? .07 : .65,
                  ),
                  border: Border.all(
                    color: AppColors.lightSurface.withValues(
                      alpha: dark ? .14 : .9,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.post_add_rounded,
                  size: 23,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home_create_title'.tr,
                      style: AppTextStyles.resolve(context, AppTextStyles.h4)
                          .copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(Theme.of(context).brightness),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'home_empty_description'.tr,
                      style:
                          AppTextStyles.resolve(
                            context,
                            AppTextStyles.bodySmall,
                          ).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          IntrinsicHeight(
            child: Row(
              key: const ValueKey('home-primary-actions-row'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CtaButton(
                    buttonKey: const ValueKey('create-resume'),
                    label: 'home_start_short'.tr,
                    icon: Icons.add_rounded,
                    primary: true,
                    onPressed: _busy ? null : () => _run(widget.onCreate),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CtaButton(
                    buttonKey: const ValueKey('import-resume'),
                    label: 'home_import_short'.tr,
                    icon: Icons.upload_file_outlined,
                    onPressed: _busy ? null : () => _run(widget.onImport),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CtaButton(
                    buttonKey: const ValueKey('check-ats'),
                    label: 'home_ats_short'.tr,
                    icon: Icons.fact_check_outlined,
                    onPressed: _busy ? null : () => _run(widget.onAts),
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

class _CtaButton extends StatefulWidget {
  const _CtaButton({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });
  final Key buttonKey;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  final _states = WidgetStatesController();
  @override
  void initState() {
    super.initState();
    _states.addListener(_changed);
  }

  void _changed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = AppTextStyles.resolve(
      context,
      AppTextStyles.button,
    ).copyWith(fontSize: 12, fontWeight: FontWeight.w600);
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: AppRadii.field),
      ),
      textStyle: WidgetStatePropertyAll(labelStyle),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(
        widget.primary
            ? AppColors.transparent
            : scheme.surface.withValues(alpha: .45),
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? scheme.onSurface.withValues(alpha: .38)
            : widget.primary
            ? AppColors.lightSurface
            : scheme.primary,
      ),
      side: widget.primary
          ? null
          : WidgetStatePropertyAll(
              BorderSide(color: scheme.primary.withValues(alpha: .24)),
            ),
    );
    final label = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (MediaQuery.textScalerOf(context).scale(12) <= 18 &&
            MediaQuery.sizeOf(context).width >= 360) ...[
          Icon(widget.icon, size: 14),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: labelStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
    final button = widget.primary
        ? ElevatedButton(
            key: widget.buttonKey,
            statesController: _states,
            style: style,
            onPressed: widget.onPressed,
            child: label,
          )
        : OutlinedButton(
            key: widget.buttonKey,
            statesController: _states,
            style: style,
            onPressed: widget.onPressed,
            child: label,
          );
    return AnimatedOpacity(
      opacity: _states.value.contains(WidgetState.pressed) ? .76 : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 80),
      child: widget.primary
          ? DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppRadii.field,
              ),
              child: button,
            )
          : button,
    );
  }

  @override
  void dispose() {
    _states.removeListener(_changed);
    _states.dispose();
    super.dispose();
  }
}
