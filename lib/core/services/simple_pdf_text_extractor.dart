import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'resume_import_service.dart';
import 'pdf_unicode_map.dart';

/// Extracts selectable PDF text through embedded Unicode character maps.
abstract final class SimplePdfTextExtractor {
  static String extract(Uint8List bytes) =>
      _PdfReader(latin1.decode(bytes)).read();
}

class _PdfReader {
  _PdfReader(this.source);
  final String source;
  final objects = <int, String>{}, streams = <int, String>{};
  int expanded = 0;
  String? stream(String body) {
    final m = RegExp(r'\bstream\r?\n').firstMatch(body);
    if (m == null) return null;
    final end = body.lastIndexOf('endstream');
    if (end < m.end) throw const ImportException('import_invalid_pdf');
    final dictionary = body.substring(0, m.start);
    if (RegExp(r'/Subtype\s*/Image\b').hasMatch(dictionary)) return null;
    final count = int.tryParse(
      RegExp(
            r'/Length\s+(\d+)(?!\d|\s+\d+\s+R)',
          ).firstMatch(dictionary)?.group(1) ??
          '',
    );
    var data = latin1.encode(
      body.substring(
        m.end,
        count != null && m.end + count <= end ? m.end + count : end,
      ),
    );
    if (dictionary.contains('/Filter')) {
      if (!RegExp(
        r'/Filter\s*(?:/FlateDecode\b|\[\s*/FlateDecode\s*\])',
      ).hasMatch(dictionary)) {
        return null;
      }
      final sink = _BoundedSink(20 * 1024 * 1024 - expanded);
      try {
        final decoder = ZLibDecoder().startChunkedConversion(sink);
        decoder.add(data);
        decoder.close();
        data = sink.bytes.takeBytes();
      } on ImportException {
        rethrow;
      } catch (_) {
        throw const ImportException('import_invalid_pdf');
      }
    }
    expanded += data.length;
    if (expanded > 20 * 1024 * 1024) {
      throw const ImportException('import_too_large');
    }
    return latin1.decode(data);
  }

