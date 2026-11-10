import 'dart:convert';
import '../models/resume_model.dart';

/// Encodes and validates portable resume JSON without performing file I/O.
abstract final class ResumeJson {
  static String encode(ResumeModel resume, {bool pretty = true}) {
    try {
      final encoder = pretty
          ? const JsonEncoder.withIndent('  ')
          : const JsonEncoder();
      return encoder.convert(resume.toJson());
    } catch (error) {
      throw FormatException('Unable to encode resume JSON: $error');
    }
  }

  static ResumeModel decode(String source) {
    try {
      final decoded = jsonDecode(source.replaceFirst(RegExp('^\uFEFF'), ''));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Resume JSON must contain an object');
      }
      if (!decoded.containsKey('fullName') || decoded['fullName'] is! String) {
        throw const FormatException('Resume JSON requires a fullName string');
      }
      return ResumeModel.fromJson(decoded);
    } on FormatException {
      rethrow;
    } catch (error) {
      throw FormatException('Invalid resume field type: $error');
    }
  }
}
