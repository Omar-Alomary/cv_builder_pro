import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/core/constants/storage_keys.dart';

class _MemoryStorage implements GetStorage {
  final data = <String, dynamic>{};
  final disk = <String, dynamic>{};
  bool failNextFlush = false;
  @override
  GetQueue queue = GetQueue();

  void _scheduleFlush() {
    scheduleMicrotask(() {
      queue.add<void>(() async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        if (failNextFlush) {
          failNextFlush = false;
          throw StateError('Simulated disk failure');
        }
        disk
          ..clear()
          ..addAll(data);
      });
    });
  }

  @override
  T? read<T>(String key) => data[key] as T?;
  @override
  void writeInMemory(String key, dynamic value) => data[key] = value;
  @override
  Future<void> write(String key, dynamic value) async {
    data[key] = value;
    _scheduleFlush();
  }

  @override
  Future<void> remove(String key) async {
    data.remove(key);
    _scheduleFlush();
  }

  @override
  Future<void> erase() async {
    data.clear();
    _scheduleFlush();
  }

  @override
  T getKeys<T>() => data.keys as T;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MemoryStorage storage;
  late ResumeRepository repository;
  setUp(() {
    storage = _MemoryStorage();
    repository = ResumeRepository(storage: storage);
  });

  test('The installed GetStorage flushes resume JSON to a real file', () async {
    final name = 'cv_repository_${DateTime.now().microsecondsSinceEpoch}';
    final directory = await Directory(
      '.dart_tool/storage_repository_tests',
    ).create(recursive: true);
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => directory.absolute.path,
    );
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final box = GetStorage(name, directory.absolute.path);
    await box.initStorage;
    final realRepository = ResumeRepository(storage: box);
    final saved = await realRepository.saveResume(
      ResumeModel(fullName: 'اختبار'),
    );
    final contents = await File('${directory.path}/$name.gs').readAsString();
    final json = jsonDecode(contents) as Map<String, dynamic>;
    final rows = json[StorageKeys.resumes] as List;
    expect(rows.single['fullName'], 'اختبار');
    expect(rows.single['id'], saved.id);
  });

  test(
    'Create, update and delete preserve IDs and wait for the scheduled flush',
    () async {
      final saved = await repository.saveResume(ResumeModel(fullName: 'عمر'));
      expect(saved.id, isNotNull);
      expect(saved.updatedAt, isNotNull);
      expect((storage.disk[StorageKeys.resumes] as List), hasLength(1));
      final updated = await repository.saveResume(
        saved.copyWith(summary: 'Updated', isFavorite: true),
      );
      expect(updated.id, saved.id);
      expect(repository.loadResumes(), [updated]);
      await repository.deleteResume(saved.id!);
      expect(repository.loadResumes(), isEmpty);
      expect(storage.disk[StorageKeys.resumes], isEmpty);
    },
  );

  test('Concurrent saves keep both resumes and assign distinct IDs', () async {
    final saved = await Future.wait([
      repository.saveResume(ResumeModel(fullName: 'One')),
      repository.saveResume(ResumeModel(fullName: 'Two')),
    ]);
    expect(saved[0].id, isNot(saved[1].id));
    expect(repository.loadResumes(), hasLength(2));
  });

  test('Existing storage schema loads without migration loss', () {
    storage.data[StorageKeys.resumes] = [
      {
        'id': 123,
        'fullName': 'Existing',
        'email': '',
        'phone': '',
        'education': [],
        'experience': [],
        'skills': [],
        'templateId': 'ats',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'isFavorite': true,
      },
    ];
    final saved = repository.loadResumes().single;
    expect(saved.id, 123);
    expect(saved.isFavorite, true);
    expect(saved.templateId, 'ats');
  });

  test('Reads return isolated JSON snapshots', () async {
    await repository.write('customization', {
      'nested': ['blue'],
    });
    final copy = repository.read<Map<String, dynamic>>('customization')!;
    (copy['nested'] as List).add('red');
    expect(repository.read<Map<String, dynamic>>('customization')!['nested'], [
      'blue',
    ]);
  });

  test(
    'A failed flush reports failure, restores memory and allows retry',
    () async {
      await repository.write(StorageKeys.appLocale, 'en');
      storage.failNextFlush = true;
      await expectLater(
        repository.write(StorageKeys.appLocale, 'ar'),
        throwsA(isA<StorageException>()),
      );
      expect(repository.read<String>(StorageKeys.appLocale), 'en');
      expect(storage.disk[StorageKeys.appLocale], 'en');
      await repository.write(StorageKeys.appLocale, 'ar');
      expect(storage.disk[StorageKeys.appLocale], 'ar');
    },
  );

  test(
    'Failed clear restores data and successful clear removes all settings',
    () async {
      await repository.write(StorageKeys.appLocale, 'ar');
      storage.failNextFlush = true;
      await expectLater(
        repository.clearAllData(),
        throwsA(isA<StorageException>()),
      );
      expect(repository.read<String>(StorageKeys.appLocale), 'ar');
      await repository.clearAllData();
      expect(storage.disk, isEmpty);
      expect(repository.loadResumes(), isEmpty);
    },
  );

  test('Corrupt saved data is reported without being overwritten', () {
    storage.data[StorageKeys.resumes] = ['invalid'];
    expect(repository.loadResumes, throwsA(isA<StorageException>()));
    expect(storage.data[StorageKeys.resumes], ['invalid']);
  });
}
