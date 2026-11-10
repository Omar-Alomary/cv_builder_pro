import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Resume tips retaining all messages with a static reduced-motion alternative.
class MarqueeHeader extends StatelessWidget {
  const MarqueeHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final tips = [
      'tip_action_verbs'.tr,
      'tip_tailor_resume'.tr,
      'tip_resume_length'.tr,
      'tip_relevant_skills'.tr,
      'tip_job_keywords'.tr,
    ];
    final text = tips.join('   •   ');
    final scheme = Theme.of(context).colorScheme;
    final style = AppTextStyles.resolve(
      context,
      AppTextStyles.bodySmall,
    ).copyWith(color: scheme.onSurfaceVariant);
    final staticTips =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context) ||
        MediaQuery.textScalerOf(
              context,
            ).scale(AppTextStyles.bodySmall.fontSize!) >
            AppTextStyles.h4.fontSize!;
    return AppCard(
      child: staticTips
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: scheme.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(tips.join('\n'), style: style),
              ],
            )
          : Semantics(
              label: text,
              excludeSemantics: true,
              child: SizedBox(
                height:
                    MediaQuery.textScalerOf(
                      context,
                    ).scale(AppTextStyles.bodySmall.fontSize!) +
                    AppSpacing.xl,
                child: Marquee(
                  text: text,
                  style: style,
                  velocity: 35,
                  blankSpace: AppSpacing.xxxl,
                  pauseAfterRound: const Duration(seconds: 2),
                  textDirection: Directionality.of(context),
                ),
              ),
            ),
    );
  }
}