  Map<String, int> refs(String value) => {
    for (final m in RegExp(
      r'/([^\s/<>\[\]()]+)\s+(\d+)\s+\d+\s+R',
    ).allMatches(value))
      m.group(1)!: int.parse(m.group(2)!),
  };
  String read() {
    if (!source.startsWith('%PDF-')) {
      throw const ImportException('import_invalid_pdf');
    }
    if (RegExp(r'/Encrypt\b').hasMatch(source)) {
      throw const ImportException('import_pdf_encrypted');
    }
    for (final m in RegExp(
      r'(\d+)\s+\d+\s+obj\b([\s\S]*?)endobj',
    ).allMatches(source)) {
      objects[int.parse(m.group(1)!)] = m.group(2)!;
    }
    for (final e in objects.entries.toList()) {
      final value = stream(e.value);
      if (value != null) streams[e.key] = value;
    }
    for (final e in objects.entries.toList()) {
      if (!RegExp(r'/Type\s*/ObjStm\b').hasMatch(e.value)) continue;
      final data = streams[e.key];
      final first = int.tryParse(
        RegExp(r'/First\s+(\d+)').firstMatch(e.value)?.group(1) ?? '',
      );
      final n = int.tryParse(
        RegExp(r'/N\s+(\d+)').firstMatch(e.value)?.group(1) ?? '',
      );
      if (data == null ||
          first == null ||
          n == null ||
          first > data.length ||
          n > 100000) {
        throw const ImportException('import_invalid_pdf');
      }
      final header = RegExp(r'\d+')
          .allMatches(data.substring(0, first))
          .map((m) => int.parse(m.group(0)!))
          .toList();
      if (header.length < n * 2) {
        throw const ImportException('import_invalid_pdf');
      }
      for (var i = 0; i < n; i++) {
        final start = first + header[i * 2 + 1],
            end = i + 1 == n ? data.length : first + header[(i + 1) * 2 + 1];
        if (start < first || end < start || end > data.length) {
          throw const ImportException('import_invalid_pdf');
        }
        objects[header[i * 2]] = data.substring(start, end);
      }
    }
    final fonts = <int, _Font>{};
    for (final e in objects.entries) {
      if (!RegExp(
        r'/Type\s*/Font\b|/Subtype\s*/(?:Type0|Type1|TrueType)\b',
      ).hasMatch(e.value)) {
        continue;
      }
      fonts[e.key] = _Font(e.value, streams[refs(e.value)['ToUnicode']]);
    }
    Map<String, _Font> aliases(String resources) {
      final dictionary = objects[refs(resources)['Font']] ?? resources;
      return {
        for (final e in refs(dictionary).entries)
          if (fonts.containsKey(e.value)) e.key: fonts[e.value]!,
      };
    }

    final all = <String, _Font>{};
    for (final value in objects.values) {
      all.addAll(aliases(value));
    }
    final out = StringBuffer(), visited = <int>{};
    for (final page in objects.values.where(
      (s) => RegExp(r'/Type\s*/Page\b').hasMatch(s),
    )) {
      var resources = page;
      for (var i = 0; i < 12; i++) {
        final r = refs(resources);
        if (r['Resources'] != null) {
          resources = objects[r['Resources']] ?? resources;
          break;
        }
        if (resources.contains('/Resources') || r['Parent'] == null) break;
        resources = objects[r['Parent']] ?? '';
      }
      final local = {...all, ...aliases(resources)};
      final content =
          RegExp(
            r'/Contents\s*(\[[\s\S]*?\]|\d+\s+\d+\s+R)',
          ).firstMatch(page)?.group(1) ??
          '';
      for (final ref in RegExp(r'(\d+)\s+\d+\s+R').allMatches(content)) {
        final id = int.parse(ref.group(1)!);
        if (streams[id] != null && visited.add(id)) {
          out.write(text(streams[id]!, local));
        }
      }
    }
    if (visited.isEmpty) {
      for (final value in streams.values) {
        if (value.contains('BT')) out.write(text(value, all));
      }
    }
    final result = normalizePdfArabic(out.toString()).trim();
    if (result.isEmpty) throw const ImportException('import_pdf_no_text');
    return result;
  }

