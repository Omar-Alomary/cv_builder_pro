import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/resume_model.dart';
import '../constants/app_constants.dart';
import '../../features/resume_builder/presentation/templates/ats_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/base_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/modern_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/classic_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/business_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/technical_pdf_template.dart';
import '../../features/resume_builder/presentation/templates/pdf_template_options.dart';

/// Loads local fonts and photos and dispatches immutable drafts to PDF layouts.
class PdfService {
  PdfService({AssetBundle? assets}) : _assets = assets ?? rootBundle;
  final AssetBundle _assets;
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    int? photoMaxDimension,
  }) async {
    final snapshot = resume.copyWith();
    locale = AppConstants.documentLocale(snapshot.templateId, locale);
    final templateType = AppConstants.templateType(snapshot.templateId);
    if (templateType == 'ats') {
      return generateAts(snapshot, locale: locale);
    }
    try {
      if (![
        'modern',
        'classic',
        'business',
        'technical',
      ].contains(templateType)) {
        throw ArgumentError.value(
          snapshot.templateId,
          'templateId',
          'Unknown PDF template',
        );
      }
      final options = PdfTemplateOptions.fromJson(snapshot.customization);
      final cairo = pw.Font.ttf(
        await _assets.load('assets/fonts/Cairo-Regular.ttf'),
      );
      final isArabic = locale.startsWith('ar');
      final fontPath = switch (options.fontFamily) {
        'Poppins' => 'assets/fonts/Poppins-Regular.ttf',
        'Sukar' => 'assets/fonts/SukarRegular.ttf',
        _ => 'assets/fonts/Cairo-Regular.ttf',
      };
      final font = options.fontFamily == 'Cairo'
          ? cairo
          : pw.Font.ttf(await _assets.load(fontPath));
      final bold = pw.Font.ttf(
        await _assets.load(
          options.fontFamily == 'Sukar'
              ? 'assets/fonts/SukarBlack.ttf'
              : 'assets/fonts/Cairo-Bold.ttf',
        ),
      );
      Uint8List? photo;
      final path = snapshot.profilePicture;
      if (path != null && path.trim().isNotEmpty) {
        try {
          final file = File(path);
          if (await file.exists()) {
            photo = await file.readAsBytes();
            if (photoMaxDimension != null) {
              photo = await _resizePhoto(photo, photoMaxDimension);
            }
          }
        } catch (error) {
          throw StateError('Unable to read profile photo: $error');
        }
      }
      final BasePdfTemplate template = switch (templateType) {
        'classic' => ClassicPdfTemplate(
          options: options,
          fallbackFont: cairo,
          boldFont: bold,
          photo: photo,
        ),
        'business' => BusinessPdfTemplate(
          options: options,
          fallbackFont: cairo,
          boldFont: bold,
          photo: photo,
        ),
        'technical' => TechnicalPdfTemplate(
          options: options,
          fallbackFont: cairo,
          boldFont: bold,
          photo: photo,
        ),
        _ => ModernPdfTemplate(
          options: options,
          fallbackFont: cairo,
          boldFont: bold,
          photo: photo,
        ),
      };
      return await template.build(
        resume: snapshot,
        font: font,
        isArabic: isArabic,
      );
    } catch (error) {
      throw StateError('Unable to generate ${snapshot.templateId} PDF: $error');
    }
  }

  Future<Uint8List> _resizePhoto(Uint8List bytes, int dimension) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      final maximum = dimension.clamp(32, 2048);
      final scale = math.min(
        1.0,
        maximum / math.max(descriptor.width, descriptor.height),
      );
      codec = await descriptor.instantiateCodec(
        targetWidth: math.max(1, (descriptor.width * scale).round()),
        targetHeight: math.max(1, (descriptor.height * scale).round()),
      );
      image = (await codec.getNextFrame()).image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Unable to encode profile photo');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer.dispose();
    }
  }

  Future<Uint8List> generateAts(
    ResumeModel resume, {
    String locale = 'en',
  }) async {
    try {
      final snapshot = resume.copyWith();
      locale = AppConstants.documentLocale(snapshot.templateId, locale);
      final data = await _assets.load('assets/fonts/Cairo-Regular.ttf');
      return await const AtsPdfTemplate().build(
        resume: snapshot,
        font: pw.Font.ttf(data),
        isArabic: locale.startsWith('ar'),
      );
    } catch (error) {
      throw StateError('Unable to generate ATS PDF: $error');
    }
  }
}
