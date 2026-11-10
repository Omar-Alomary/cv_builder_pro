import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/services/settings_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Images extends SettingsService {
  bool fail = false;
  @override
  Future<String?> pickProfileImage() async {
    if (fail) throw Exception('permission denied');
    return null;
  }
}

void main() {
  tearDown(Get.reset);
  testWidgets(
    'photo cancellation preserves data, failure reports feedback, removal clears reference',
    (tester) async {
      final resumes = Get.put(ResumeController(repository: _Repository()));
      Get.put(TemplateController());
      resumes.currentResume.value = ResumeModel(profilePicture: '');
      final images = _Images();
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          translations: AppTranslations(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: Scaffold(body: PersonalInfoStep(imageService: images)),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('personal-pick-image')));
      await tester.pumpAndSettle();
      expect(resumes.currentResume.value!.profilePicture, '');
      images.fail = true;
      await tester.tap(find.byKey(const ValueKey('personal-pick-image')));
      await tester.pumpAndSettle();
      expect(find.text('profile_image_failed'.tr), findsOneWidget);
      await tester.tap(find.text('builder_remove_photo'.tr));
      await tester.pumpAndSettle();
      expect(resumes.currentResume.value!.profilePicture, isNull);
    },
  );
}
