import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/template_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/template_grid_card.dart';

/// Searches both template languages and filters the responsive catalog by type.
class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final _search = TextEditingController();
  String _category = 'all';
  String _language = 'ar';
  static const _categories = [
    'all',
    'modern',
    'classic',
    'business',
    'technical',
    'ats',
  ];

  void _reset() => setState(() {
    _search.clear();
    _category = 'all';
  });

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final controller = Get.find<TemplateController>();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(title: Text('templates'.tr)),
        body: SafeArea(
          child: Responsive.maxWidth(
            child: Padding(
              padding: Responsive.pagePadding(context),
              child: CustomScrollView(
                key: const ValueKey('templates-scroll'),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'catalog_heading'.tr,
                          style: AppTextStyles.resolve(
                            context,
                            AppTextStyles.h2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'catalog_intro'.tr,
                          style:
                              AppTextStyles.resolve(
                                context,
                                AppTextStyles.bodySmall,
                              ).copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          onTap: (index) => setState(
                            () => _language = ['ar', 'en', 'all'][index],
                          ),
                          tabs: [
                            const Tab(
                              key: ValueKey('language-ar'),
                              text: 'العربية',
                            ),
                            const Tab(
                              key: ValueKey('language-en'),
                              text: 'English',
                            ),
                            Tab(
                              key: const ValueKey('language-all'),
                              text: 'template_category_all'.tr,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppTextField(
                          key: const ValueKey('template-search'),
                          controller: _search,
                          label: 'search_templates'.tr,
                          hint: 'search_hint'.tr,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _search.text.isEmpty
                              ? null
                              : IconButton(
                                  key: const ValueKey('clear-template-search'),
                                  tooltip: 'clear_template_search'.tr,
                                  icon: const Icon(Icons.close),
                                  onPressed: () => setState(_search.clear),
                                ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories
                                .map(
                                  (category) => Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                      end: AppSpacing.sm,
                                    ),
                                    child: ChoiceChip(
                                      key: ValueKey('category-$category'),
                                      label: Text(
                                        'template_category_$category'.tr,
                                      ),
                                      selected: _category == category,
                                      onSelected: (_) =>
                                          setState(() => _category = category),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                  Obx(() {
                    final entries = controller
                        .searchTemplates(_search.text)
                        .where(
                          (template) =>
                              _language == 'all' ||
                              template.language == _language,
                        )
                        .where(
                          (template) =>
                              _category == 'all' || template.type == _category,
                        )
                        .toList();
                    if (entries.isEmpty) {
                      final filtered =
                          _search.text.isNotEmpty || _category != 'all';
                      return SliverToBoxAdapter(
                        child: AppEmptyState(
                          title:
                              (filtered
                                      ? 'no_search_results'
                                      : 'no_templates_available')
                                  .tr,
                          icon: Icons.search_off,
                          actionLabel: filtered
                              ? 'reset_template_filters'.tr
                              : null,
                          onAction: filtered ? _reset : null,
                        ),
                      );
                    }
                    final ratio = Responsive.value<double>(
                      context: context,
                      mobile: .65,
                      tablet: .75,
                      desktop: .85,
                    );
                    return SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = Responsive.columns(
                          context,
                          mobile: 1,
                          tablet: 2,
                          desktop: 3,
                        );
                        final width =
                            (constraints.crossAxisExtent -
                                AppSpacing.md * (columns - 1)) /
                            columns;
                        return SliverGrid(
                          key: const ValueKey('template-grid'),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: ratio,
                                mainAxisExtent:
                                    math.max(440, width / ratio * .85) +
                                    math.max(0, scale - 1) * 260,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final template = entries[index];
                            return TemplateGridCard(
                              template: template,
                              onSelect: () async {
                                await Get.toNamed<void>(
                                  AppRoutes.resumeBuilder,
                                  arguments: template.id,
                                );
                              },
                            );
                          }, childCount: entries.length),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
