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
