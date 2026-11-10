import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/index.dart';
import '../constants/app_constants.dart';

/// Export failure with a stable, localized feedback key.
class ExportException implements Exception {
  const ExportException(this.messageKey);
  final String messageKey;
  @override
  String toString() => messageKey;
}

/// Saves and shares complete UTF-8 resume JSON compatible with the importer.
class ResumeExportService {
  ResumeExportService({
    FilePicker? picker,
    Future<ShareResult> Function(ShareParams)? share,
  }) : _picker = picker,
       _share = share;
  final FilePicker? _picker;
  final Future<ShareResult> Function(ShareParams)? _share;

  /// Mobile pickers write supplied bytes; desktop pickers return a destination.
  bool get pickerWritesBytes => Platform.isAndroid || Platform.isIOS;

  String fileName(ResumeModel resume) {
    var name = resume.fullName
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\u0600-\u06ff-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (name.length > 60) name = name.substring(0, 60);
    return 'cv_${name.isEmpty ? 'resume' : name}.json';
  }

  Uint8List toBytes(ResumeModel resume) {
    try {
      final bytes = Uint8List.fromList(utf8.encode(ResumeJson.encode(resume)));
      if (bytes.length > AppConstants.maxImportBytes) {
        throw const ExportException('export_json_too_large');
      }
      return bytes;
    } on ExportException {
      rethrow;
    } catch (_) {
      throw const ExportException('export_json_invalid');
    }
  }

  Future<String?> saveJson(ResumeModel resume) async {
    try {
      final bytes = toBytes(resume);
      final destination = await (_picker ?? FilePicker.platform).saveFile(
        fileName: fileName(resume),
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
        lockParentWindow: true,
      );
      if (destination == null) return null;
      if (!pickerWritesBytes) {
        if (!destination.toLowerCase().endsWith('.json')) {
          throw const ExportException('export_json_extension');
        }
        await _writeAtomically(File(destination), bytes);
      }
      return destination;
    } on ExportException {
      rethrow;
    } catch (_) {
      throw const ExportException('export_json_save_failed');
    }
  }

  Future<void> _writeAtomically(File destination, Uint8List bytes) async {
    Directory? staging;
    File? temporary;
    try {
      staging = await destination.parent.createTemp('.cv_export_');
      temporary = File('${staging.path}/resume.json');
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(destination.path);
    } catch (_) {
      throw const ExportException('export_json_save_failed');
    } finally {
      try {
        if (temporary != null && await temporary.exists()) {
          await temporary.delete();
        }
        if (staging != null && await staging.exists()) await staging.delete();
      } catch (_) {
        /* A cleanup failure must not misreport a completed export. */
      }
    }
  }

  Future<ShareResult> shareJson(
    ResumeModel resume, {
    required Rect origin,
  }) async {
    try {
      final bytes = toBytes(resume);
      final name = fileName(resume);
      final params = ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'application/json', name: name),
        ],
        fileNameOverrides: [name],
        subject: 'CV Maker Pro',
        sharePositionOrigin: origin,
      );
      return await (_share ?? SharePlus.instance.share)(params);
    } on ExportException {
      rethrow;
    } catch (_) {
      throw const ExportException('export_json_share_failed');
    }
  }
}