  String text(String content, Map<String, _Font> fonts) {
    final out = StringBuffer(), operands = <Object>[];
    final pieces = <({double x, double y, String value, int order})>[];
    var matrix = <double>[1, 0, 0, 1, 0, 0];
    final stack = <List<double>>[];
    double x = 0, y = 0;
    double leading = 14;
    var positioned = false;
    var font = _Font('', null), active = false;
    final run = <String>[];
    final logicalClusters = <int, String>{};
    final marked = <({bool reversed, String? actual, int start, bool used})>[];
    double? runX, runY;
    void flush() {
      if (run.isEmpty) return;
      final value = String.fromCharCodes(
        run.join().runes.expand((r) => logicalClusters[r]?.runes ?? [r]),
      );
      if (value.trim().isNotEmpty) {
        if (!positioned) {
          out.writeln(value);
        } else {
          pieces.add((
            x: runX ?? x,
            y: runY ?? y,
            value: value.trim(),
            order: pieces.length,
          ));
        }
      }
      run.clear();
      runX = null;
      runY = null;
    }

    void show(Object value) {
      final buffer = StringBuffer();
      if (value is _PdfString) buffer.write(font.decode(value.bytes));
      if (value is List<Object>) {
        for (final item in value) {
          if (item is num && item < -180) {
            buffer.write(' ');
          } else if (item is _PdfString) {
            buffer.write(font.decode(item.bytes));
          }
        }
      }
      var decoded = buffer.toString();
      var logicalCluster =
          value is _PdfString && font.widths.contains(value.bytes.length);
      final actualIndex = marked.lastIndexWhere((m) => m.actual != null);
      if (actualIndex >= 0) {
        final m = marked[actualIndex];
        if (m.used) return;
        decoded = m.actual!;
        logicalCluster = true;
        marked[actualIndex] = (
          reversed: m.reversed,
          actual: m.actual,
          start: m.start,
          used: true,
        );
      } else if (!logicalCluster &&
          RegExp(r'[\ufb50-\ufdff\ufe70-\ufeff]').hasMatch(decoded)) {
        decoded = decoded.replaceAllMapped(
          RegExp(r'[\u0600-\u06ff\ufb50-\ufdff\ufe70-\ufeff]+'),
          (m) => String.fromCharCodes(m.group(0)!.runes.toList().reversed),
        );
      }
      decoded = normalizePdfArabic(decoded);
      if (logicalCluster &&
          decoded.runes.length > 1 &&
          marked.any((m) => m.reversed)) {
        final code = 0xe000 + logicalClusters.length;
        if (code >= 0xf800) throw const ImportException('import_too_large');
        logicalClusters[code] = decoded;
        decoded = String.fromCharCode(code);
      }
      if (decoded.isEmpty) return;
      if (!positioned) {
        if (decoded.trim().isNotEmpty) out.writeln(decoded.trim());
        return;
      }
      runX ??= matrix[0] * x + matrix[2] * y + matrix[4];
      runY ??= matrix[1] * x + matrix[3] * y + matrix[5];
      run.add(decoded);
    }

    for (final token in _tokens(content)) {
      if (token is! String || token.startsWith('/')) {
        operands.add(token);
        continue;
      }
      if (token == '<<' || token == '>>') continue;
      switch (token) {
        case 'BDC':
        case 'BMC':
          final actualIndex = operands.indexOf('/ActualText');
          String? actual;
          if (actualIndex >= 0 &&
              actualIndex + 1 < operands.length &&
              operands[actualIndex + 1] is _PdfString) {
            final data = (operands[actualIndex + 1] as _PdfString).bytes;
            if (data.length >= 2 && data[0] == 254 && data[1] == 255) {
              actual = String.fromCharCodes([
                for (var i = 2; i + 1 < data.length; i += 2)
                  (data[i] << 8) | data[i + 1],
              ]);
            } else {
              actual = latin1.decode(data);
            }
          }
          marked.add((
            reversed: operands.contains('/ReversedChars'),
            actual: actual,
            start: run.length,
            used: false,
          ));
        case 'EMC':
          if (marked.isNotEmpty) {
            final m = marked.removeLast();
            if (m.reversed && m.start < run.length) {
              final value = run.sublist(m.start).join();
              final clusters = RegExp(
                r'[^\u064b-\u065f\u0670][\u064b-\u065f\u0670]*',
              ).allMatches(value).map((m) => m.group(0)!).toList();
              run.removeRange(m.start, run.length);
              run.add(clusters.reversed.join());
            }
          }
        case 'q':
          stack.add(List<double>.of(matrix));
        case 'Q':
          if (stack.isNotEmpty) matrix = stack.removeLast();
        case 'cm':
          if (operands.length >= 6 && operands.take(6).every((n) => n is num)) {
            final b = operands
                    .take(6)
                    .cast<num>()
                    .map((n) => n.toDouble())
                    .toList(),
                a = matrix;
            matrix = [
              a[0] * b[0] + a[2] * b[1],
              a[1] * b[0] + a[3] * b[1],
              a[0] * b[2] + a[2] * b[3],
              a[1] * b[2] + a[3] * b[3],
              a[0] * b[4] + a[2] * b[5] + a[4],
              a[1] * b[4] + a[3] * b[5] + a[5],
            ];
          }
        case 'BT':
          flush();
          active = true;
          positioned = false;
          x = 0;
          y = 0;
        case 'ET':
          flush();
          active = false;
        case 'Td':
        case 'TD':
          if (operands.length >= 2 &&
              operands[0] is num &&
              operands[1] is num) {
            x += (operands[0] as num).toDouble();
            y += (operands[1] as num).toDouble();
            positioned = true;
            if (token == 'TD') leading = -(operands[1] as num).toDouble();
          }
        case 'TL':
          if (operands.isNotEmpty && operands.last is num) {
            leading = (operands.last as num).toDouble();
          }
        case 'T*':
          y -= leading;
          x = 0;
        case 'Tm':
          if (operands.length >= 6 &&
              operands[4] is num &&
              operands[5] is num) {
            x = (operands[4] as num).toDouble();
            y = (operands[5] as num).toDouble();
            positioned = true;
          }
        case 'Tf':
          if (operands.length >= 2) {
            font =
                fonts['${operands[operands.length - 2]}'.replaceFirst(
                  '/',
                  '',
                )] ??
                _Font('', null);
          }
        case 'Tj':
        case 'TJ':
        case "'":
        case '"':
          if (active && operands.isNotEmpty) {
            if (token == "'" || token == '"') {
              y -= leading;
              x = 0;
            }
            show(operands.last);
          }
      }
      operands.clear();
    }
    flush();
    pieces.sort((a, b) => b.y.compareTo(a.y));
    for (var i = 0; i < pieces.length;) {
      final line = [pieces[i++]];
      while (i < pieces.length && (pieces[i].y - line.first.y).abs() < 2) {
        line.add(pieces[i++]);
      }
      final arabic = line.any(
        (p) => RegExp(r'[\u0600-\u06ff]').hasMatch(p.value),
      );
      line.sort(
        (a, b) => a.x == b.x
            ? a.order.compareTo(b.order)
            : arabic
            ? b.x.compareTo(a.x)
            : a.x.compareTo(b.x),
      );
      out.writeln(line.map((p) => p.value).join(' '));
    }
    return out.toString();
  }
}

