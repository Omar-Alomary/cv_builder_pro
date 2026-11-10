import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import '../../../../data/models/resume_model.dart';

/// Contract for PDF layouts using fonts loaded by the central PDF service.
abstract class BasePdfTemplate {
  const BasePdfTemplate();
  Future<Uint8List> build({
    required ResumeModel resume,
    required pw.Font font,
    required bool isArabic,
  });
}
