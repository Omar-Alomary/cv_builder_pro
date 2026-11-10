import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/template_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../templates/presentation/widgets/template_mini_preview.dart';

/// Quiet, manually scrolled document previews with a compact action footer.
class TemplateCarousel extends StatefulWidget {
  const TemplateCarousel({super.key});
  @override
  State<TemplateCarousel> createState() => _TemplateCarouselState();
}

class _TemplateCarouselState extends State<TemplateCarousel> {
  final _controller = carousel.CarouselSliderController();
  int _index = 0;
  @override
  Widget build(BuildContext context) => Obx(() {
    final templates = Get.find<TemplateController>().getFeaturedTemplates();
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    if (templates.isEmpty) return Text('no_templates_available'.tr);
    return Column(
      children: [
        carousel.CarouselSlider(
          carouselController: _controller,
          options: carousel.CarouselOptions(
            height: 180 + (scale > 1 ? scale - 1 : 0) * 140,
            viewportFraction: Responsive.value(
              context: context,
              mobile: .85,
              tablet: .5,
              desktop: .35,
            ),
            autoPlay: false,
            onPageChanged: (index, reason) => setState(() => _index = index),
            enableInfiniteScroll: false,
            padEnds: false,
            enlargeCenterPage: false,
          ),
          items: templates.map((template) {
            Future<void> use() async {
              await Get.toNamed<void>(
                AppRoutes.resumeBuilder,
                arguments: template.id,
              );
            }

            final scheme = Theme.of(context).colorScheme;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.md),
              child: Material(
                color: scheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.card,
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      flex: 60,
                      child: InkWell(
                        onTap: () =>
                            TemplateMiniPreview.show(context, template, use),
                        child: SizedBox.expand(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: TemplateMiniPreview(
                              templateId: template.id,
                              previewImage: template.previewImage,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template.localizedName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.resolve(
                                      context,
                                      AppTextStyles.caption,
                                    ),
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: scheme.primaryContainer,
                                      borderRadius: AppRadii.chip,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: Text(
                                        template.type == 'ats'
                                            ? 'ATS'
                                            : 'template_category_${template.type}'
                                                  .tr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            AppTextStyles.resolve(
                                              context,
                                              AppTextStyles.caption,
                                            ).copyWith(
                                              color: scheme.onPrimaryContainer,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: TextButton(
                                key: ValueKey('use-template-${template.id}'),
                                onPressed: use,
                                child: Text(
                                  'use_template'.tr,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.resolve(
                                    context,
                                    AppTextStyles.caption,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              tooltip: 'previous'.tr,
              onPressed: _index == 0
                  ? null
                  : () {
                      if (MediaQuery.disableAnimationsOf(context)) {
                        _controller.jumpToPage(_index - 1);
                      } else {
                        _controller.previousPage(
                          duration: AppTheme.motionDuration,
                        );
                      }
                    },
              icon: const BackButtonIcon(),
            ),
            Text(
              'template_position'.trParams({
                'current': '${_index + 1}',
                'total': '${templates.length}',
              }),
              style: AppTextStyles.resolve(context, AppTextStyles.caption),
            ),
            IconButton(
              tooltip: 'next'.tr,
              onPressed: _index >= templates.length - 1
                  ? null
                  : () {
                      if (MediaQuery.disableAnimationsOf(context)) {
                        _controller.jumpToPage(_index + 1);
                      } else {
                        _controller.nextPage(duration: AppTheme.motionDuration);
                      }
                    },
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ],
    );
  });
}
