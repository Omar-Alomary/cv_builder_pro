import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/favorites/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final entries = [
    ResumeModel(
      id: 1,
      fullName: 'Alice',
      email: 'alice@example.com',
      isFavorite: true,
      skills: [
        Skill(name: 'Flutter'),
        Skill(name: 'Communication'),
      ],
    ),
    ResumeModel(
      id: 2,
      fullName: 'عمر',
      email: 'omer@example.com',
      isFavorite: true,
      skills: [Skill(name: 'Dart')],
    ),
    ResumeModel(id: 3, fullName: 'Hidden', isFavorite: false),
  ];
  bool failSave = false;
  @override
  List<ResumeModel> loadResumes() =>
      entries.map((item) => item.copyWith()).toList();
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (failSave) throw Exception('disk failure');
    entries[entries.indexWhere((item) => item.id == resume.id)] = resume
        .copyWith();
    return resume.copyWith();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host({
  double scale = 1,
  bool arabic = false,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: arabic ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: const FavoritesScreen(),
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
  ],
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  // The awaited confirmation keeps the initiating button busy behind the dialog.
  await tester.pump(const Duration(milliseconds: 400));
  if (find.byType(Dialog).evaluate().isEmpty) {
    await tester.pumpAndSettle();
  }
}

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('favorites fit width $width and Arabic large text', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      Get.put(ResumeController(repository: _Repository()));
      await tester.pumpWidget(host(scale: 2, arabic: true));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const ValueKey('favorites-scroll')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FavoriteCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'search matches name email and skill and clear restores favorites',
    (tester) async {
      Get.put(ResumeController(repository: _Repository()));
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      for (final query in [' ALICE ', 'example.com', 'dart', 'عمر']) {
        await tester.enterText(find.byType(TextFormField), query);
        await tester.pumpAndSettle();
        expect(
          find.byType(FavoriteCard),
          findsNWidgets(query == 'example.com' ? 2 : 1),
        );
      }
      await tester.enterText(find.byType(TextFormField), 'missing');
      await tester.pumpAndSettle();
      expect(find.text('no_search_results'.tr), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('clear-favorites-search')));
      await tester.pumpAndSettle();
      expect(find.byType(FavoriteCard), findsNWidgets(2));
    },
  );
  testWidgets('editing passes an isolated draft', (tester) async {
    final controller = Get.put(ResumeController(repository: _Repository()));
    ResumeModel? draft;
    await tester.pumpWidget(
      host(capture: (value) => draft = value as ResumeModel),
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('edit-favorite-1')));
    expect(draft!.id, 1);
    draft!.fullName = 'Changed';
    draft!.skills.clear();
    expect(controller.resumes.first.fullName, 'Alice');
    expect(controller.resumes.first.skills, isNotEmpty);
  });
  testWidgets(
    'cancel preserves favorite and confirm persists removal without deleting resume',
    (tester) async {
      final repository = _Repository();
      final controller = Get.put(ResumeController(repository: repository));
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('remove-favorite-1')));
      await tester.tap(find.text('cancel'.tr));
      await tester.pumpAndSettle();
      expect(controller.getFavoriteResumes(), hasLength(2));
      await tapVisible(tester, find.byKey(const ValueKey('remove-favorite-1')));
      await tester.tap(find.byKey(const ValueKey('confirm-remove-favorite')));
      await tester.pumpAndSettle();
      expect(controller.getFavoriteResumes(), hasLength(1));
      expect(controller.resumes, hasLength(3));
      expect(repository.entries.first.isFavorite, isFalse);
      expect(find.byKey(const ValueKey('remove-favorite-1')), findsNothing);
    },
  );
  testWidgets('failed save retains favorite', (tester) async {
    final repository = _Repository()..failSave = true;
    final controller = Get.put(ResumeController(repository: repository));
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('remove-favorite-1')));
    await tester.tap(find.byKey(const ValueKey('confirm-remove-favorite')));
    await tester.pumpAndSettle();
    expect(controller.getFavoriteResumes(), hasLength(2));
    expect(repository.entries.first.isFavorite, isTrue);
  });
  testWidgets('empty favorites creates a new resume', (tester) async {
    final repository = _Repository()..entries.clear();
    Get.put(ResumeController(repository: repository));
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    expect(find.text('favorites_empty_title'.tr), findsOneWidget);
    await tapVisible(tester, find.text('create_resume'.tr));
    expect(find.text('builder-marker'), findsOneWidget);
  });
}
