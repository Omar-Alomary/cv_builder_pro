import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/models/resume_model.dart';

class _Pdf extends PdfService {
  int? dimension;
  bool fail = false;
  @override
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    int? photoMaxDimension,
  }) async {
    dimension = photoMaxDimension;
    if (fail) throw StateError('failed');
    return Uint8List.fromList('%PDF-test'.codeUnits);
  }
}

class _Picker extends FilePicker {
  String? destination;
  bool fail = false;
  Uint8List? bytesReceived;
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
    if (fail) throw StateError('picker failure');
    expect(allowedExtensions, ['pdf']);
    bytesReceived = bytes;
    return destination;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final bytes = Uint8List.fromList('%PDF-test'.codeUnits);
  test(
    'quality selects actual photo resolution and generation errors are localized',
    () async {
      final pdf = _Pdf();
      final service = PdfExportService(pdfService: pdf);
      for (final entry in {
        PdfExportQuality.compact: 96,
        PdfExportQuality.standard: 256,
        PdfExportQuality.high: 768,
      }.entries) {
        await service.generate(ResumeModel(), quality: entry.key);
        expect(pdf.dimension, entry.value);
      }
      pdf.fail = true;
      await expectLater(
        service.generate(ResumeModel()),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_generation_failed',
          ),
        ),
      );
    },
  );
  test(
    'PDF saving writes exact bytes atomically and cancellation leaves existing file intact',
    () async {
      final directory = await Directory.systemTemp.createTemp('cv-pdf-save-');
      try {
        final picker = _Picker();
        final service = PdfExportService(picker: picker);
        final file = File('${directory.path}/resume.pdf');
        await file.writeAsString('old');
        expect(await service.savePdf(bytes, name: 'resume.pdf'), isNull);
        expect(await file.readAsString(), 'old');
        picker.destination = file.path;
        expect(await service.savePdf(bytes, name: 'resume.pdf'), file.path);
        expect(await file.readAsBytes(), bytes);
        expect(picker.bytesReceived, bytes);
        expect(await directory.list().length, 1);
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
  test(
    'invalid file extension and picker failure report useful errors',
    () async {
      final picker = _Picker()..destination = 'resume.txt';
      final service = PdfExportService(picker: picker);
      await expectLater(
        service.savePdf(bytes, name: 'resume.pdf'),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_extension_required',
          ),
        ),
      );
      picker.fail = true;
      await expectLater(
        service.savePdf(bytes, name: 'resume.pdf'),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_save_failed',
          ),
        ),
      );
    },
  );
  test(
    'printing preserves native cancellation and reports platform failures',
    () async {
      expect(
        await PdfExportService(
          print: (data, name) async {
            expect(data, bytes);
            return false;
          },
        ).printPdf(bytes, name: 'cv.pdf'),
        isFalse,
      );
      await expectLater(
        PdfExportService(
          print: (_, _) async => throw StateError('no printer'),
        ).printPdf(bytes, name: 'cv.pdf'),
        throwsA(
          isA<PdfExportException>().having(
            (e) => e.messageKey,
            'key',
            'pdf_print_failed',
          ),
        ),
      );
    },
  );
  test('sharing forwards PDF bytes, name, anchor and cancellation', () async {
    final service = PdfExportService(
      share: (params) async {
        expect(params.fileNameOverrides, ['cv.pdf']);
        expect(
          params.sharePositionOrigin,
          const ui.Rect.fromLTWH(1, 2, 30, 40),
        );
        expect(params.files!.single.mimeType, 'application/pdf');
        expect(await params.files!.single.readAsBytes(), bytes);
        return const ShareResult('', ShareResultStatus.dismissed);
      },
    );
    expect(
      (await service.sharePdf(
        bytes,
        name: 'cv.pdf',
        origin: const ui.Rect.fromLTWH(1, 2, 30, 40),
      )).status,
      ShareResultStatus.dismissed,
    );
  });
  test('invalid PDF never reaches native print or save', () async {
    var printed = false;
    final service = PdfExportService(
      print: (_, _) async {
        printed = true;
        return true;
      },
    );
    await expectLater(
      service.printPdf(Uint8List(0), name: 'bad.pdf'),
      throwsA(isA<PdfExportException>()),
    );
    expect(printed, isFalse);
  });
  test(
    'real quality resizing keeps PDF text and changes embedded photo dimensions',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'cv-pdf-quality-',
      );
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      canvas.drawRect(
        const ui.Rect.fromLTWH(0, 0, 1000, 500),
        ui.Paint()..color = const ui.Color(0xff1565c0),
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(1000, 500);
      try {
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('${directory.path}/photo.png');
        await file.writeAsBytes(data!.buffer.asUint8List());
        final resume = ResumeModel(
          fullName: 'Photo quality',
          profilePicture: file.path,
        );
        for (final entry in {
          PdfExportQuality.compact: 96,
          PdfExportQuality.standard: 256,
          PdfExportQuality.high: 768,
        }.entries) {
          final pdf = await PdfExportService().generate(
            resume,
            quality: entry.key,
          );
          final source = String.fromCharCodes(pdf);
          expect(
            RegExp('/Width\\s+${entry.value}\\b').hasMatch(source),
            isTrue,
          );
          expect(source, contains('/FontFile2'));
        }
      } finally {
        image.dispose();
        picture.dispose();
        await directory.delete(recursive: true);
      }
    },
  );
}
