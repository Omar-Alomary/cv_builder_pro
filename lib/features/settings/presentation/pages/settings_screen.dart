import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/index.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/repositories/resume_repository.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/language_dialog.dart';
import '../widgets/profile_header.dart';
import '../widgets/settings_card.dart';

/// Settings with persisted preferences and guarded platform operations.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.service});
  final SettingsService? service;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final _service = widget.service ?? SettingsService();
  final _repository = Get.find<ResumeRepository>();
  final _profile = ProfileController.instance;
  bool _busy = false;

  Future<void> _pickImage() async {
    try {
      final path = await _service.pickProfileImage();
      if (path == null || !mounted) return;
      await _profile.setImage(path);
      if (!mounted) return;
      AppSnackbar.success(context, 'profile_image_updated'.tr);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'profile_image_failed'.tr);
    }
  }

  Future<void> _language() async {
    final controller = Get.find<LanguageController>();
    final code = await showDialog<String>(
      context: context,
      builder: (_) =>
          LanguageDialog(selectedLanguage: controller.currentLanguage.value),
    );
    if (code != null && mounted) await controller.changeLanguage(code);
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
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
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.lg),
                  Text(message),
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
                        key: const ValueKey('confirm-settings-action'),
                        label: action,
                        variant: AppButtonVariant.danger,
                        onPressed: () => Navigator.of(context).pop(true),
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

  Future<void> _clear() async {
    if (_busy) return;
    _busy = true;
    try {
      if (!await _confirm(
            'clear_all_data'.tr,
            'clear_all_data_confirmation'.tr,
            'clear_all'.tr,
          ) ||
          !mounted) {
        return;
      }
      await Get.find<ResumeController>().clearAllData();
      _profile.resetImage();
      final language = Get.find<LanguageController>();
      language.isLanguageSelected.value = false;
      language.currentLanguage.value = 'en';
      Get.find<ThemeController>().isDarkMode.value = false;
      Get.changeThemeMode(ThemeMode.light);
      Get.locale = const Locale('en', 'US');
      Get.appUpdate();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      if (!mounted) return;
      Get.offAllNamed<void>(AppRoutes.splash);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'clear_all_data_failed'.tr);
    } finally {
      _busy = false;
    }
  }

  Future<void> _exit() async {
    if (_busy) return;
    _busy = true;
    try {
      if (!await _confirm(
            'exit_app'.tr,
            'settings_exit_confirmation'.tr,
            'exit'.tr,
          ) ||
          !mounted) {
        return;
      }
      Get.find<ResumeController>().stopAutoSave();
      await _repository.remove(StorageKeys.currentCv);
      await _repository.remove(StorageKeys.profileImage);
      _profile.resetImage();
      await _service.exitApp();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
    } finally {
      _busy = false;
    }
  }

  Widget _section(String title, List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      ...children,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final scale =
        MediaQuery.textScalerOf(context).scale(AppSpacing.lg) / AppSpacing.lg;
    final theme = Get.find<ThemeController>();
    final language = Get.find<LanguageController>();
    final sections = [
      _section('appearance'.tr, [
        Obx(
          () => SettingsCard(
            icon: Icons.dark_mode_outlined,
            title: 'dark_mode'.tr,
            subtitle: 'switch_theme'.tr,
            trailing: Switch(
              key: const ValueKey('settings-theme-switch'),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                final scheme = Theme.of(context).colorScheme;
                return states.contains(WidgetState.selected)
                    ? scheme.onPrimary
                    : scheme.onSurfaceVariant;
              }),
              value: theme.isDarkMode.value,
              onChanged: _busy
                  ? null
                  : (_) async {
                      await theme.toggleTheme();
                    },
            ),
          ),
        ),
        Obx(
          () => SettingsCard(
            icon: Icons.language,
            title: 'language'.tr,
            subtitle: 'change_app_language'.tr,
            actionLabel:
                (language.currentLanguage.value == 'ar'
                        ? 'language_arabic'
                        : 'language_english')
                    .tr,
            onAction: _language,
          ),
        ),
      ]),
      _section('support'.tr, [
        SettingsCard(
          icon: Icons.contact_support_outlined,
          title: 'contact_us'.tr,
          subtitle: 'get_help_support'.tr,
          onAction: _service.contactSupport,
        ),
        // SettingsCard(
        //   icon: Icons.star_outline,
        //   title: 'rate_app'.tr,
        //   subtitle: 'rate_us_on_store'.tr,
        //   onAction: _service.rateApp,
        // ),
        // Builder(
        //   builder: (context) => SettingsCard(
        //     icon: Icons.share_outlined,
        //     title: 'share_app'.tr,
        //     subtitle: 'share_with_friends'.tr,
        //     onAction: () async {
        //       final box = context.findRenderObject() as RenderBox;
        //       await _service.shareApp(
        //         box.localToGlobal(Offset.zero) & box.size,
        //         'share_app_message'.tr,
        //       );
        //     },
        //   ),
        // ),
      ]),
      _section('about'.tr, [
        SettingsCard(
          icon: Icons.info_outline,
          title: 'app_version'.tr,
          subtitle: 'version_1_0_0'.tr,
        ),
      ]),
      _section('data'.tr, [
        SettingsCard(
          key: const ValueKey('settings-clear'),
          icon: Icons.delete_forever_outlined,
          title: 'data_management'.tr,
          subtitle: 'settings_data_description'.tr,
          actionLabel: 'clear_all_data'.tr,
          isDestructive: true,
          onAction: _clear,
        ),
        AppButton(
          key: const ValueKey('settings-exit'),
          label: 'exit_app'.tr,
          icon: Icons.exit_to_app,
          fullWidth: true,
          variant: AppButtonVariant.secondary,
          onPressed: _exit,
        ),
      ]),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
        toolbarHeight:
            AppSpacing.touchTarget +
            AppSpacing.sm +
            math.max(0, scale - 1) * AppSpacing.xxl,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('settings-scroll'),
            padding: Responsive.pagePadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GetBuilder<ProfileController>(
                  init: _profile,
                  builder: (profile) => ProfileHeader(
                    imagePath: profile.imagePath,
                    onPick: _pickImage,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = Responsive.isTabletOrLarger(context)
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - AppSpacing.xl * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: AppSpacing.xl,
                      runSpacing: AppSpacing.xl,
                      children: sections
                          .map(
                            (section) => SizedBox(width: width, child: section),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
