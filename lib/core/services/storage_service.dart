import '../../data/repositories/resume_repository.dart';

/// Coordinates local storage initialization through the repository.
abstract final class StorageService {
  static Future<ResumeRepository> initialize() => ResumeRepository.initialize();
}