class _PdfString {
  _PdfString(this.bytes);
  final List<int> bytes;
}

Iterable<Object> _tokens(String source) sync* {
  var i = 0;
  while (i < source.length) {
    final c = source[i];
    if (RegExp(r'\s').hasMatch(c)) {
      i++;
      continue;
    }
    if (c == '%') {
      while (i < source.length && source[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '(') {
      final bytes = <int>[];
      var depth = 1;
      i++;
      while (i < source.length && depth > 0) {
        var code = source.codeUnitAt(i++);
        if (code == 92 && i < source.length) {
          code = source.codeUnitAt(i++);
          if (code >= 48 && code <= 55) {
            var octal = String.fromCharCode(code);
            while (octal.length < 3 &&
                i < source.length &&
                source.codeUnitAt(i) >= 48 &&
                source.codeUnitAt(i) <= 55) {
              octal += source[i++];
            }
            bytes.add(int.parse(octal, radix: 8) & 255);
            continue;
          }
          if (code == 10 || code == 13) {
            if (code == 13 && i < source.length && source.codeUnitAt(i) == 10) {
              i++;
            }
            continue;
          }
          bytes.add(switch (code) {
            110 => 10,
            114 => 13,
            116 => 9,
            98 => 8,
            102 => 12,
            _ => code,
          });
          continue;
        }
        if (code == 40) depth++;
        if (code == 41) {
          depth--;
          if (depth == 0) break;
        }
        bytes.add(code);
      }
      yield _PdfString(bytes);
      continue;
    }
    // Marked-content property dictionaries are not hexadecimal strings.
    if (i + 1 < source.length &&
        (source.substring(i, i + 2) == '<<' ||
            source.substring(i, i + 2) == '>>')) {
      yield source.substring(i, i + 2);
      i += 2;
      continue;
    }
    if (c == '<' && i + 1 < source.length && source[i + 1] != '<') {
      final end = source.indexOf('>', i);
      if (end < 0) throw const ImportException('import_invalid_pdf');
      var hex = source.substring(i + 1, end).replaceAll(RegExp(r'\s'), '');
      if (hex.length.isOdd) hex += '0';
      yield _PdfString([
        for (var j = 0; j < hex.length; j += 2)
          int.parse(hex.substring(j, j + 2), radix: 16),
      ]);
      i = end + 1;
      continue;
    }
    if (c == '[') {
      final end = source.indexOf(']', i);
      if (end < 0) throw const ImportException('import_invalid_pdf');
      yield _tokens(source.substring(i + 1, end)).toList();
      i = end + 1;
      continue;
    }
    final start = i++;
    while (i < source.length && !RegExp(r'[\s\[\]()<>/]').hasMatch(source[i])) {
      i++;
    }
    final value = source.substring(start, i);
    yield num.tryParse(value) ?? value;
  }
}

class _Font {
  _Font(this.dictionary, String? cmap) {
    if (cmap == null) return;
    void add(String code, String value) {
      if (map.length >= 131072) throw const ImportException('import_too_large');
      if (value.length % 4 != 0) {
        throw const ImportException('import_pdf_font_unsupported');
      }
      map[code.toUpperCase()] = String.fromCharCodes([
        for (var i = 0; i < value.length; i += 4)
          int.parse(value.substring(i, i + 4), radix: 16),
      ]);
      widths.add(code.length ~/ 2);
    }

    for (final block in RegExp(
      r'beginbfchar([\s\S]*?)endbfchar',
    ).allMatches(cmap)) {
      for (final pair in RegExp(
        r'<([\da-fA-F]+)>\s*<([\da-fA-F]+)>',
      ).allMatches(block.group(1)!)) {
        add(pair.group(1)!, pair.group(2)!);
      }
    }
    for (final block in RegExp(
      r'beginbfrange([\s\S]*?)endbfrange',
    ).allMatches(cmap)) {
      for (final range in RegExp(
        r'<([\da-fA-F]+)>\s*<([\da-fA-F]+)>\s*(<([\da-fA-F]+)>|\[([^\]]*)\])',
      ).allMatches(block.group(1)!)) {
        final low = int.parse(range.group(1)!, radix: 16),
            high = int.parse(range.group(2)!, radix: 16);
        if (high < low || high - low > 65536) {
          throw const ImportException('import_too_large');
        }
        final values = range.group(5) == null
            ? null
            : RegExp(
                r'<([\da-fA-F]+)>',
              ).allMatches(range.group(5)!).map((m) => m.group(1)!).toList();
        for (var code = low; code <= high; code++) {
          final offset = code - low;
          if (values != null && offset >= values.length) {
            throw const ImportException('import_invalid_pdf');
          }
          final value = values == null
              ? (int.parse(range.group(4)!, radix: 16) + offset)
                    .toRadixString(16)
                    .padLeft(range.group(4)!.length, '0')
              : values[offset];
          add(
            code.toRadixString(16).padLeft(range.group(1)!.length, '0'),
            value,
          );
        }
      }
    }
  }
  final String dictionary;
  final map = <String, String>{};
  final widths = <int>{};
  String decode(List<int> bytes) {
    if (bytes.isEmpty) return '';
    if (bytes.length >= 2 && bytes[0] == 254 && bytes[1] == 255) {
      return String.fromCharCodes([
        for (var i = 2; i + 1 < bytes.length; i += 2)
          bytes[i] * 256 + bytes[i + 1],
      ]);
    }
    if (map.isNotEmpty) {
      final out = StringBuffer(),
          sizes = widths.toList()..sort((a, b) => b.compareTo(a));
      for (var i = 0; i < bytes.length;) {
        var found = false;
        for (final size in sizes) {
          if (i + size > bytes.length) continue;
          final key = bytes
              .skip(i)
              .take(size)
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join()
              .toUpperCase();
          if (map.containsKey(key)) {
            out.write(map[key]);
            i += size;
            found = true;
            break;
          }
        }
        if (!found) throw const ImportException('import_pdf_font_unsupported');
      }
      return out.toString();
    }
    if (RegExp(r'/Subtype\s*/Type0\b|/Identity-[HV]\b').hasMatch(dictionary) ||
        bytes.any((b) => b < 9)) {
      throw const ImportException('import_pdf_font_unsupported');
    }
    return latin1.decode(bytes);
  }
}

class _BoundedSink implements Sink<List<int>> {
  _BoundedSink(this.limit);
  final int limit;
  final bytes = BytesBuilder(copy: false);
  @override
  void add(List<int> data) {
    if (bytes.length + data.length > limit) {
      throw const ImportException('import_too_large');
    }
    bytes.add(data);
  }

  @override
  void close() {}
}
