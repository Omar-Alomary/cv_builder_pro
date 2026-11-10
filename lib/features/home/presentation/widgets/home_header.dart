import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/index.dart';

/// Welcome banner with statistics overlapping its lower edge inside hit bounds.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.statistics});
  final Widget statistics;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final padding = Responsive.value<double>(
      context: context,
      mobile: AppSpacing.lg,
      tablet: AppSpacing.xl,
      desktop: AppSpacing.xxl,
    );
    return Stack(
      children: [
        Positioned.fill(
          bottom: AppSpacing.xxxl,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.xxl),
              ),
              gradient: dark
                  ? const LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: [
                        AppColors.darkTint,
                        AppColors.primaryDark,
                        AppColors.violet,
                      ],
                    )
                  : AppColors.primaryGradient,
            ),
          ),
        ),
        Responsive.maxWidth(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              padding,
              AppSpacing.xl,
              padding,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'app_name'.tr,
                            style: AppTextStyles.resolve(
                              context,
                              AppTextStyles.caption,
                            ).copyWith(color: AppColors.lightSurface),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Semantics(
                            header: true,
                            child: Text(
                              'home_welcome'.tr,
                              style: AppTextStyles.resolve(
                                context,
                                Responsive.isMobile(context)
                                    ? AppTextStyles.h2
                                    : AppTextStyles.h1,
                              ).copyWith(color: AppColors.lightSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    AppAvatar(
                      heroTag: 'cv-profile',
                      size: AppSpacing.touchTarget + AppSpacing.sm,
                      semanticsLabel: 'settings'.tr,
                      onTap: () => Get.toNamed<void>(AppRoutes.settings),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'splash_tagline'.tr,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.bodySmall,
                  ).copyWith(color: AppColors.lightSurface),
                ),
                const SizedBox(height: AppSpacing.xl),
                statistics,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
