import 'package:get/get.dart';
import '../app/routes/app_routes.dart';
import '../core/services/ats_analyzer_service.dart';
import '../data/models/ats_score_model.dart';
import '../data/models/resume_model.dart';
import 'resume_controller.dart';

/// Coordinates ATS analysis and applying the ATS output template.
class AtsController extends GetxController {
  final ResumeController _resumes;
  final AtsAnalyzerService _analyzer;
  final Rx<AtsScoreModel?> result = Rx<AtsScoreModel?>(null);
  final RxBool isAnalyzing = false.obs;
  final RxBool isApplyingTemplate = false.obs;
  final RxString errorMessage = ''.obs;
  ResumeModel? _analyzedResume;
  Worker? _resumeWorker;

  AtsController({
    ResumeController? resumeController,
    AtsAnalyzerService? analyzer,
  }) : _resumes = resumeController ?? Get.find<ResumeController>(),
       _analyzer = analyzer ?? const AtsAnalyzerService();

  @override
  void onInit() {
    super.onInit();
    _resumeWorker = ever<ResumeModel?>(_resumes.currentResume, (_) {
      result.value = null;
      _analyzedResume = null;
      errorMessage.value = '';
    });
  }

  AtsScoreModel? analyze({ResumeModel? resume}) {
    final target = resume ?? _resumes.currentResume.value;
    result.value = null;
    errorMessage.value = '';
    if (target == null || target.fullName.trim().isEmpty) {
      _analyzedResume = null;
      return null;
    }
    isAnalyzing.value = true;
    try {
      final score = _analyzer.analyze(
        target,
        locale: Get.locale?.languageCode ?? 'en',
      );
      _analyzedResume = target;
      result.value = score;
      return score;
    } catch (_) {
      _analyzedResume = null;
      errorMessage.value = 'ats_analysis_failed'.tr;
      return null;
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<bool> useAtsTemplate() async {
    if (isApplyingTemplate.value) return false;
    final target = _analyzedResume ?? _resumes.currentResume.value;
    if (target == null || target.fullName.trim().isEmpty) {
      analyze();
      return false;
    }
    isApplyingTemplate.value = true;
    errorMessage.value = '';
    try {
      final converted = target.copyWith(
        templateId: target.templateId.endsWith('_en') ? 'ats_en' : 'ats',
        customization: {
          ...?target.customization,
          'fontFamily': 'Cairo',
          'fontSize': 11.0,
        },
      );
      final saved = await _resumes.saveResume(converted);
      if (!saved) {
        errorMessage.value = 'ats_save_failed'.tr;
        return false;
      }
      _resumes.currentResume.value = converted;
      _resumes.isEditing.value = converted.id != null;
      analyze(resume: converted);
      return true;
    } catch (_) {
      errorMessage.value = 'ats_apply_failed'.tr;
      return false;
    } finally {
      isApplyingTemplate.value = false;
    }
  }

  Future<void> editResume() async {
    final target = _analyzedResume ?? _resumes.currentResume.value;
    await Get.toNamed<void>(
      AppRoutes.resumeBuilder,
      arguments: target?.copyWith(),
    );
  }

  @override
  void onClose() {
    _resumeWorker?.dispose();
    super.onClose();
  }
}
