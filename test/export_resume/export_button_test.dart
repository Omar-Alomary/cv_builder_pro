import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/core/services/resume_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Service extends ResumeExportService {
  ResumeModel? captured;
  String? path = '/saved/resume.json';
  int saves = 0;
  bool fail = false;
  Completer<String?>? pending;
  ShareResultStatus status = ShareResultStatus.success;
  @override
  Future<String?> saveJson(ResumeModel resume) async {
    saves++;
    captured = resume;
    if (fail) throw const ExportException('export_json_save_failed');
    return pending == null ? path : pending!.future;
  }

  @override
  Future<ShareResult> shareJson(
    ResumeModel resume, {
    required Rect origin,
  }) async {
    captured = resume;
    expect(origin.width, greaterThan(0));
    return ShareResult('', status);
  }
}

Widget _host(
  _Service service,
  ResumeModel? resume, {
  double scale = 1,
  bool arabic = false,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: arabic ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: Scaffold(
    appBar: AppBar(
      actions: [ResumeJsonExportButton(resume: () => resume, service: service)],
    ),
  ),
);
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.byTooltip('export_json'.tr));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(ValueKey(key));
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('export dialog fits $width with Arabic large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        _host(_Service(), ResumeModel(fullName: 'عمر'), scale: 2, arabic: true),
      );
      await _open(tester);
      await tester.ensureVisible(
        find.byKey(const ValueKey('share-resume-json')),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('save exports a snapshot including unpersisted edits', (
    tester,
  ) async {
    final resume = ResumeModel(
      fullName: 'Draft',
      skills: [Skill(name: 'Dart')],
    );
    final service = _Service();
    await tester.pumpWidget(_host(service, resume));
    await _open(tester);
    resume.fullName = 'Changed later';
    resume.skills.clear();
    await _tap(tester, 'save-resume-json');
    expect(service.captured!.fullName, 'Draft');
    expect(service.captured!.skills.single.name, 'Dart');
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('export_json_saved'.tr), findsOneWidget);
  });
  testWidgets('cancelled picker keeps dialog open without success message', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_Service()..path = null, ResumeModel()));
    await _open(tester);
    await _tap(tester, 'save-resume-json');
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('export_json_saved'.tr), findsNothing);
  });
  testWidgets('errors appear inside dialog and retry succeeds', (tester) async {
    final service = _Service()..fail = true;
    await tester.pumpWidget(_host(service, ResumeModel()));
    await _open(tester);
    await _tap(tester, 'save-resume-json');
    expect(
      find.descendant(
        of: find.byType(Dialog),
        matching: find.text('export_json_save_failed'.tr),
      ),
      findsOneWidget,
    );
    service.fail = false;
    await _tap(tester, 'save-resume-json');
    expect(find.byType(Dialog), findsNothing);
  });
  testWidgets('sharing dismiss stays open and success closes dialog', (
    tester,
  ) async {
    final service = _Service()..status = ShareResultStatus.dismissed;
    await tester.pumpWidget(_host(service, ResumeModel()));
    await _open(tester);
    await _tap(tester, 'share-resume-json');
    expect(find.byType(Dialog), findsOneWidget);
    service.status = ShareResultStatus.success;
    await _tap(tester, 'share-resume-json');
    expect(find.byType(Dialog), findsNothing);
  });
  testWidgets('no resume reports feedback without opening export', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_Service(), null));
    await _open(tester);
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('export_no_resume'.tr), findsOneWidget);
  });
  testWidgets('pending export blocks duplicate save and other actions', (
    tester,
  ) async {
    final service = _Service()..pending = Completer<String?>();
    await tester.pumpWidget(_host(service, ResumeModel()));
    await _open(tester);
    await tester.tap(find.byKey(const ValueKey('save-resume-json')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('save-resume-json')));
    await tester.pump();
    expect(service.saves, 1);
    final share = tester.widget<OutlinedButton>(
      find.descendant(
        of: find.byKey(const ValueKey('share-resume-json')),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(share.onPressed, isNull);
    service.pending!.complete('/saved/resume.json');
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
