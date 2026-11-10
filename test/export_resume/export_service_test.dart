import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/core/services/resume_export_service.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';

class _Picker extends FilePicker {
  String? destination;
  Uint8List? received;
  String? proposedName;
  bool fail = false;
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    if (fail) throw Exception('picker failure');
    received = bytes;
    proposedName = fileName;
    expect(type, FileType.custom);
    expect(allowedExtensions, ['json']);
    return destination;
  }
}

class _MobileService extends ResumeExportService {
  _MobileService(FilePicker picker) : super(picker: picker);
  @override
  bool get pickerWritesBytes => true;
}

Matcher _error(String key) => throwsA(
  isA<ExportException>().having((error) => error.messageKey, 'messageKey', key),
);

void main() {
  late Directory directory;
  late _Picker picker;
  late ResumeExportService service;
  final resume = ResumeModel(
    fullName: 'عمر',
    id: 12,
    email: 'omer@example.com',
    phone: '+966500000000',
    profilePicture: '/local/photo.jpg',
    summary: 'ملخص',
    isFavorite: true,
    templateId: 'ats',
    education: [
      Education(degree: 'BSc', institution: 'University', year: '2024'),
    ],
    experience: [
      Experience(
        jobTitle: 'Developer',
        company: 'Company',
        startDate: '01/2024',
      ),
    ],
    skills: [Skill(name: 'Dart')],
    courses: [
      Course.fromJson({'name': 'Course'}),
    ],
    certificates: [
      Certificate.fromJson({'name': 'Certificate'}),
    ],
    languages: [
      Language.fromJson({'name': 'English', 'level': 'Advanced'}),
    ],
    projects: [
      Project.fromJson({'name': 'App'}),
    ],
    achievements: [
      Achievement.fromJson({'title': 'Award'}),
    ],
    interests: ['قراءة'],
    linkedin: 'https://linkedin.com/in/test',
    github: 'https://github.com/test',
    website: 'https://example.com',
    portfolio: 'https://example.com/work',
    customization: {'fontSize': 14, 'primaryColor': 4278190080},
  );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('cv_export_test_');
    picker = _Picker();
    service = ResumeExportService(picker: picker);
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('actual JSON file imports with every field and UTF8 intact', () async {
    picker.destination = '${directory.path}/resume.json';
    final result = await service.saveJson(resume);
    expect(result, picker.destination);
    final bytes = await File(result!).readAsBytes();
    expect(ResumeImportService().fromBytes(bytes, 'json'), resume);
    expect(utf8.decode(bytes), contains('عمر'));
    expect(directory.listSync().whereType<Directory>(), isEmpty);
  });
  test(
    'confirmed destination replaces existing JSON without staging leftovers',
    () async {
      final file = File('${directory.path}/resume.json');
      await file.writeAsString('old data');
      picker.destination = file.path;
      await service.saveJson(resume);
      expect(ResumeJson.decode(await file.readAsString()), resume);
      expect(directory.listSync(), hasLength(1));
    },
  );
  test('picker cancellation writes nothing', () async {
    expect(await service.saveJson(resume), isNull);
    expect(directory.listSync(), isEmpty);
  });
  test(
    'mobile picker receives bytes and content URI is not treated as file path',
    () async {
      picker.destination = 'content://documents/resume';
      final mobile = _MobileService(picker);
      expect(await mobile.saveJson(resume), picker.destination);
      expect(ResumeImportService().fromBytes(picker.received!, 'json'), resume);
    },
  );
  test('picker failure and write failure expose localized errors', () async {
    picker.fail = true;
    await expectLater(
      service.saveJson(resume),
      _error('export_json_save_failed'),
    );
    picker.fail = false;
    final target = await Directory('${directory.path}/occupied.json').create();
    picker.destination = target.path;
    await expectLater(
      service.saveJson(resume),
      _error('export_json_save_failed'),
    );
    expect(await target.exists(), true);
    expect(directory.listSync(), hasLength(1));
  });
  test('desktop export requires JSON extension before writing', () async {
    picker.destination = '${directory.path}/wrong.txt';
    await expectLater(
      service.saveJson(resume),
      _error('export_json_extension'),
    );
    expect(directory.listSync(), isEmpty);
  });
  test(
    'filenames cannot contain paths reserved characters or unbounded names',
    () {
      expect(
        service.fileName(ResumeModel(fullName: '../../CON: / name?')),
        'cv_CON-name.json',
      );
      expect(service.fileName(ResumeModel()), 'cv_resume.json');
      expect(
        service.fileName(ResumeModel(fullName: 'a' * 1000)).length,
        lessThan(80),
      );
      expect(service.fileName(resume), contains('عمر'));
    },
  );
  test(
    'sharing uses actual JSON file bytes filename and iPad origin',
    () async {
      ShareParams? captured;
      final sharer = ResumeExportService(
        share: (params) async {
          captured = params;
          return const ShareResult('ok', ShareResultStatus.success);
        },
      );
      final result = await sharer.shareJson(
        resume,
        origin: const Rect.fromLTWH(10, 10, 100, 48),
      );
      expect(result.status, ShareResultStatus.success);
      expect(captured!.fileNameOverrides, [service.fileName(resume)]);
      expect(captured!.sharePositionOrigin!.width, 100);
      expect(
        ResumeImportService().fromBytes(
          await captured!.files!.single.readAsBytes(),
          'json',
        ),
        resume,
      );
    },
  );
  test('sharing cancellation is preserved and failures are wrapped', () async {
    final cancelled = ResumeExportService(
      share: (_) async => const ShareResult('', ShareResultStatus.dismissed),
    );
    expect(
      (await cancelled.shareJson(resume, origin: Rect.zero)).status,
      ShareResultStatus.dismissed,
    );
    final failed = ResumeExportService(
      share: (_) async => throw Exception('unavailable'),
    );
    await expectLater(
      failed.shareJson(resume, origin: Rect.zero),
      _error('export_json_share_failed'),
    );
  });
  test('oversized and non JSON customization data fail before writing', () {
    expect(
      () => service.toBytes(ResumeModel(summary: 'a' * (10 * 1024 * 1024))),
      _error('export_json_too_large'),
    );
    expect(
      () => service.toBytes(ResumeModel(customization: {'value': double.nan})),
      _error('export_json_invalid'),
    );
  });
}
