import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../data/index.dart';
import '../constants/app_constants.dart';
import 'simple_pdf_text_extractor.dart';
import 'resume_text_parser.dart';

/// A localized import failure with a stable translation key.
class ImportException implements Exception {
  const ImportException(this.messageKey);
  final String messageKey;
  @override
  String toString() => messageKey;
}

/// Imports portable JSON and conservatively extracts plain resume text.
class ResumeImportService {
  Future<ResumeModel?> pickAndImport(String extension) async {
    try {
      if (!['json', 'pdf', 'txt'].contains(extension)) {
        throw const ImportException('import_unsupported');
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [extension],
        allowMultiple: false,
        withData: false,
        withReadStream: true,
      );
      if (result == null) return null;
      final file = result.files.single;
      if (file.size > AppConstants.maxImportBytes) {
        throw const ImportException('import_too_large');
      }
      if (file.extension?.toLowerCase() != extension) {
        throw const ImportException('import_extension_mismatch');
      }
      final builder = BytesBuilder(copy: false);
      if (file.bytes != null) {
        builder.add(file.bytes!);
      } else if (file.readStream != null) {
        await for (final chunk in file.readStream!) {
          if (builder.length + chunk.length > AppConstants.maxImportBytes) {
            throw const ImportException('import_too_large');
          }
          builder.add(chunk);
        }
      } else if (file.path != null) {
        final source = File(file.path!);
        if (await source.length() > AppConstants.maxImportBytes) {
          throw const ImportException('import_too_large');
        }
        await for (final chunk in source.openRead()) {
          if (builder.length + chunk.length > AppConstants.maxImportBytes) {
            throw const ImportException('import_too_large');
          }
          builder.add(chunk);
        }
      } else {
        throw const ImportException('import_read_failed');
      }
      return await compute(_decodeFile, (builder.takeBytes(), extension));
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException('import_read_failed');
    }
  }

  ResumeModel fromJsonText(String source) {
    try {
      if (utf8.encode(source).length > AppConstants.maxImportBytes) {
        throw const ImportException('import_too_large');
      }
      return ResumeJson.decode(source);
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException('import_invalid_json');
    }
  }

  ResumeModel fromBytes(Uint8List bytes, String extension) {
    try {
      if (bytes.isEmpty) throw const ImportException('import_empty');
      if (bytes.length > AppConstants.maxImportBytes) {
        throw const ImportException('import_too_large');
      }
      switch (extension.toLowerCase()) {
        case 'json':
          return fromJsonText(_decodeText(bytes));
        case 'txt':
          return fromPlainText(_decodeText(bytes));
        case 'pdf':
          return fromPlainText(SimplePdfTextExtractor.extract(bytes));
        default:
          throw const ImportException('import_unsupported');
      }
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException('import_read_failed');
    }
  }

  String _decodeText(Uint8List bytes) {
    if (bytes.length >= 2 &&
        ((bytes[0] == 255 && bytes[1] == 254) ||
            (bytes[0] == 254 && bytes[1] == 255))) {
      if (bytes.length.isOdd) {
        throw const ImportException('import_text_encoding');
      }
      final data = ByteData.sublistView(bytes);
      return String.fromCharCodes([
        for (var i = 2; i < bytes.length; i += 2)
          data.getUint16(i, bytes[0] == 255 ? Endian.little : Endian.big),
      ]);
    }
    try {
      return utf8.decode(bytes).replaceFirst('\uFEFF', '');
    } catch (_) {
      throw const ImportException('import_text_encoding');
    }
  }

  ResumeModel fromPlainText(String source) {
    if (utf8.encode(source).length > AppConstants.maxImportBytes) {
      throw const ImportException('import_too_large');
    }
    if (source.trim().isEmpty) throw const ImportException('import_empty');
    return ResumeTextParser.parse(source);
  }
}

ResumeModel _decodeFile((Uint8List, String) payload) =>
    ResumeImportService().fromBytes(payload.$1, payload.$2);
