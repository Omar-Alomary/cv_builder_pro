import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../../../core/services/pdf_unicode_map.dart';

final _repairedFonts = Expando<bool>();

void _repairArabicGlyphs(pw.Context context, pw.Font font) {
  final native = font.getFont(context);
  if (native is! PdfTtfFont || _repairedFonts[native] == true) return;
  final map = native.font.charToGlyphIndexMap;
  for (var code = 0xfb50; code <= 0xfeff; code++) {
    if ((map[code] ?? 0) > 0) continue;
    final basic = normalizePdfArabic(String.fromCharCode(code)).runes.toList();
    if (basic.length == 1 && (map[basic.single] ?? 0) > 0) {
      map[code] = map[basic.single]!;
    }
  }
  _repairedFonts[native] = true;
}

/// Keeps Latin punctuation with its LTR run inside an Arabic PDF paragraph.
pw.Widget pdfDirectionalText(
  String value, {
  required pw.TextStyle style,
  required pw.TextDirection direction,
  pw.TextAlign? align,
}) {
  return pw.Builder(
    builder: (context) {
      if (style.font != null) _repairArabicGlyphs(context, style.font!);
      for (final fallback in style.fontFallback) {
        _repairArabicGlyphs(context, fallback);
      }
      return _directionalText(
        value,
        style: style,
        direction: direction,
        align: align,
      );
    },
  );
}

pw.Widget _directionalText(
  String value, {
  required pw.TextStyle style,
  required pw.TextDirection direction,
  pw.TextAlign? align,
}) {
  if (direction != pw.TextDirection.rtl ||
      !RegExp(r'[A-Za-z]').hasMatch(value) ||
      !RegExp(r'[\u0600-\u06ff]').hasMatch(value)) {
    return pw.Text(
      value,
      style: style,
      textDirection: direction,
      textAlign: align,
    );
  }
  return pw.Builder(
    builder: (context) {
      final children = <pw.InlineSpan>[];
      var cursor = 0;
      for (final run in RegExp(
        r'[A-Za-z][A-Za-z0-9 .,()%/+&:|\-]*',
      ).allMatches(value)) {
        // Separators belong to the surrounding RTL text, not the LTR run.
        final latin = run.group(0)!.replaceFirst(RegExp(r'[ |]+$'), '');
        if (run.start > cursor) {
          children.add(pw.TextSpan(text: value.substring(cursor, run.start)));
        }
        children.add(
          pw.WidgetSpan(
            baseline:
                style.font!.getFont(context).stringMetrics(latin).descent *
                style.fontSize!,
            child: pw.SizedBox(
              width:
                  style.font!
                          .getFont(context)
                          .stringMetrics(latin)
                          .advanceWidth *
                      style.fontSize! +
                  .1,
              child: pw.Text(
                latin,
                style: style.copyWith(lineSpacing: 0),
                textDirection: pw.TextDirection.ltr,
              ),
            ),
          ),
        );
        cursor = run.start + latin.length;
      }
      if (cursor < value.length) {
        children.add(pw.TextSpan(text: value.substring(cursor)));
      }
      return pw.RichText(
        text: pw.TextSpan(style: style, children: children),
        textDirection: direction,
        textAlign: align,
      );
    },
  );
}
