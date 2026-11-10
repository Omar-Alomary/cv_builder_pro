import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/storage_keys.dart';
import '../models/resume_model.dart';

/// A storage failure with a message suitable for presentation by the caller.
class StorageException implements Exception {
  final String operation;
  final Object cause;
  const StorageException(this.operation, this.cause);
  @override
  String toString() => 'StorageException: Unable to $operation';
}

/// The only gateway to GetStorage, retaining the existing storage keys.
class ResumeRepository {
  final GetStorage _storage;
  late final _StorageQueue _queue;
  Future<void> _pending = Future<void>.value();

  ResumeRepository({GetStorage? storage}) : _storage = storage ?? GetStorage() {
    _queue = _storage.queue is _StorageQueue
        ? _storage.queue as _StorageQueue
        : _StorageQueue();
    _storage.queue = _queue;
  }

  static Future<ResumeRepository> initialize({String? container}) async {
    try {
      final initialized = container == null
          ? await GetStorage.init()
          : await GetStorage.init(container);
      if (!initialized) throw StateError('Storage initialization failed');
      return ResumeRepository(
        storage: container == null ? null : GetStorage(container),
      );
    } catch (error) {
      throw StorageException('initialize local storage', error);
    }
  }

  T? read<T>(String key) {
    try {
      final value = _storage.read<dynamic>(key);
      return value == null ? null : jsonDecode(jsonEncode(value)) as T;
    } catch (error) {
      throw StorageException('read $key', error);
    }
  }

  Future<T> _enqueue<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<void> write(String key, Object? value) => _enqueue(() async {
    try {
      final snapshot = jsonDecode(jsonEncode(value));
      await _persist(key, snapshot);
    } catch (error) {
      throw StorageException('save $key', error);
    }
  });

  Future<void> remove(String key) => _enqueue(() async {
    Object? previous;
    try {
      previous = _storage.read<dynamic>(key);
      await _storage.remove(key);
      await _queue.waitForFlush();
    } catch (error) {
      _storage.writeInMemory(key, previous);
      throw StorageException('remove $key', error);
    }
  });

  List<ResumeModel> loadResumes() {
    try {
      final rows = read<List<dynamic>>(StorageKeys.resumes) ?? [];
      return rows.map((row) {
        if (row is! Map) throw const FormatException('Invalid saved resume');
        return ResumeModel.fromJson(Map<String, dynamic>.from(row));
      }).toList();
    } catch (error) {
      throw StorageException('load saved resumes', error);
    }
  }

  Future<ResumeModel> saveResume(ResumeModel resume) {
    final snapshot = resume.copyWith();
    return _enqueue(() async {
      try {
        final resumes = loadResumes();
        var id = snapshot.id;
        if (id == null) {
          id = DateTime.now().microsecondsSinceEpoch;
          while (resumes.any((entry) => entry.id == id)) {
            id = id! + 1;
          }
        }
        final saved = snapshot.copyWith(id: id, updatedAt: DateTime.now());
        final index = resumes.indexWhere((entry) => entry.id == id);
        if (index < 0) {
          resumes.add(saved);
        } else {
          resumes[index] = saved;
        }
        await _persist(
          StorageKeys.resumes,
          resumes.map((entry) => entry.toJson()).toList(),
        );
        return saved;
      } catch (error) {
        throw StorageException('save resume', error);
      }
    });
  }

  Future<void> deleteResume(int id) => _enqueue(() async {
    try {
      final resumes = loadResumes()..removeWhere((entry) => entry.id == id);
      await _persist(
        StorageKeys.resumes,
        resumes.map((entry) => entry.toJson()).toList(),
      );
    } catch (error) {
      throw StorageException('delete resume', error);
    }
  });

  Future<void> clearAllData() => _enqueue(() async {
    final previous = <String, dynamic>{};
    try {
      for (final key in _storage.getKeys<Iterable>().cast<String>()) {
        previous[key] = _storage.read<dynamic>(key);
      }
      await _storage.erase();
      await _queue.waitForFlush();
    } catch (error) {
      previous.forEach(_storage.writeInMemory);
      throw StorageException('clear application data', error);
    }
  });

  Future<void> _persist(String key, Object? value) async {
    final previous = _storage.read<dynamic>(key);
    try {
      await _storage.write(key, value);
      await _queue.waitForFlush();
    } catch (_) {
      _storage.writeInMemory(key, previous);
      rethrow;
    }
  }
}

// GetStorage schedules its flush without returning the flush future. Observe
// the queue so completion and disk failures reach the awaiting caller.
class _StorageQueue extends GetQueue {
  Future<void> _last = Future<void>.value();
  Object? _error;

  @override
  Future<T> add<T>(Function job) {
    // The bundled GetQueue catches Exception but lets Error escape. Keep a
    // future chain here so both kinds of failures reach the repository.
    final result = _last.then<T>((_) async => await job() as T);
    _last = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace _) {
        _error = error;
      },
    );
    return result;
  }

  Future<void> waitForFlush() async {
    await _last;
    final error = _error;
    _error = null;
    if (error != null) throw error;
  }
}
