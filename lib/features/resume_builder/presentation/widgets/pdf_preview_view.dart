import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../../../app/theme/index.dart';
import '../../../../shared_widgets/index.dart';

/// Scrollable, zoomable PDF pages with cancellation on disposal or replacement.
class PdfPreviewView extends StatefulWidget {
  const PdfPreviewView({
    super.key,
    required this.bytes,
    required this.onRetry,
    this.rasterizer,
  });
  final Uint8List bytes;
  final VoidCallback onRetry;
  final Stream<PdfRaster> Function(Uint8List)? rasterizer;
  @override
  State<PdfPreviewView> createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<PdfPreviewView> {
  final _pages = <({Uint8List png, double ratio})>[];
  StreamIterator<PdfRaster>? _iterator;
  int _generation = 0;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_render());
  }

  @override
  void didUpdateWidget(covariant PdfPreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.bytes, widget.bytes)) unawaited(_render());
  }

  Future<void> _cancel(StreamIterator<PdfRaster>? iterator) async {
    try {
      await iterator?.cancel();
    } catch (_) {
      // A cancelled renderer must not report a failure on a closed screen.
    }
  }

  Future<void> _render() async {
    final generation = ++_generation;
    unawaited(_cancel(_iterator));
    _pages.clear();
    _loading = true;
    _failed = false;
    StreamIterator<PdfRaster>? iterator;
    try {
      iterator = StreamIterator(
        widget.rasterizer?.call(widget.bytes) ??
            Printing.raster(widget.bytes, dpi: 144),
      );
      _iterator = iterator;
      while (await iterator.moveNext()) {
        final page = iterator.current;
        final png = await page.toPng();
        // Both stream delivery and PNG conversion cross async boundaries.
        if (!mounted || generation != _generation) return;
        if (page.width <= 0 || page.height <= 0) {
          throw StateError('Invalid PDF page dimensions');
        }
        setState(() => _pages.add((png: png, ratio: page.width / page.height)));
      }
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _failed = _pages.isEmpty;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    } finally {
      await _cancel(iterator);
    }
  }

  Widget _error() => AppEmptyState(
    title: 'failed_to_generate_preview'.tr,
    actionLabel: 'retry'.tr,
    onAction: widget.onRetry,
  );

  @override
  Widget build(BuildContext context) {
    if (_failed) return _error();
    if (_pages.isEmpty) return AppLoading(message: 'pdf_preview_loading'.tr);
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: ListView.separated(
        key: const ValueKey('pdf-rendered-pages'),
        padding: const EdgeInsets.all(AppSpacing.sm),
        itemCount: _pages.length + (_loading ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == _pages.length) {
            return AppLoading(message: 'pdf_preview_loading'.tr);
          }
          final page = _pages[index];
          return Semantics(
            label: 'pdf_page_number'.trParams({'number': '${index + 1}'}),
            image: true,
            child: AspectRatio(
              aspectRatio: page.ratio,
              child: ColoredBox(
                color: Colors.white,
                child: Image.memory(
                  page.png,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _error(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _generation++;
    unawaited(_cancel(_iterator));
    super.dispose();
  }
}
