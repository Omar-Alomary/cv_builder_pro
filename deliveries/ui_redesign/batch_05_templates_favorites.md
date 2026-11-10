# UI/UX — Batch 5: Templates + Favorites
طُبقت الدفعة الخامسة داخل طبقة العرض فقط، دون تعديل المتحكمات أو الخدمات أو المستودعات أو النماذج أو الترجمات أو الاعتماديات.
القوالب: SliverAppBar عائم، بحث ضمن المحتوى العلوي، تصنيفات أفقية قابلة للتمرير، شبكة 2/3/4 أعمدة بالنسب الأصلية، بطاقات AppCard مع hover بنسبة 1.02 ومعاينة مستند زخرفية، وشارات Featured وATS. المعاينة الزخرفية ليست PDF مولداً؛ اختيار البطاقة أو زرها يفتح البناء بمعرّف القالب نفسه. يوجد منع لتكرار فتح البطاقة ومعالجة خطأ التنقل.
المفضلة: بطاقات بسطح وظل النظام، AppAvatar مع الصورة أو الحرف البديل، البريد وتاريخ الحفظ والمهارات، وزري التعديل والإزالة. أضيف Dismissible باتجاه endToStart مع خلفية توضح الإزالة. يستدعي السحب نافذة التأكيد القائمة وعملية الحفظ القائمة؛ لا يحذف السيرة نفسها. تبقى البطاقة عند الإلغاء أو فشل الحفظ، وتزال بعد تحديث حالة المفضلة المحفوظة. ينعكس اتجاه السحب في العربية.
بقي البحث في اللغتين والتصنيف المتقاطع ومسح البحث وإعادة تعيين المرشحات والحالات الفارغة والتعديل بمسودة مستقلة دون تغيير. تحميل القوالب والسير متزامن في المتحكمات الحالية؛ لم تُضف حالة تحميل وهمية. يظهر انتظار الإجراء على أزرار AppButton، وتبقى معالجة أخطاء التخزين القائمة فعالة.
التحقق: flutter analyze دون ملاحظات، وجميع اختبارات المشروع الـ422 ناجحة. تشمل 40 حالة جديدة للشاشتين عند عروض 320/390/600/1024/1920 مع العربية والإنجليزية والوضعين وتكبير النص 200%، إضافة إلى 6 حالات للسحب تشمل التأكيد والإلغاء وفشل الحفظ بالاتجاهين. تبقى اختبارات القوالب والمفضلة السابقة الـ19 دون تعديل. صور المعاينة تُولد بخطوط التطبيق الفعلية عند تكبير النص الافتراضي. لم يُكرر التشغيل على جهاز فعلي في هذه الدفعة.
## المعاينات
[templates — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_templates_light_en_390.png)
[templates — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_templates_light_en_1920.png)
[templates — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_templates_dark_ar_390.png)
[templates — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_templates_dark_ar_1920.png)
[favorites — light_en — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_favorites_light_en_390.png)
[favorites — light_en — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_favorites_light_en_1920.png)
[favorites — dark_ar — 390](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_favorites_dark_ar_390.png)
[favorites — dark_ar — 1920](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/batch_05_favorites_dark_ar_1920.png)
## الملفات كاملة
1. lib/features/templates/presentation/pages/templates_screen.dart
2. lib/features/templates/presentation/widgets/template_grid_card.dart
3. lib/features/favorites/presentation/pages/favorites_screen.dart
4. lib/features/favorites/presentation/widgets/favorite_card.dart
5. test/templates/redesign_catalog_test.dart

## lib/features/templates/presentation/pages/templates_screen.dart
```dart
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
    return Scaffold(
      body: SafeArea(
        child: Responsive.maxWidth(
          child: Padding(
            padding: Responsive.pagePadding(context),
            child: CustomScrollView(
              key: const ValueKey('templates-scroll'),
              slivers: [
                SliverAppBar(
                  title: Text('templates'.tr),
                  floating: true,
                  snap: true,
                  toolbarHeight:
                      AppSpacing.touchTarget +
                      AppSpacing.sm +
                      math.max(0, scale - 1) * AppSpacing.xxl,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                    mobile: .40,
                    tablet: .55,
                    desktop: .65,
                  );
                  return SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final columns = Responsive.columns(context);
                      final width =
                          (constraints.crossAxisExtent -
                              AppSpacing.md * (columns - 1)) /
                          columns;
                      return SliverGrid(
                        key: const ValueKey('template-grid'),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: ratio,
                          mainAxisExtent: scale > 1
                              ? width / ratio +
                                    (scale - 1) * AppSpacing.xxxl * 8
                              : null,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
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
    );
  }
}

```

