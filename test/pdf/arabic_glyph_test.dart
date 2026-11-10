import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cv_builder_pro/features/resume_builder/presentation/templates/pdf_directional_text.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final path in [
    'assets/fonts/Cairo-Regular.ttf',
    'assets/fonts/Cairo-Bold.ttf',
  ]) {
    test(
      'Arabic name with diacritics emits a real isolated yeh glyph: $path',
      () async {
        final font = pw.Font.ttf(await rootBundle.load(path));
        final document = pw.Document();
        PdfTtfFont? native;
        document.addPage(
          pw.Page(
            build: (context) {
              native = font.getFont(context) as PdfTtfFont;
              return pdfDirectionalText(
                'أحمد محمد العُمري',
                style: pw.TextStyle(font: font, fontSize: 28),
                direction: pw.TextDirection.rtl,
              );
            },
          ),
        );
        final bytes = await document.save();
        expect(native!.font.charToGlyphIndexMap[0xfef1], greaterThan(0));
        expect(native!.font.charToGlyphIndexMap[0x064f], greaterThan(0));
        if (path.contains('Bold')) {
          await File('tmp/device_matrix/glyph_fix.pdf').writeAsBytes(bytes);
        }
      },
    );
  }
}
