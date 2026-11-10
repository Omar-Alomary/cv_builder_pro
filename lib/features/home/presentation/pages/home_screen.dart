import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../controllers/profile_controller.dart';
import '../../../../app/theme/index.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../../../../controllers/language_controller.dart';
import '../widgets/home_primary_action.dart';
import '../widgets/stats_cards.dart';
import '../widgets/template_carousel.dart';
import '../widgets/recent_activity_card.dart';

/// Responsive dashboard for templates, saved resumes and navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _recentKey = GlobalKey();
  bool _showAll = false;
  bool _exitDialogOpen = false;
  bool _creating = false;

  void _viewAll() {
    setState(() => _showAll = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _recentKey.currentContext == null) return;
      Scrollable.ensureVisible(
        _recentKey.currentContext!,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
      );
    });
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Dialog(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(message),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(
                        label: 'cancel'.tr,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                      ),
                      AppButton(
                        label: action,
                        variant: AppButtonVariant.danger,
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ) ??
      false;

  Future<void> _delete(ResumeModel resume) async {
    if (resume.id == null) return;
    final confirmed = await _confirm(
      'delete'.tr,
      'delete_resume_confirmation'.tr,
      'delete'.tr,
    );
    if (confirmed && mounted) {
      await Get.find<ResumeController>().deleteResume(resume.id!);
    }
  }

  Future<void> _requestExit() async {
    if (_exitDialogOpen) return;
    _exitDialogOpen = true;
    try {
      final confirmed = await _confirm(
        'exit_app'.tr,
        'exit_confirmation'.tr,
        'exit'.tr,
      );
      if (confirmed && mounted) await SystemNavigator.pop();
    } catch (_) {
      if (mounted) AppSnackBar.error(context, 'action_failed'.tr);
    } finally {
      _exitDialogOpen = false;
    }
  }

  Widget _recent() {
    final controller = Get.find<ResumeController>();
    return Obx(() {
      final items = controller.getRecentResumes(
        limit: _showAll ? controller.resumes.length : 5,
      );
      if (items.isEmpty) {
        return Text(
          'home_no_resumes'.tr,
          style: Theme.of(context).textTheme.bodySmall,
        );
      }
      Widget card(int index) => RecentActivityCard(
        key: ValueKey('recent-${items[index].id}'),
        resume: items[index],
        onEdit: () {
          Get.toNamed<void>(
            AppRoutes.resumeBuilder,
            arguments: items[index].copyWith(),
          );
        },
        onDelete: () => _delete(items[index]),
        onFavorite: () async {
          final id = items[index].id;
          if (id != null) await controller.toggleFavorite(id);
        },
      );
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      return SizedBox(
        height: 180 + (scale > 1 ? scale - 1 : 0) * 160,
        child: ListView.separated(
          key: const ValueKey('recent-list'),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (_, index) => SizedBox(
            width: 224 + (scale > 1 ? scale - 1 : 0) * 80,
            child: card(index),
          ),
        ),
      );
    });
  }

  Future<void> _create() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      await Get.toNamed<void>(AppRoutes.resumeBuilder);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  void _destination(int index) {
    if (index == 0) return;
    Get.toNamed<void>(
      [
        AppRoutes.home,
        AppRoutes.templates,
        AppRoutes.favorites,
        AppRoutes.settings,
      ][index],
    );
  }

  Widget _content(ResumeController resumes) => RefreshIndicator(
    onRefresh: () async {
      resumes.loadResumes();
    },
    child: SingleChildScrollView(
      key: const ValueKey('home-scroll'),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Responsive.maxWidth(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomePrimaryAction(
                onAts: () async {
                  await Get.toNamed<void>(AppRoutes.atsChecker);
                },
                onCreate: _create,
                onImport: () async {
                  await Get.toNamed<void>(AppRoutes.importResume);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              StatsCards(onViewResumes: _viewAll),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(
                key: _recentKey,
                inlineAction: true,
                title: (_showAll ? 'resumes' : 'recent_resumes').tr,
                actionLabel: (_showAll ? 'show_recent' : 'view_all').tr,
                onAction: () {
                  if (_showAll) {
                    setState(() => _showAll = false);
                  } else {
                    _viewAll();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _recent(),
              const SizedBox(height: AppSpacing.lg),
              AppSectionHeader(
                inlineAction: true,
                title: 'featured_templates'.tr,
                actionLabel: 'view_all'.tr,
                onAction: () async {
                  await Get.toNamed<void>(AppRoutes.templates);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              const TemplateCarousel(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _rail(double scale) {
    final extended = Responsive.isDesktop(context) && scale < 1.5;
    final labels = ['home'.tr, 'templates'.tr, 'favorites'.tr, 'settings'.tr];
    final icons = [
      Icons.home_outlined,
      Icons.grid_view_outlined,
      Icons.favorite_outline,
      Icons.settings_outlined,
    ];
    return NavigationRail(
      key: const ValueKey('home-navigation-rail'),
      selectedIndex: 0,
      extended: extended,
      labelType: NavigationRailLabelType.none,
      minWidth: AppSpacing.xxxl + AppSpacing.xxl,
      minExtendedWidth: AppSpacing.xxxl * 4,
      onDestinationSelected: _destination,
      leading: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Icon(
          Icons.description_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      destinations: [
        for (var index = 0; index < labels.length; index++)
          NavigationRailDestination(
            icon: Tooltip(message: labels[index], child: Icon(icons[index])),
            label: Text(labels[index]),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumes = Get.find<ResumeController>();
    final scale =
        MediaQuery.textScalerOf(
          context,
        ).scale(AppTextStyles.bodySmall.fontSize!) /
        AppTextStyles.bodySmall.fontSize!;
    final mobile = Responsive.isMobile(context);
    Widget dashboard(String locale) {
      return Directionality(
        textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _requestExit();
          },
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 64 + (scale > 1 ? scale - 1 : 0) * 40,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'app_name'.tr,
                    style: AppTextStyles.resolve(context, AppTextStyles.h4),
                  ),
                  Text(
                    'home_welcome'.tr,
                    style: AppTextStyles.resolve(
                      context,
                      AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: AppSpacing.lg),
                  child: GetBuilder<ProfileController>(
                    init: ProfileController.instance,
                    builder: (profile) => ProfileAvatar(
                      key: const ValueKey('home-profile-avatar'),
                      imagePath: profile.imagePath,
                      size: AppSpacing.touchTarget,
                      label: 'settings'.tr,
                      onTap: () => Get.toNamed<void>(AppRoutes.settings),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!mobile) ...[
                    _rail(scale),
                    const VerticalDivider(width: AppSpacing.stroke),
                  ],
                  Expanded(child: _content(resumes)),
                ],
              ),
            ),
            bottomNavigationBar: mobile
                ? NavigationBar(
                    key: const ValueKey('home-navigation-bar'),
                    height:
                        AppSpacing.touchTarget +
                        AppSpacing.xxl +
                        (scale > 1 ? scale - 1 : 0) * AppSpacing.xl,
                    selectedIndex: 0,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    onDestinationSelected: _destination,
                    destinations: [
                      NavigationDestination(
                        icon: const Icon(Icons.home_outlined),
                        selectedIcon: const Icon(Icons.home),
                        label: 'home'.tr,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.grid_view_outlined),
                        label: 'templates'.tr,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.favorite_outline),
                        label: 'favorites'.tr,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.settings_outlined),
                        label: 'settings'.tr,
                      ),
                    ],
                  )
                : null,
          ),
        ),
      );
    }

    return Get.isRegistered<LanguageController>()
        ? Obx(
            () =>
                dashboard(Get.find<LanguageController>().currentLanguage.value),
          )
        : dashboard(
            Get.locale?.languageCode ??
                Localizations.localeOf(context).languageCode,
          );
  }
}