## lib/features/templates/presentation/widgets/template_grid_card.dart
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../data/models/template_model.dart';
import '../../../../shared_widgets/index.dart';

/// Interactive catalog card with a decorative document and accessible badges.
class TemplateGridCard extends StatefulWidget {
  const TemplateGridCard({
    super.key,
    required this.template,
    required this.onSelect,
  });
  final TemplateModel template;
  final Future<void> Function() onSelect;
  @override
  State<TemplateGridCard> createState() => _TemplateGridCardState();
}

class _TemplateGridCardState extends State<TemplateGridCard> {
  bool _opening = false;
  Future<void> _select() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await widget.onSelect();
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'action_failed'.tr);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.template;
    final scheme = Theme.of(context).colorScheme;
    final hex = template.previewColor?.replaceFirst('#', '') ?? '';
    final value = hex.length == 6 ? int.tryParse(hex, radix: 16) : null;
    final color = value == null ? scheme.primary : Color(0xFF000000 | value);
    final ats = template.id == 'ats';
    final icon = switch (template.id) {
      'modern' => Icons.auto_awesome_outlined,
      'business' => Icons.business_center_outlined,
      'technical' => Icons.code,
      'ats' => Icons.fact_check_outlined,
      _ => Icons.description_outlined,
    };
    return AppCard(
      onTap: _opening ? null : _select,
      padding: const EdgeInsets.all(AppSpacing.md),
      semanticsLabel: '${'use_template'.tr}: ${template.localizedName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      color.withValues(alpha: .18),
                      color.withValues(alpha: .04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: .75,
                    heightFactor: .78,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                        boxShadow: AppShadows.soft,
                        border: Border.all(color: scheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxHeight < AppSpacing.xxxl * 2) {
                              return FittedBox(
                                child: Icon(
                                  icon,
                                  color: scheme.primary,
                                  size: AppSpacing.xxl,
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  icon,
                                  color: scheme.primary,
                                  size: AppSpacing.xxl,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                for (var index = 0; index < 4; index++) ...[
                                  FractionallySizedBox(
                                    widthFactor: index.isEven ? 1 : .65,
                                    child: Container(
                                      height: AppSpacing.xs,
                                      color: ats
                                          ? scheme.onSurface.withValues(
                                              alpha: .25,
                                            )
                                          : color.withValues(alpha: .35),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (template.isFeatured || ats) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: AppRadii.chip,
                ),
                child: Text(
                  ats ? 'ATS' : 'featured'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.resolve(
                    context,
                    AppTextStyles.caption,
                  ).copyWith(color: scheme.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Text(
            template.localizedName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.resolve(context, AppTextStyles.h4),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            template.localizedDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.resolve(
              context,
              AppTextStyles.bodySmall,
            ).copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            key: ValueKey('select-template-${template.id}'),
            label: 'use_template'.tr,
            semanticsLabel: '${'use_template'.tr}: ${template.localizedName}',
            fullWidth: true,
            size: AppButtonSize.sm,
            isLoading: _opening,
            onPressed: _select,
          ),
        ],
      ),
    );
  }
}

```

## lib/features/favorites/presentation/pages/favorites_screen.dart
```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/favorite_card.dart';

/// Searchable favorites that react to persisted changes without copying lists.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _search = TextEditingController();
  bool _confirming = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _remove(ResumeModel resume) async {
    if (_confirming || resume.id == null) return;
    _confirming = true;
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
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
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'remove_favorite'.tr,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'favorite_remove_confirmation'.trParams({
                      'name': resume.fullName.trim().isEmpty
                          ? 'untitled_resume'.tr
                          : resume.fullName,
                    }),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'cancel'.tr,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      AppButton(
                        key: const ValueKey('confirm-remove-favorite'),
                        label: 'remove_favorite'.tr,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      if (confirmed == true && mounted) {
        final controller = Get.find<ResumeController>();
        if (controller.getFavoriteResumes().any(
          (item) => item.id == resume.id,
        )) {
          await controller.toggleFavorite(resume.id!);
        }
      }
    } finally {
      _confirming = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites'.tr),
        toolbarHeight:
            AppSpacing.touchTarget +
            AppSpacing.sm +
            math.max(0, scale - 1) * AppSpacing.xxl,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('favorites-scroll'),
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _search,
                  label: 'search_favorites'.tr,
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (_) => setState(() {}),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          key: const ValueKey('clear-favorites-search'),
                          tooltip: 'clear_template_search'.tr,
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(_search.clear),
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Obx(() {
                  final favorites = Get.find<ResumeController>()
                      .getFavoriteResumes();
                  final query = _search.text.trim().toLowerCase();
                  final entries = favorites
                      .where(
                        (resume) => [
                          resume.fullName,
                          resume.email,
                          ...resume.skills.map((skill) => skill.name),
                        ].any((text) => text.toLowerCase().contains(query)),
                      )
                      .toList();
                  if (entries.isEmpty) {
                    return AppEmptyState(
                      title:
                          (favorites.isEmpty
                                  ? 'favorites_empty_title'
                                  : 'no_search_results')
                              .tr,
                      description: favorites.isEmpty
                          ? 'favorites_empty_description'.tr
                          : null,
                      icon: Icons.favorite_border,
                      actionLabel:
                          (favorites.isEmpty
                                  ? 'create_resume'
                                  : 'clear_template_search')
                              .tr,
                      onAction: () async {
                        if (favorites.isEmpty) {
                          await Get.toNamed<void>(AppRoutes.resumeBuilder);
                        } else {
                          setState(_search.clear);
                        }
                      },
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = Responsive.value<int>(
                        context: context,
                        mobile: 1,
                        tablet: 2,
                        desktop: 3,
                      );
                      final width =
                          (constraints.maxWidth -
                              AppSpacing.lg * (columns - 1)) /
                          columns;
                      return Wrap(
                        spacing: AppSpacing.lg,
                        runSpacing: AppSpacing.lg,
                        children: entries
                            .map(
                              (resume) => SizedBox(
                                width: width,
                                child: FavoriteCard(
                                  resume: resume,
                                  onEdit: () async {
                                    await Get.toNamed<void>(
                                      AppRoutes.resumeBuilder,
                                      arguments: resume.copyWith(),
                                    );
                                  },
                                  onRemove: () => _remove(resume),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/features/favorites/presentation/widgets/favorite_card.dart
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../app/theme/index.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';

/// Saved favorite with profile fallback and accessible editing actions.
class FavoriteCard extends StatelessWidget {
  const FavoriteCard({
    super.key,
    required this.resume,
    required this.onEdit,
    required this.onRemove,
  });
  final ResumeModel resume;
  final Future<void> Function() onEdit;
  final Future<void> Function() onRemove;

  @override
  Widget build(BuildContext context) {
    final name = resume.fullName.trim().isEmpty
        ? 'untitled_resume'.tr
        : resume.fullName;
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('swipe-favorite-${resume.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await onRemove();
        // Persisted controller state removes the card; cancellation or failure
        // leaves it in place instead of optimistically hiding the resume.
        return false;
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppRadii.card,
        ),
        child: Icon(
          Icons.heart_broken_outlined,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: AppAvatar(
                    name: name,
                    size: AppSpacing.xxxl,
                    image: resume.profilePicture?.isNotEmpty == true
                        ? FileImage(File(resume.profilePicture!))
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    name,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.resolve(context, AppTextStyles.h4),
                  ),
                ),
              ],
            ),
            if (resume.email.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                resume.email,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.ltr,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              'last_saved'.trParams({
                'time': DateFormatter.relativeTime(
                  resume.updatedAt ?? resume.createdAt,
                  locale: Get.locale?.languageCode ?? 'en',
                ),
              }),
              style: AppTextStyles.resolve(
                context,
                AppTextStyles.caption,
              ).copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (resume.skills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: resume.skills
                    .take(3)
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              key: ValueKey('edit-favorite-${resume.id}'),
              label: 'edit_resume'.tr,
              icon: Icons.edit_outlined,
              fullWidth: true,
              onPressed: onEdit,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              key: ValueKey('remove-favorite-${resume.id}'),
              label: 'remove_favorite'.tr,
              icon: Icons.favorite,
              variant: AppButtonVariant.secondary,
              fullWidth: true,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

```

## test/templates/redesign_catalog_test.dart
```dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/theme/index.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/templates/index.dart';
import 'package:cv_builder_pro/features/favorites/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  bool fail = false;
  final entries = [
    ResumeModel(
      id: 1,
      fullName: 'Alex Morgan',
      email: 'alex@example.com',
      isFavorite: true,
      skills: [
        Skill(name: 'Flutter'),
        Skill(name: 'Communication'),
      ],
    ),
  ];
  @override
  List<ResumeModel> loadResumes() => entries.map((e) => e.copyWith()).toList();
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw StateError('storage failure');
    entries[0] = resume.copyWith();
    return resume.copyWith();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _host(
  bool favorites, {
  bool arabic = false,
  bool dark = false,
  double scale = 1,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: RepaintBoundary(
    key: const ValueKey('catalog-preview'),
    child: favorites ? const FavoritesScreen() : const TemplatesScreen(),
  ),
);
Future<void> _capture(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final image = await tester
        .renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('catalog-preview')),
        )
        .toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(
        'deliveries/ui_redesign/batch_05_$name.png',
      ).writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}

void main() {
  setUpAll(() async {
    for (final entry in {
      'Poppins': 'assets/fonts/Poppins-Regular.ttf',
      'Cairo': 'assets/fonts/Cairo-Regular.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
    }.entries) {
      final font = FontLoader(entry.key)..addFont(rootBundle.load(entry.value));
      await font.load();
    }
  });
  tearDown(Get.reset);
  for (final favorites in [false, true]) {
    for (final width in [320.0, 390.0, 600.0, 1024.0, 1920.0]) {
      for (final arabic in [false, true]) {
        for (final dark in [false, true]) {
          testWidgets(
            '${favorites ? 'favorites' : 'templates'} $width ar=$arabic dark=$dark large text',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(
                width,
                width == 1024 ? 480 : 1000,
              );
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              Get.put(TemplateController());
              Get.put(ResumeController(repository: _Repository()));
              await tester.pumpWidget(
                _host(favorites, arabic: arabic, dark: dark, scale: 2),
              );
              await tester.pumpAndSettle();
              await tester.drag(
                find.byKey(
                  ValueKey(favorites ? 'favorites-scroll' : 'templates-scroll'),
                ),
                const Offset(0, -400),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              if (const bool.fromEnvironment('WRITE_UI_PREVIEWS') &&
                  (width == 390 || width == 1920) &&
                  arabic == dark) {
                await tester.pumpWidget(const SizedBox());
                await tester.pumpWidget(
                  _host(favorites, arabic: arabic, dark: dark),
                );
                await tester.pumpAndSettle();
                await _capture(
                  tester,
                  '${favorites ? 'favorites' : 'templates'}_${dark ? 'dark_ar' : 'light_en'}_${width.toInt()}',
                );
              }
            },
          );
        }
      }
    }
  }
  for (final arabic in [false, true]) {
    for (final outcome in ['cancel', 'confirm', 'failure']) {
      testWidgets(
        'swipe favorite $outcome ar=$arabic preserves persisted state',
        (tester) async {
          final repository = _Repository()..fail = outcome == 'failure';
          final controller = Get.put(ResumeController(repository: repository));
          await tester.pumpWidget(_host(true, arabic: arabic));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byKey(const ValueKey('swipe-favorite-1')),
            Offset(arabic ? 700 : -700, 0),
          );
          await tester.pump(const Duration(milliseconds: 500));
          expect(find.byType(Dialog), findsOneWidget);
          await tester.tap(
            outcome == 'cancel'
                ? find.text('cancel'.tr)
                : find.byKey(const ValueKey('confirm-remove-favorite')),
          );
          await tester.pumpAndSettle();
          expect(controller.resumes, hasLength(1));
          expect(
            controller.getFavoriteResumes(),
            hasLength(outcome == 'confirm' ? 0 : 1),
          );
          expect(repository.entries.first.isFavorite, outcome != 'confirm');
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

```


