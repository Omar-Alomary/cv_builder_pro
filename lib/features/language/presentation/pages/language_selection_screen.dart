import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/index.dart';
import '../../../../controllers/language_controller.dart';
import '../../../../core/utils/responsive.dart';

/// Compact, accessible language choices using the existing persistence flow.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _activeCode;

  Future<void> _select(String code) async {
    final controller = Get.find<LanguageController>();
    if (controller.isSelecting.value) return;
    setState(() => _activeCode = code);
    try {
      await controller.selectLanguage(code);
    } finally {
      if (mounted) setState(() => _activeCode = null);
    }
  }

  Widget _choice(String code) {
    final controller = Get.find<LanguageController>();
    final scheme = Theme.of(context).colorScheme;
    final english = code == 'en';
    return Obx(() {
      final busy = controller.isSelecting.value;
      final loading = busy && _activeCode == code;
      return Semantics(
        key: ValueKey('language-card-$code'),
        label: english ? 'Select English' : 'اختيار اللغة العربية',
        button: true,
        enabled: !busy,
        onTap: busy ? null : () => _select(code),
        child: ExcludeSemantics(
          child: SizedBox(
            key: ValueKey('select-$code'),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: busy ? null : () => _select(code),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                disabledBackgroundColor: scheme.surface,
                disabledForegroundColor: scheme.onSurfaceVariant,
                padding: const EdgeInsets.all(18),
                minimumSize: const Size(0, 100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
              ),
              child: Directionality(
                textDirection: english ? TextDirection.ltr : TextDirection.rtl,
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        english ? 'Aa' : 'ع',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          fontFamily: english ? 'Poppins' : 'Cairo',
                          fontSize: 22,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            english ? 'English' : 'العربية',
                            style: TextStyle(
                              fontFamily: english ? 'Poppins' : 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            english ? 'الإنجليزية' : 'Arabic',
                            style: TextStyle(
                              fontFamily: english ? 'Cairo' : 'Poppins',
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (loading)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight - 64).clamp(
                    0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: Responsive.maxWidth(
                    width: 680,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'app_name'.tr,
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyles.resolve(
                                context,
                                AppTextStyles.bodySmall,
                              ).copyWith(
                                color: scheme.onSurfaceVariant,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: .08),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.translate_rounded,
                              color: scheme.primary,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Semantics(
                          header: true,
                          child: Text(
                            'language_selection_title'.tr,
                            textAlign: TextAlign.center,
                            style:
                                AppTextStyles.resolve(
                                  context,
                                  AppTextStyles.h3,
                                ).copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'language_selection_subtitle'.tr,
                          textAlign: TextAlign.center,
                          style:
                              AppTextStyles.resolve(
                                context,
                                AppTextStyles.bodySmall,
                              ).copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.6,
                              ),
                        ),
                        const SizedBox(height: 28),
                        if (Responsive.isTabletOrLarger(context))
                          Row(
                            key: const ValueKey('language-row'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _choice('en')),
                              const SizedBox(width: 16),
                              Expanded(child: _choice('ar')),
                            ],
                          )
                        else
                          Column(
                            key: const ValueKey('language-column'),
                            children: [
                              _choice('en'),
                              const SizedBox(height: 12),
                              _choice('ar'),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
