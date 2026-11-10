import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';
import 'package:cv_builder_pro/features/resume_builder/presentation/widgets/pdf_preview_view.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aWQAAAABJRU5ErkJggg==',
);

class _DelayedPage extends PdfRaster {
  _DelayedPage(this.result) : super(1, 1, Uint8List(4));
  final Future<Uint8List> result;
  @override
  Future<Uint8List> toPng() => result;
}

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets(
    'closing PDF during PNG conversion cancels stream and ignores late page',
    (tester) async {
      final png = Completer<Uint8List>();
      var cancelled = false;
      final stream = StreamController<PdfRaster>(
        onCancel: () => cancelled = true,
      );
      await tester.pumpWidget(
        _host(
          PdfPreviewView(
            bytes: Uint8List(1),
            onRetry: () {},
            rasterizer: (_) => stream.stream,
          ),
        ),
      );
      stream.add(_DelayedPage(png.future));
      await tester.pump();
      await tester.pumpWidget(_host(const Text('closed')));
      png.complete(_png);
      await tester.pump();
      expect(cancelled, true);
      expect(tester.takeException(), isNull);
      unawaited(stream.close());
    },
  );
  testWidgets(
    'replacing PDF ignores stale PNG conversion and displays new pages',
    (tester) async {
      final stale = Completer<Uint8List>();
      final old = Uint8List.fromList([1]);
      final fresh = Uint8List.fromList([2]);
      Stream<PdfRaster> rasterize(Uint8List bytes) => Stream.value(
        _DelayedPage(identical(bytes, old) ? stale.future : Future.value(_png)),
      );
      await tester.pumpWidget(
        _host(
          PdfPreviewView(bytes: old, onRetry: () {}, rasterizer: rasterize),
        ),
      );
      await tester.pump();
      await tester.pumpWidget(
        _host(
          PdfPreviewView(bytes: fresh, onRetry: () {}, rasterizer: rasterize),
        ),
      );
      await tester.pumpAndSettle();
      stale.completeError(StateError('old conversion failed'));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('raster errors offer retry without a framework error', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      _host(
        PdfPreviewView(
          bytes: Uint8List(1),
          onRetry: () => retries++,
          rasterizer: (_) => Stream.error(StateError('invalid pdf')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('retry'));
    await tester.pumpAndSettle();
    expect(retries, 1);
    expect(tester.takeException(), isNull);
  });
}
