import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/resume_model.dart';
import 'pdf_service.dart';

/// Image resolution choices; PDF text remains vector content at every quality.
enum PdfExportQuality { compact, standard, high }

/// Export failure exposing a stable translation key to the presentation layer.
class PdfExportException implements Exception {
  const PdfExportException(this.messageKey);
  final String messageKey;
  @override
  String toString() => messageKey;
}

/// Generates complete PDFs and handles native saving, printing and sharing.
class PdfExportService {
  PdfExportService({
    PdfService? pdfService,
    FilePicker? picker,
    Future<bool> Function(Uint8List, String)? print,
    Future<ShareResult> Function(ShareParams)? share,
  }) : _pdf = pdfService ?? PdfService(),
       _picker = picker,
       _print = print,
       _share = share;
  final PdfService _pdf;
  final FilePicker? _picker;
  final Future<bool> Function(Uint8List, String)? _print;
  final Future<ShareResult> Function(ShareParams)? _share;
  bool get pickerWritesBytes => Platform.isAndroid || Platform.isIOS;
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    PdfExportQuality quality = PdfExportQuality.standard,
  }) async {
    try {
      return await _pdf.generate(
        resume.copyWith(),
        locale: locale,
        photoMaxDimension: switch (quality) {
          PdfExportQuality.compact => 96,
          PdfExportQuality.standard => 256,
          PdfExportQuality.high => 768,
        },
      );
    } catch (_) {
      throw const PdfExportException('pdf_generation_failed');
    }
  }

  String fileName(String fullName) {
    var name = fullName.trim().replaceAll(
      RegExp(r'[^a-zA-Z0-9_\u0600-\u06ff-]+'),
      '-',
    );
    if (name.length > 60) name = name.substring(0, 60);
    return 'cv_${name.isEmpty ? 'resume' : name}.pdf';
  }

  void _validate(Uint8List bytes) {
    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw const PdfExportException('pdf_invalid_data');
    }
  }

  Future<String?> savePdf(Uint8List bytes, {required String name}) async {
    Directory? staging;
    try {
      _validate(bytes);
      final path = await (_picker ?? FilePicker.platform).saveFile(
        fileName: name,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        bytes: bytes,
        lockParentWindow: true,
      );
      if (path == null) return null;
      if (!pickerWritesBytes) {
        if (!path.toLowerCase().endsWith('.pdf')) {
          throw const PdfExportException('pdf_extension_required');
        }
        final destination = File(path);
        staging = await destination.parent.createTemp('.cv_pdf_');
        final temporary = File('${staging.path}/resume.pdf');
        await temporary.writeAsBytes(bytes, flush: true);
        await temporary.rename(path);
      }
      return path;
    } on PdfExportException {
      rethrow;
    } catch (_) {
      throw const PdfExportException('pdf_save_failed');
    } finally {
      try {
        if (staging != null && await staging.exists()) {
          final temporary = File('${staging.path}/resume.pdf');
          if (await temporary.exists()) await temporary.delete();
          await staging.delete();
        }
      } catch (_) {
        /* Cleanup must not hide the export result. */
      }
    }
  }

  Future<bool> printPdf(Uint8List bytes, {required String name}) async {
    try {
      _validate(bytes);
      if (_print != null) return await _print(bytes, name);
      return await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: name,
        format: PdfPageFormat.a4,
        dynamicLayout: false,
      );
    } on PdfExportException {
      rethrow;
    } catch (_) {
      throw const PdfExportException('pdf_print_failed');
    }
  }

  Future<ShareResult> sharePdf(
    Uint8List bytes, {
    required String name,
    required Rect origin,
  }) async {
    try {
      _validate(bytes);
      return await (_share ?? SharePlus.instance.share)(
        ShareParams(
          files: [
            XFile.fromData(bytes, mimeType: 'application/pdf', name: name),
          ],
          fileNameOverrides: [name],
          subject: 'CV Maker Pro',
          sharePositionOrigin: origin,
        ),
      );
    } on PdfExportException {
      rethrow;
    } catch (_) {
      throw const PdfExportException('pdf_share_failed');
    }
  }
}
