# Part 2 — الدفعة الخامسة عشرة: استيراد السيرة
الملفات التالية كاملة ومطبقة في المشروع. أضيف مسار الاستيراد وزر في الرئيسية. file_picker موجود بالقيد ^8.0.0؛ لا اعتماديات أخرى أضيفت.
JSON: اختيار ملف أو لصق مباشر، جميع حقول ResumeModel محفوظة في التحويل، ومعاينة JSON قابلة للتعديل قبل الحفظ. يدعم BOM وUTF-8 وUTF-16. TXT: استخراج مبدئي للاسم والبريد والهاتف والروابط والمهارات المفصولة بفواصل، مع الاحتفاظ بالنص الكامل في الملخص للمراجعة اليدوية. لا يحول التعليم والخبرات في TXT/PDF إلى سجلات منظمة تلقائياً.
حدود PDF: هذه ليست أداة PDF عامة. القراءة محدودة بتدفقات النص الحرفي البسيط ASCII، غير المضغوطة أو المضغوطة Flate. ترفض الخطوط Type0 وToUnicode والنصوص السداسية والتشفير وملفات الصور التي لا تحتوي نصاً مدعوماً. لا يوجد OCR ولا دعم لاستيراد PDF العربي بخطوط مضمّنة. لذلك لا يتحقق شرط استيراد جميع ملفات PDF الوارد في الطلب الأصلي بهذه الدفعة؛ تظهر الحدود في واجهة الاختيار ورسائل الخطأ. JSON هو الخيار الذي يحافظ على بنية السيرة كاملة.
الملفات بحد أقصى 10 ميغابايت، وفك ضغط PDF محدود لتجنب استهلاك غير محدود للذاكرة. تستخدم الخدمة FilePicker ثم معالجة في isolate. الحفظ ينشئ سيرة جديدة ويصفّر المعرّف ومسار الصورة المحلية والمفضلة قبل تمرير نسخة إلى المحرر، لمنع الكتابة فوق سيرة محلية موجودة. لا تُحفظ المعاينة تلقائياً.
التحقق: فحص المجلدات المطورة دون ملاحظات ونجاح 130 اختباراً إجمالاً. تضم الإضافات اختبارات JSON الكامل والنص العربي والترميزات وPDF النصي وFlate وملف مضغوط يتجاوز الحد، ومعاينة الاستيراد وتعديلها والحفظ وفشله والإلغاء والتجاوب وزر الرئيسية. اختيار الملفات الأصلي لم يختبر على جهاز؛ اختبارات الشاشة تستبدل الخدمة وتختبر المحلل ببايتات فعلية. لم ينفذ flutter run في هذه الدفعة.
مرجع تقنية فك الضغط: [توثيق dart:io الرسمي](https://api-staging.dart.dev/dart-io/).

## pubspec.yaml

```yaml
name: cv_builder_pro
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  #sdk: ">3.0.0 <4.0.0"
  sdk: ">=3.10.8 <4.0.0"

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter
   # State Management & Routing
  get: ^4.6.5
  get_storage: ^2.1.1
  hive_flutter:
  flutter_colorpicker:
  marquee:
  
  # UI Components
  carousel_slider: ^5.1.2
  lottie: ^3.3.2
  animated_text_kit: ^4.2.2
  intl: ^0.20.2
  
  # Export & Sharing
  share_plus: ^12.0.1
  url_launcher: ^6.1.14
  path_provider: ^2.1.0
  
  # PDF Generation
  pdf: ^3.10.2
  printing: ^5.11.2
  image_picker: ^1.0.4
  file_picker: ^8.0.0

 # shared_preferences:
 
  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  
dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true
  assets:
    - assets/animations/

  # To add assets to your application, add an assets section, like this:
  #assets:
  # - assets/
  #   - images/a_dot_ham.jpeg
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Bold.ttf
        - asset: assets/fonts/Cairo-Regular.ttf
        
    - family: Sukar
      fonts:
        - asset: assets/fonts/SukarBlack.ttf
        - asset: assets/fonts/SukarRegular.ttf
        - asset: assets/fonts/Sukar Regular.ttf
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf    
  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package

```

## lib/core/services/resume_import_service.dart

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../data/index.dart';
import '../constants/app_constants.dart';
import 'simple_pdf_text_extractor.dart';

/// A localized import failure with a stable translation key.
class ImportException implements Exception {
  const ImportException(this.messageKey);
  final String messageKey;
  @override
  String toString() => messageKey;
}

/// Imports portable JSON and conservatively extracts plain resume text.
class ResumeImportService {
  Future<ResumeModel?> pickAndImport(String extension) async {
    try {
      if (!['json', 'pdf', 'txt'].contains(extension)) {
        throw const ImportException('import_unsupported');
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [extension],
        allowMultiple: false,
        withData: false,
        withReadStream: true,
      );
      if (result == null) return null;
      final file = result.files.single;
      if (file.size > AppConstants.maxImportBytes) {
        throw const ImportException('import_too_large');
      }
      if (file.extension?.toLowerCase() != extension) {
        throw const ImportException('import_extension_mismatch');
      }
      final builder = BytesBuilder(copy: false);
      if (file.bytes != null) {
        builder.add(file.bytes!);
      } else if (file.readStream != null) {
        await for (final chunk in file.readStream!) {
          if (builder.length + chunk.length > AppConstants.maxImportBytes) {
            throw const ImportException('import_too_large');
          }
          builder.add(chunk);
        }
      } else if (file.path != null) {
        final source = File(file.path!);
        if (await source.length() > AppConstants.maxImportBytes) {
          throw const ImportException('import_too_large');
        }
        await for (final chunk in source.openRead()) {
          if (builder.length + chunk.length > AppConstants.maxImportBytes) {
            throw const ImportException('import_too_large');
          }
          builder.add(chunk);
        }
      } else {
        throw const ImportException('import_read_failed');
      }
      return await compute(_decodeFile, (builder.takeBytes(), extension));
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException('import_read_failed');
    }
  }

  ResumeModel fromJsonText(String source) {
    try {
      if (utf8.encode(source).length > AppConstants.maxImportBytes) {
        throw const ImportException('import_too_large');
      }
      return ResumeJson.decode(source);
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException('import_invalid_json');
    }
  }

  ResumeModel fromBytes(Uint8List bytes, String extension) {
    try {
      if (bytes.isEmpty) throw const ImportException('import_empty');
      if (bytes.length > AppConstants.maxImportBytes) {
        throw const ImportException('import_too_large');
      }
      switch (extension.toLowerCase()) {
        case 'json':
          return fromJsonText(_decodeText(bytes));
        case 'txt':
          return fromPlainText(_decodeText(bytes));
        case 'pdf':
          return fromPlainText(SimplePdfTextExtractor.extract(bytes));
        default:
          throw const ImportException('import_unsupported');
      }
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException('import_read_failed');
    }
  }

  String _decodeText(Uint8List bytes) {
    if (bytes.length >= 2 &&
        ((bytes[0] == 255 && bytes[1] == 254) ||
            (bytes[0] == 254 && bytes[1] == 255))) {
      if (bytes.length.isOdd) {
        throw const ImportException('import_text_encoding');
      }
      final data = ByteData.sublistView(bytes);
      return String.fromCharCodes([
        for (var i = 2; i < bytes.length; i += 2)
          data.getUint16(i, bytes[0] == 255 ? Endian.little : Endian.big),
      ]);
    }
    try {
      return utf8.decode(bytes).replaceFirst('\uFEFF', '');
    } catch (_) {
      throw const ImportException('import_text_encoding');
    }
  }

  ResumeModel fromPlainText(String source) {
    if (utf8.encode(source).length > AppConstants.maxImportBytes) {
      throw const ImportException('import_too_large');
    }
    final text = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
    if (text.isEmpty) throw const ImportException('import_empty');
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    String? labeled(String labels) => RegExp(
      '^(?:$labels)\\s*[:：]\\s*(.+)\$',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(text)?.group(1)?.trim();
    final email =
        RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}').firstMatch(text)?.group(0) ??
        '';
    final phone =
        labeled('phone|mobile|هاتف|الهاتف|الجوال') ??
        RegExp(r'(?:\+?\d[\d ()-]{6,}\d)').firstMatch(text)?.group(0) ??
        '';
    final name = labeled('full name|name|الاسم|الاسم الكامل') ?? lines.first;
    final skillsText = labeled('skills|المهارات');
    final links = RegExp(
      r'https?://[^\s<>]+',
      caseSensitive: false,
    ).allMatches(text).map((match) => match.group(0)!).toList();
    String? link(String domain) {
      for (final value in links) {
        final host = Uri.tryParse(value)?.host.toLowerCase() ?? '';
        if (host == domain || host.endsWith('.$domain')) return value;
      }
      return null;
    }

    return ResumeModel(
      fullName: name,
      email: email,
      phone: phone,
      address: labeled('address|location|العنوان|الموقع'),
      summary: text,
      linkedin: link('linkedin.com'),
      github: link('github.com'),
      website: labeled('website|الموقع الإلكتروني'),
      portfolio: labeled('portfolio|معرض الأعمال'),
      skills: skillsText == null
          ? []
          : skillsText
                .split(RegExp(r'[,،;؛|]'))
                .map((skill) => skill.trim())
                .where((skill) => skill.isNotEmpty)
                .toSet()
                .map((skill) => Skill(name: skill))
                .toList(),
    );
  }
}

ResumeModel _decodeFile((Uint8List, String) payload) =>
    ResumeImportService().fromBytes(payload.$1, payload.$2);

```

## lib/core/services/simple_pdf_text_extractor.dart

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'resume_import_service.dart';

/// Conservative reader for literal text in unencrypted simple-font PDF streams.
abstract final class SimplePdfTextExtractor {
  static String extract(Uint8List bytes) {
    final source = latin1.decode(bytes);
    if (!source.startsWith('%PDF-')) {
      throw const ImportException('import_invalid_pdf');
    }
    if (RegExp(r'/Encrypt\b').hasMatch(source)) {
      throw const ImportException('import_pdf_encrypted');
    }
    // Glyph identifiers cannot safely be interpreted as Unicode text.
    if (RegExp(
      r'/Subtype\s*/Type0\b|/ToUnicode\b|/Encoding\s*/Identity-[HV]\b',
    ).hasMatch(source)) {
      throw const ImportException('import_pdf_font_unsupported');
    }
    final output = StringBuffer();
    var decodedBytes = 0;
    final streams = RegExp(
      r'<<(.*?)>>\s*stream\r?\n',
      dotAll: true,
    ).allMatches(source);
    for (final match in streams) {
      final dictionary = match.group(1)!;
      final end = source.indexOf('endstream', match.end);
      if (end < 0) throw const ImportException('import_invalid_pdf');
      if (dictionary.contains('/Subtype /Image') ||
          RegExp(r'/Subtype\s*/Image').hasMatch(dictionary)) {
        continue;
      }
      final length = RegExp(
        r'/Length\s+(\d+)(?!\d|\s+\d+\s+R)',
      ).firstMatch(dictionary);
      final declared = length == null ? null : int.tryParse(length.group(1)!);
      final stop = declared != null && match.end + declared <= end
          ? match.end + declared
          : end;
      var data = bytes.sublist(match.end, stop);
      if (RegExp(r'/Filter\b').hasMatch(dictionary)) {
        if (!RegExp(r'/Filter\s*/FlateDecode\b').hasMatch(dictionary)) {
          throw const ImportException('import_invalid_pdf');
        }
        final sink = _BoundedSink(20 * 1024 * 1024 - decodedBytes);
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
      decodedBytes += data.length;
      if (decodedBytes > 20 * 1024 * 1024) {
        throw const ImportException('import_too_large');
      }
      final stream = latin1.decode(data);
      for (final block in RegExp(
        r'\bBT\b(.*?)\bET\b',
        dotAll: true,
      ).allMatches(stream)) {
        final body = block.group(1)!;
        // Reject hex glyph strings rather than displaying guessed text.
        if (RegExp(r'<[0-9A-Fa-f\s]+>').hasMatch(body)) {
          throw const ImportException('import_pdf_font_unsupported');
        }
        for (final token in RegExp(
          r'\(((?:\\[\s\S]|[^\\()])*)\)',
          dotAll: true,
        ).allMatches(body)) {
          final value = token.group(1)!.replaceAllMapped(
            RegExp(r'\\([0-7]{1,3}|[\s\S])'),
            (m) {
              final escape = m.group(1)!;
              final octal = int.tryParse(escape, radix: 8);
              if (octal != null) return String.fromCharCode(octal);
              return switch (escape) {
                'n' => '\n',
                'r' => '\n',
                't' => '\t',
                '\n' => '',
                _ => escape,
              };
            },
          );
          if (value.codeUnits.any((code) => code > 127)) {
            throw const ImportException('import_pdf_font_unsupported');
          }
          output.writeln(value);
        }
      }
    }
    if (output.toString().trim().isEmpty) {
      throw const ImportException('import_pdf_no_text');
    }
    return output.toString();
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

```

## lib/core/index.dart

```dart
export 'constants/app_constants.dart';
export 'services/storage_service.dart';
export 'services/settings_service.dart';
export 'services/resume_import_service.dart';
export 'services/ats_analyzer_service.dart';
export 'utils/ats_scorer.dart';
export 'constants/storage_keys.dart';
export 'extensions/context_extensions.dart';
export 'utils/app_snackbar.dart';
export 'utils/date_formatter.dart';
export 'utils/responsive.dart';
export 'utils/validators.dart';

```

## lib/features/import_resume/presentation/pages/import_resume_screen.dart

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/services/resume_import_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/import_option_card.dart';
import '../widgets/import_preview_widget.dart';
import '../widgets/import_loading_widget.dart';

/// Picks a file or accepts pasted JSON, previews it, and saves an isolated copy.
class ImportResumeScreen extends StatefulWidget {
  const ImportResumeScreen({super.key, this.service});
  final ResumeImportService? service;
  @override
  State<ImportResumeScreen> createState() => _ImportResumeScreenState();
}

class _ImportResumeScreenState extends State<ImportResumeScreen> {
  late final _service = widget.service ?? ResumeImportService();
  final _paste = TextEditingController();
  final _previewKey = GlobalKey();
  ResumeModel? _resume;
  bool _loading = false;
  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  void _preview(ResumeModel resume) {
    setState(() => _resume = resume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _previewKey.currentContext;
      if (mounted && context != null) {
        Scrollable.ensureVisible(context, alignment: 0);
      }
    });
  }

  Future<void> _pick(String extension) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final resume = await _service.pickAndImport(extension);
      if (resume != null && mounted) _preview(resume);
    } on ImportException catch (error) {
      if (mounted) AppSnackbar.error(context, error.messageKey.tr);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'import_read_failed'.tr);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(ResumeModel resume) async {
    // Foreign IDs and local image paths must not overwrite or access local data.
    final copy = resume.copyWith(
      id: null,
      profilePicture: null,
      createdAt: DateTime.now(),
      updatedAt: null,
      isFavorite: false,
    );
    final saved = await Get.find<ResumeController>().saveResume(copy);
    if (saved && mounted) {
      Get.offNamed<void>(AppRoutes.resumeBuilder, arguments: copy.copyWith());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Scaffold(
      appBar: AppBar(
        title: Text('import_resume'.tr),
        toolbarHeight: 56 + math.max(0, scale - 1) * 30,
      ),
      body: SafeArea(
        child: Responsive.maxWidth(
          child: SingleChildScrollView(
            key: const ValueKey('import-scroll'),
            padding: Responsive.pagePadding(context),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final options = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final format in ['json', 'pdf', 'txt'])
                      ImportOptionCard(
                        key: ValueKey('import-option-$format'),
                        title: 'import_${format}_title'.tr,
                        description: 'import_${format}_description'.tr,
                        icon: format == 'pdf'
                            ? Icons.picture_as_pdf_outlined
                            : format == 'json'
                            ? Icons.data_object
                            : Icons.text_snippet_outlined,
                        actionLabel: 'import_select_file'.trParams({
                          'format': format.toUpperCase(),
                        }),
                        onSelect: _loading ? null : () => _pick(format),
                      ),
                    const SizedBox(height: 16),
                    AppTextField(
                      key: const ValueKey('paste-resume-json'),
                      controller: _paste,
                      label: 'import_paste_json'.tr,
                      maxLines: 7,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.multiline,
                      enabled: !_loading,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      key: const ValueKey('parse-pasted-json'),
                      label: 'import_preview'.tr,
                      fullWidth: true,
                      onPressed: _loading
                          ? null
                          : () {
                              try {
                                _preview(_service.fromJsonText(_paste.text));
                              } on ImportException catch (error) {
                                AppSnackbar.error(context, error.messageKey.tr);
                              }
                            },
                    ),
                  ],
                );
                final preview = Column(
                  key: _previewKey,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loading) const ImportLoadingWidget(),
                    if (_resume != null)
                      ImportPreviewWidget(
                        key: ObjectKey(_resume),
                        resume: _resume!,
                        onSave: _save,
                        onDiscard: () => setState(() => _resume = null),
                      )
                    else if (!_loading)
                      AppEmptyState(
                        title: 'import_preview_empty'.tr,
                        description: 'import_preview_empty_description'.tr,
                        icon: Icons.upload_file,
                      ),
                  ],
                );
                if (Responsive.isTabletOrLarger(context)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: options),
                      const SizedBox(width: 24),
                      Expanded(child: preview),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [options, const SizedBox(height: 24), preview],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/features/import_resume/presentation/widgets/import_option_card.dart

```dart
import 'package:flutter/material.dart';
import '../../../../shared_widgets/index.dart';

/// File format explanation with a working picker action.
class ImportOptionCard extends StatelessWidget {
  const ImportOptionCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    required this.onSelect,
  });
  final String title;
  final String description;
  final IconData icon;
  final String actionLabel;
  final Future<void> Function()? onSelect;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 36)),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 16),
          AppButton(label: actionLabel, fullWidth: true, onPressed: onSelect),
        ],
      ),
    ),
  );
}

```

## lib/features/import_resume/presentation/widgets/import_preview_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/resume_import_service.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/index.dart';
import '../../../../shared_widgets/index.dart';

/// Editable full-schema JSON preview that validates before saving a new resume.
class ImportPreviewWidget extends StatefulWidget {
  const ImportPreviewWidget({
    super.key,
    required this.resume,
    required this.onSave,
    required this.onDiscard,
  });
  final ResumeModel resume;
  final Future<void> Function(ResumeModel) onSave;
  final VoidCallback onDiscard;
  @override
  State<ImportPreviewWidget> createState() => _ImportPreviewWidgetState();
}

class _ImportPreviewWidgetState extends State<ImportPreviewWidget> {
  late final _json = TextEditingController(
    text: ResumeJson.encode(widget.resume),
  );
  @override
  void dispose() {
    _json.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionHeader(
            title: 'import_preview'.tr,
            subtitle: 'import_preview_description'.tr,
          ),
          const SizedBox(height: 12),
          Text(
            widget.resume.fullName.isEmpty
                ? 'untitled_resume'.tr
                : widget.resume.fullName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.resume.email.isNotEmpty)
            Text(widget.resume.email, textDirection: TextDirection.ltr),
          Text(
            'import_section_counts'.trParams({
              'education': '${widget.resume.education.length}',
              'experience': '${widget.resume.experience.length}',
              'skills': '${widget.resume.skills.length}',
            }),
          ),
          const SizedBox(height: 16),
          AppTextField(
            key: const ValueKey('import-preview-json'),
            controller: _json,
            label: 'import_edit_json'.tr,
            maxLines: 16,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
          AppButton(
            key: const ValueKey('save-imported-resume'),
            label: 'import_save_edit'.tr,
            icon: Icons.save_outlined,
            fullWidth: true,
            onPressed: () async {
              try {
                final resume = ResumeImportService().fromJsonText(_json.text);
                if (resume.fullName.trim().isEmpty) {
                  AppSnackbar.warning(context, 'import_name_required'.tr);
                  return;
                }
                await widget.onSave(resume);
              } on ImportException catch (error) {
                if (context.mounted) {
                  AppSnackbar.error(context, error.messageKey.tr);
                }
              }
            },
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'import_discard'.tr,
            onPressed: widget.onDiscard,
            fullWidth: true,
            variant: AppButtonVariant.text,
          ),
        ],
      ),
    ),
  );
}

```

## lib/features/import_resume/presentation/widgets/import_loading_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared_widgets/index.dart';

/// Shared animated loading feedback during file selection and decoding.
class ImportLoadingWidget extends StatelessWidget {
  const ImportLoadingWidget({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: AppLoading(message: 'import_loading'.tr),
  );
}

```

## lib/features/import_resume/index.dart

```dart
export 'presentation/pages/import_resume_screen.dart';
export 'presentation/widgets/import_option_card.dart';
export 'presentation/widgets/import_preview_widget.dart';
export 'presentation/widgets/import_loading_widget.dart';

```

## lib/features/index.dart

```dart
export 'splash/index.dart';
export 'language/index.dart';
export 'home/index.dart';
export 'templates/index.dart';
export 'favorites/index.dart';
export 'settings/index.dart';
export 'import_resume/index.dart';

```

## lib/app/routes/app_routes.dart

```dart
/// Named routes used throughout the application.
abstract final class AppRoutes {
  static const root = '/';
  static const splash = '/splash';
  static const languageSelection = '/language-selection';
  static const home = '/home';
  static const templates = '/templates';
  static const favorites = '/favorites';
  static const settings = '/settings';
  static const resumeBuilder = '/resume-builder';
  static const preview = '/preview';
  static const importResume = '/import-resume';
}

```

## lib/app/routes/app_pages.dart

```dart
import 'package:get/get.dart';
import '../../legacy_app.dart' as legacy;
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/language/presentation/pages/language_selection_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/templates/presentation/pages/templates_screen.dart';
import '../../features/favorites/presentation/pages/favorites_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';
import '../../features/import_resume/presentation/pages/import_resume_screen.dart';
import 'app_routes.dart';

/// Registers existing screens during the staged migration.
abstract final class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(name: AppRoutes.root, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.languageSelection,
      page: () => const LanguageSelectionScreen(),
    ),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(
      name: AppRoutes.importResume,
      page: () => const ImportResumeScreen(),
    ),
    GetPage(name: AppRoutes.templates, page: () => const TemplatesScreen()),
    GetPage(name: AppRoutes.favorites, page: () => const FavoritesScreen()),
    GetPage(name: AppRoutes.settings, page: () => const SettingsScreen()),
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () => const legacy.ResumeBuilderScreen(),
    ),
    GetPage(name: AppRoutes.preview, page: () => const legacy.PreviewScreen()),
  ];
}

```

## lib/features/home/presentation/pages/home_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../controllers/resume_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../data/models/resume_model.dart';
import '../../../../shared_widgets/index.dart';
import '../widgets/home_header.dart';
import '../widgets/stats_cards.dart';
import '../widgets/marquee_header.dart';
import '../widgets/template_carousel.dart';
import '../widgets/recent_activity_card.dart';

/// Responsive dashboard for templates, saved resumes and navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _recentKey = GlobalKey();
  bool _showAll = false;
  bool _exitDialogOpen = false;

  void _viewAll() {
    setState(() => _showAll = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _recentKey.currentContext == null) return;
      Scrollable.ensureVisible(
        _recentKey.currentContext!,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 300),
      );
    });
  }

  Future<bool> _confirm(String title, String message, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.value<double>(
                context: context,
                mobile: 500,
                tablet: 600,
                desktop: 650,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(message),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      AppButton(
                        label: 'cancel'.tr,
                        variant: AppButtonVariant.text,
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                        },
                      ),
                      AppButton(
                        label: action,
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ) ??
      false;

  Future<void> _delete(ResumeModel resume) async {
    if (resume.id == null) return;
    final confirmed = await _confirm(
      'delete'.tr,
      'delete_resume_confirmation'.tr,
      'delete'.tr,
    );
    if (confirmed && mounted) {
      await Get.find<ResumeController>().deleteResume(resume.id!);
    }
  }

  Future<void> _requestExit() async {
    if (_exitDialogOpen) return;
    _exitDialogOpen = true;
    try {
      final confirmed = await _confirm(
        'exit_app'.tr,
        'exit_confirmation'.tr,
        'exit'.tr,
      );
      if (confirmed && mounted) await SystemNavigator.pop();
    } catch (_) {
      if (mounted) AppSnackbar.error(context, 'action_failed'.tr);
    } finally {
      _exitDialogOpen = false;
    }
  }

  Widget _recent() {
    final controller = Get.find<ResumeController>();
    return Obx(() {
      final items = controller.getRecentResumes(
        limit: _showAll ? controller.resumes.length : 5,
      );
      if (items.isEmpty) {
        return AppEmptyState(
          title: 'no_resumes_found'.tr,
          description: 'home_empty_description'.tr,
          actionLabel: 'create_new'.tr,
          onAction: () async {
            await Get.toNamed<void>(AppRoutes.resumeBuilder);
          },
        );
      }
      Widget card(int index) => RecentActivityCard(
        key: ValueKey('recent-${items[index].id}'),
        resume: items[index],
        onEdit: () {
          Get.toNamed<void>(
            AppRoutes.resumeBuilder,
            arguments: items[index].copyWith(),
          );
        },
        onDelete: () => _delete(items[index]),
        onFavorite: () async {
          final id = items[index].id;
          if (id != null) await controller.toggleFavorite(id);
        },
      );
      if (Responsive.isMobile(context)) {
        return ListView.separated(
          key: const ValueKey('recent-list'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, index) => card(index),
        );
      }
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      return GridView.builder(
        key: const ValueKey('recent-grid'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Responsive.isDesktop(context) ? 3 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 340 + (scale > 1 ? scale - 1 : 0) * 220,
        ),
        itemBuilder: (_, index) => card(index),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final resumes = Get.find<ResumeController>();
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Directionality(
      textDirection: Get.locale?.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _requestExit();
        },
        child: Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                resumes.loadResumes();
              },
              child: CustomScrollView(
                key: const ValueKey('home-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: HomeHeader(
                      statistics: StatsCards(onViewResumes: _viewAll),
                    ),
                  ),
                  const SliverToBoxAdapter(child: MarqueeHeader()),
                  SliverToBoxAdapter(
                    child: Responsive.maxWidth(
                      child: Padding(
                        padding: Responsive.pagePadding(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppButton(
                              key: const ValueKey('create-resume'),
                              label: 'create_new'.tr,
                              icon: Icons.add,
                              onPressed: () async {
                                await Get.toNamed<void>(
                                  AppRoutes.resumeBuilder,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              key: const ValueKey('import-resume'),
                              label: 'import_resume'.tr,
                              icon: Icons.upload_file,
                              variant: AppButtonVariant.outlined,
                              fullWidth: true,
                              onPressed: () async {
                                await Get.toNamed<void>(AppRoutes.importResume);
                              },
                            ),
                            const SizedBox(height: 24),
                            AppSectionHeader(
                              title: 'featured_templates'.tr,
                              subtitle: 'home_templates_description'.tr,
                              actionLabel: 'view_all'.tr,
                              onAction: () async {
                                await Get.toNamed<void>(AppRoutes.templates);
                              },
                            ),
                            const SizedBox(height: 16),
                            const TemplateCarousel(),
                            const SizedBox(height: 24),
                            AppSectionHeader(
                              key: _recentKey,
                              title:
                                  (_showAll ? 'resumes' : 'recent_activity').tr,
                              subtitle: 'home_recent_description'.tr,
                              actionLabel:
                                  (_showAll ? 'show_recent' : 'view_all').tr,
                              onAction: () {
                                if (_showAll) {
                                  setState(() => _showAll = false);
                                } else {
                                  _viewAll();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            _recent(),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Align(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Responsive.maxContentWidth,
              ),
              child: NavigationBar(
                height: 80 + (scale > 1 ? scale - 1 : 0) * 24,
                selectedIndex: 0,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                onDestinationSelected: (index) {
                  if (index == 0) return;
                  Get.toNamed<void>(
                    [
                      AppRoutes.home,
                      AppRoutes.templates,
                      AppRoutes.favorites,
                      AppRoutes.settings,
                    ][index],
                  );
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.home_outlined),
                    selectedIcon: const Icon(Icons.home),
                    label: 'home'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_outlined),
                    label: 'templates'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.favorite_outline),
                    label: 'favorites'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    label: 'settings'.tr,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

```

## lib/translations/en_us.dart

```dart
/// English interface messages.
const Map<String, String> enUs = {
  'home': 'Home',
  'templates': 'Templates',
  'favorites': 'Favorites',
  'settings': 'Settings',
  'save': 'Save',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'edit': 'Edit',
  'next': 'Next',
  'previous': 'Previous',
  'finish': 'Finish',
  'preview': 'Preview',
  'view_all': 'View All',
  'success': 'Success',
  'resume_saved': 'Resume saved successfully',
  'resume_deleted': 'Resume deleted successfully',
  'no_resumes_found': 'No resumes found',
  'no_favorites': 'No favorites yet',
  'browse_templates': 'Browse Templates',
  'create_new': 'Create New',
  'recent_activity': 'Recent Activity',
  'featured_templates': 'Featured Templates',
  'use_template': 'Use Template',
  'personal_info': 'Personal Information',
  'education': 'Education',
  'experience': 'Experience',
  'skills': 'Skills',
  'full_name': 'Full Name',
  'email': 'Email',
  'phone': 'Phone',
  'address': 'Address',
  'summary': 'Professional Summary',
  'degree': 'Degree',
  'institution': 'Institution',
  'graduation_year': 'Graduation Year',
  'grade': 'Grade',
  'add_education': 'Add Education',
  'edit_education': 'Edit Education',
  'no_education_added': 'No education added',
  'degree_required': 'Degree is required',
  'institution_required': 'Institution is required',
  'year_required': 'Graduation year is required',
  'job_title': 'Job Title',
  'company': 'Company',
  'start_date': 'Start Date',
  'end_date': 'End Date',
  'current_job': 'Current Job',
  'description': 'Description',
  'add_experience': 'Add Experience',
  'edit_experience': 'Edit Experience',
  'no_experience_added': 'No experience added',
  'job_title_required': 'Job title is required',
  'company_required': 'Company is required',
  'start_date_required': 'Start date is required',
  'skill_name': 'Skill Name',
  'skill_level': 'Skill Level',
  'add_skill': 'Add Skill',
  'no_skills_added': 'No skills added',
  'language': 'Language',
  'change_app_language': 'Change app language',
  'dark_mode': 'Dark Mode',
  'switch_theme': 'Switch between light and dark theme',
  'contact_us': 'Contact Us',
  'share_app': 'Share App',
  'email_required': 'Email is required',
  'invalid_email': 'Please enter a valid email',
  'phone_required': 'Phone number is required',
  'invalid_phone': 'Please enter a valid phone number',
  'is_required': 'is required',
  'create_resume': 'Create Resume',
  'edit_resume': 'Edit Resume',
  'customize_resume': 'Customize Resume',
  'apply_changes': 'Apply Changes',
  'customization_saved': 'Customization saved successfully',
  'failed_to_generate_preview': 'Failed to generate preview',
  'failed_to_export': 'Failed to export PDF',
  'choose_color': 'Choose Color',
  'preview_updated': 'Preview updated successfully',
  'update_preview': 'Update Preview',
  'courses': 'Courses',
  'certificates': 'Certificates',
  'languages': 'Languages',
  'add_course': 'Add Course',
  'add_certificate': 'Add Certificate',
  'add_language': 'Add Language',
  'course_name': 'Course Name',
  'certificate_name': 'Certificate Name',
  'language_name': 'Language Name',
  'provider': 'Provider',
  'organization': 'Organization',
  'proficiency_level': 'Proficiency Level',
  'no_courses_added': 'No courses added',
  'no_certificates_added': 'No certificates added',
  'no_languages_added': 'No languages added',
  'course_name_required': 'Course name is required',
  'provider_required': 'Provider is required',
  'certificate_name_required': 'Certificate name is required',
  'organization_required': 'Organization is required',
  'language_name_required': 'Language name is required',
  'additional_info': 'Additional Info',
  'projects': 'Projects',
  'achievements': 'Achievements',
  'interests': 'Interests',
  'project_name': 'Project Name',
  'achievement': 'Achievement',
  'no_projects_added': 'No projects added',
  'no_achievements_added': 'No achievements added',
  'no_additional_sections': 'No additional sections available',
  'your_selected_interests': 'Your Selected Interests:',
  'select_interests': 'Select Your Interests',
  'linkedin': 'LinkedIn',
  'github': 'GitHub',
  'website': 'Website',
  'portfolio': 'Portfolio',
  'profile_image_updated': 'Profile image updated successfully',
  'clear_cache': 'Clear Cache',
  'clear_cache_description': 'Remove temporary files and free up space',
  'clear_cache_confirmation': 'Are you sure you want to clear cache?',
  'cache_cleared': 'Cache cleared successfully',
  'cache_clear_failed': 'Failed to clear cache',
  'data': 'Data',
  'about': 'About',
  'app_version': 'App Version',
  'version_1_0_0': 'Version 1.0.0',
  'exit_app': 'Exit App',
  'exit_confirmation': 'Are you sure you want to exit?',
  'exit': 'Exit',
  'yes': 'Yes',
  'no': 'No',
  'logged_out': 'Logged out',
  'come_back_soon': 'We hope to see you again soon!',
  'logout_confirmation': 'Are you sure you want to logout?',
  'professional_resume_builder': 'Professional Resume Builder',
  'appearance': 'Appearance',
  'data_management': 'Data Management',
  'support': 'Support',
  'get_help_support': 'Get help and support',
  'rate_app': 'Rate App',
  'rate_us_on_store': 'Rate us on the store',
  'share_with_friends': 'Share with friends',
  'cannot_open_email': 'Cannot open email client',
  'select_language': 'Select Language',
  'add_project': 'Add Project',
  'edit_project': 'Edit Project',
  'current_project': 'Current Project',
  'technologies_used': 'Technologies Used',
  'add_technology': 'Add Technology',
  'project_name_required': 'Project name is required',
  'description_required': 'Description is required',
  'achievement_name': 'Achievement Name',
  'achievement_name_required': 'Achievement name is required',
  'category': 'Category',
  'date_required': 'Date is required',
  'add_achievement': 'Add Achievement',
  'edit_achievement': 'Edit Achievement',
  'cache_cleared_completely': 'Cache cleared completely',
  'clear_all_data': 'Clear All Data',
  'clear_all_data_confirmation':
      'This will delete ALL your resumes and settings. This action cannot be undone. Are you sure?',
  'clear_all': 'Clear All',
  'all_data_cleared': 'All data cleared successfully',
  'clear_all_data_failed': 'Failed to clear all data',
  'close': 'Close',
  'date': 'Date',
  'year': 'Year',
  'error': 'Error',
  'retry': 'Retry',
  'featured': 'Featured',
  'logout': 'Log out',
  'my_skills': 'My skills',
  'resumes': 'Resumes',
  'edit_certificate': 'Edit certificate',
  'edit_course': 'Edit course',
  'edit_language': 'Edit language',
  'app_name': 'CV Builder Pro',
  'search_templates': 'Search templates',
  'search': 'Search',
  'no_search_results': 'No matching results',
  'search_hint': 'Search by name or description',
  'total_resumes': 'Total resumes',
  'favorite_resumes': 'Favorite resumes',
  'available_templates': 'Available templates',
  'saving': 'Saving…',
  'auto_saved': 'Saved automatically',
  'last_saved': 'Last saved: @time',
  'save_failed': 'Could not save your changes. Try again.',
  'loading': 'Loading…',
  'please_wait': 'Please wait',
  'storage_error':
      'Storage operation failed. Check device storage and try again.',
  'startup_error':
      'Local storage could not be opened. Close and reopen the app. If the problem persists, check storage space and app permissions.',
  'field_required': '@field is required',
  'invalid_url': 'Enter a full http(s) URL',
  'invalid_date': 'Use a valid MM/YYYY date',
  'invalid_date_range': 'The end date must not precede the start date',
  'choose_image': 'Choose image',
  'remove_image': 'Remove image',
  'delete_resume_confirmation': 'Delete this resume?',
  'select_resume': 'Select a resume',
  'export_json': 'Export JSON',
  'export_pdf': 'Export PDF',
  'share_json': 'Share JSON',
  'share_pdf': 'Share PDF',
  'print_pdf': 'Print PDF',
  'import_json': 'Import JSON',
  'import_pdf': 'Import PDF',
  'import_txt': 'Import TXT',
  'recommended': 'Recommended',
  'choose_file': 'Choose file',
  'paste_json': 'Paste JSON',
  'paste_json_hint': 'Paste the complete resume JSON here',
  'json_import_description':
      'Restores all fields from a compatible resume JSON file.',
  'pdf_import_description':
      'Attempts to extract text from supported text-based PDF files. Scanned PDFs require OCR.',
  'txt_import_description':
      'Extracts recognizable contact details and text for review.',
  'import_success': 'Resume imported successfully',
  'import_failed': 'Could not import this file. Check its format and contents.',
  'import_cancelled': 'No file selected',
  'unsupported_file': 'This file type is not supported',
  'file_too_large': 'The file exceeds the 10 MB import limit',
  'invalid_json': 'The JSON structure or field types are invalid',
  'pdf_import_unsupported':
      'Text could not be extracted from this PDF. Try JSON or TXT.',
  'review_before_save':
      'Review and correct the imported information before saving.',
  'save_and_edit': 'Save and edit',
  'export_success': 'Export completed',
  'export_failed': 'Could not export the resume',
  'export_cancelled': 'Export cancelled',
  'export_quality': 'Export quality',
  'quality_standard': 'Standard',
  'quality_high': 'High',
  'customization': 'Customization',
  'font_family': 'Font',
  'font_size': 'Font size',
  'primary_color': 'Primary color',
  'secondary_color': 'Secondary color',
  'ats_checker': 'ATS checker',
  'ats_score': 'ATS score',
  'ats_score_out_of': '@score out of 100',
  'ats_recheck': 'Check again',
  'ats_use_template': 'Use ATS template',
  'ats_edit_resume': 'Go to edit',
  'ats_issues': 'Issues',
  'ats_suggestions': 'Suggestions',
  'ats_missing_keywords': 'Missing keywords',
  'ats_no_issues': 'No issues found by these checks',
  'ats_no_resume': 'Select or create a resume to start the check',
  'ats_checking': 'Analyzing resume…',
  'ats_guidance':
      'This is a rule-based guide, not a guarantee of acceptance by recruiting systems.',
  'ats_formatting_note':
      'Formatting checks use the configured template, not a parsed exported PDF.',
  'ats_template_applied': 'ATS template saved',
  'ats_section_contact': 'Contact',
  'ats_section_summary': 'Summary',
  'ats_section_experience': 'Experience',
  'ats_section_education': 'Education',
  'ats_section_skills': 'Skills',
  'ats_section_keywords': 'Keywords',
  'ats_section_formatting': 'Formatting',
  'ats_severity_critical': 'Critical',
  'ats_severity_warning': 'Warning',
  'ats_severity_info': 'Information',
  'ats_keyword_teamwork': 'teamwork',
  'ats_keyword_leadership': 'leadership',
  'ats_keyword_communication': 'communication',
  'ats_keyword_problem_solving': 'problem-solving',
  'time_just_now': 'Just now',
  'time_ago': '@count @unit ago',
  'time_in': 'In @count @unit',
  'time_minute': 'minute',
  'time_minutes': 'minutes',
  'time_hour': 'hour',
  'time_hours': 'hours',
  'time_day': 'day',
  'time_days': 'days',
  'ats_issue_name': 'The resume has no name.',
  'ats_fix_name': 'Add your full name.',
  'ats_issue_email': 'Email is missing or invalid.',
  'ats_fix_email': 'Add a valid email address.',
  'ats_issue_phone': 'Phone is missing or invalid.',
  'ats_fix_phone': 'Add a valid phone number.',
  'ats_issue_linkedin': 'A valid LinkedIn URL is missing.',
  'ats_fix_linkedin': 'Add your full LinkedIn profile URL.',
  'ats_issue_website': 'A website or portfolio URL is missing.',
  'ats_fix_website': 'Add a relevant website or portfolio URL.',
  'ats_issue_summary_missing': 'Professional summary is missing.',
  'ats_fix_summary_missing': 'Write a concise professional summary.',
  'ats_issue_summary_length': 'Summary length is outside 50–300 characters.',
  'ats_fix_summary_length': 'Keep the summary between 50 and 300 characters.',
  'ats_issue_summary_keywords': 'The summary lacks recognized job keywords.',
  'ats_fix_summary_keywords': 'Include relevant skills in the summary.',
  'ats_issue_experience_missing':
      'No complete work experience entry was found.',
  'ats_fix_experience_missing':
      'Add relevant work, internship or volunteer experience.',
  'ats_issue_experience_actions':
      'Experience descriptions lack recognized action verbs.',
  'ats_fix_experience_actions':
      'Describe achievements with verbs such as developed or led.',
  'ats_issue_experience_dates':
      'Experience dates are missing, invalid or in the future.',
  'ats_fix_experience_dates':
      'Use MM/YYYY dates and mark ongoing positions as current.',
  'ats_issue_education_missing':
      'Education is missing a degree or institution.',
  'ats_fix_education_missing': 'Add your degree and institution.',
  'ats_issue_education_year': 'A valid graduation year is missing.',
  'ats_fix_education_year':
      'Add a four-digit graduation or expected graduation year.',
  'ats_issue_skills_minimum': 'Fewer than five distinct skills were found.',
  'ats_fix_skills_minimum': 'Add at least five relevant distinct skills.',
  'ats_issue_skills_count': 'Fewer than ten distinct skills were found.',
  'ats_fix_skills_count':
      'Add more relevant skills where supported by your experience.',
  'ats_issue_skills_diversity':
      'A mix of recognized technical and interpersonal skills was not found.',
  'ats_fix_skills_diversity':
      'Include both technical and interpersonal skills you actually use.',
  'ats_issue_keywords_missing':
      'Common transferable skill keywords were not found.',
  'ats_fix_keywords_missing':
      'Mention relevant teamwork, leadership, communication or problem-solving experience.',
  'ats_issue_placeholders': 'Placeholder text requiring review was found.',
  'ats_fix_placeholders':
      'Replace placeholder text with your own verified information.',
  'ats_issue_photo': 'The configured output includes a photo.',
  'ats_fix_photo': 'Use the ATS template to omit the photo from the output.',
  'ats_issue_font': 'The selected font is not in the simple-font list.',
  'ats_fix_font': 'Choose Cairo or Poppins, or use the ATS template.',
  'ats_issue_columns':
      'A single-column layout is not confirmed for this configuration.',
  'ats_fix_columns': 'Use the single-column ATS template.',
  'ats_select_resume': 'Select or create a resume before analyzing.',
  'ats_analysis_failed':
      'The resume could not be analyzed. Check its data and try again.',
  'ats_save_failed': 'The ATS template could not be saved.',
  'ats_apply_failed': 'The ATS template could not be applied.',
  'action_failed': 'The action could not be completed. Try again.',
  'splash_tagline': 'Create your professional resume',
  'splash_preparing': 'Getting ready…',
  'language_selection_title': 'Choose your language',
  'language_selection_subtitle':
      'Select your preferred language. You can change it later in settings.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'United States',
  'country_sa': 'Saudi Arabia',
  'select_english': 'Select English',
  'select_arabic': 'Select Arabic',
  'switch_to_english': 'Use the app in English',
  'switch_to_arabic': 'Use the app in Arabic',
  'home_welcome': 'Welcome back!',
  'home_empty_description': 'Start by creating your first professional resume.',
  'home_templates_description': 'Choose from our professional designs.',
  'home_recent_description': 'Your latest saved resumes and changes.',
  'show_recent': 'Show recent',
  'untitled_resume': 'Untitled resume',
  'no_templates_available': 'No templates are available',
  'template_position': '@current of @total',
  'add_favorite': 'Add to favorites',
  'remove_favorite': 'Remove from favorites',
  'tip_action_verbs': 'Use action verbs to describe your achievements.',
  'tip_tailor_resume': 'Tailor your resume for each job application.',
  'tip_resume_length': 'Keep your resume concise and relevant.',
  'tip_relevant_skills': 'Highlight your most relevant skills and experience.',
  'tip_job_keywords': 'Use relevant keywords from the job description.',
  'clear_template_search': 'Clear search',
  'reset_template_filters': 'Reset filters',
  'template_category_all': 'All',
  'template_category_ats': 'ATS',
  'template_category_business': 'Business',
  'template_category_classic': 'Classic',
  'template_category_modern': 'Modern',
  'template_category_technical': 'Technical',
  'favorite_remove_confirmation':
      'Remove "@name" from favorites? The resume will remain saved.',
  'favorites_empty_description':
      'Add your saved resumes to favorites to find them here.',
  'favorites_empty_title': 'No favorites yet',
  'search_favorites': 'Search favorites',
  'change_profile_image': 'Change profile photo',
  'profile_image_failed':
      'Could not select or save the profile photo. Please try again.',
  'settings_data_description':
      'Delete all saved resumes, favorites, profile and preferences.',
  'settings_exit_confirmation':
      'Exit the app and clear the current draft and profile photo preference? Saved resumes will remain.',
  'share_app_message': 'Create professional resumes with CV Builder Pro.',
  'import_discard': 'Discard preview',
  'import_edit_json': 'Editable resume JSON',
  'import_empty': 'The file contains no text.',
  'import_extension_mismatch':
      'The selected file does not match the requested format.',
  'import_invalid_json':
      'Invalid resume JSON. Use an object with fullName as text and correctly typed resume fields.',
  'import_invalid_pdf': 'This PDF is damaged or unsupported.',
  'import_json_description':
      'Preserves every resume section. Select a UTF-8 or UTF-16 JSON file, up to 10 MB.',
  'import_json_title': 'JSON — recommended',
  'import_loading': 'Reading and checking your resume…',
  'import_name_required': 'Enter a full name before saving.',
  'import_paste_json': 'Or paste resume JSON',
  'import_pdf_description':
      'Supports simple ASCII text PDFs, including Flate streams. Scans, encrypted PDFs and encoded fonts are unsupported. Review the extracted content.',
  'import_pdf_encrypted': 'Password-protected PDF files cannot be imported.',
  'import_pdf_font_unsupported':
      'This PDF uses unsupported font encoding. Import JSON or copy its text to a UTF-8 TXT file.',
  'import_pdf_no_text':
      'No supported PDF text was found. Scanned PDFs require OCR; use JSON or TXT instead.',
  'import_pdf_title': 'PDF — basic text only',
  'import_preview': 'Preview import',
  'import_preview_description':
      'Edit any field in the full JSON below, then save a new copy and continue editing. Foreign IDs, favorites and image paths are reset.',
  'import_preview_empty': 'Your import preview appears here',
  'import_preview_empty_description':
      'Choose a file or paste JSON. Nothing is saved until you confirm.',
  'import_read_failed':
      'Could not read the file. Check access permissions and try again.',
  'import_resume': 'Import resume',
  'import_save_edit': 'Save and continue editing',
  'import_section_counts':
      'Education: @education • Experience: @experience • Skills: @skills',
  'import_select_file': 'Select @format file',
  'import_text_encoding': 'Save the text file using UTF-8 or UTF-16 encoding.',
  'import_too_large':
      'The file is larger than 10 MB or its decompressed content exceeds the safe limit.',
  'import_txt_description':
      'Extracts name, email, phone, links and comma-separated skills. Keeps the complete text in Summary for manual review.',
  'import_txt_title': 'TXT',
  'import_unsupported': 'Choose a JSON, PDF or TXT file.',
};

```

## lib/translations/ar_sa.dart

```dart
/// Arabic interface messages.
const Map<String, String> arSa = {
  'home': 'الرئيسية',
  'templates': 'القوالب',
  'favorites': 'المفضلة',
  'settings': 'الإعدادات',
  'save': 'حفظ',
  'cancel': 'إلغاء',
  'delete': 'حذف',
  'edit': 'تعديل',
  'next': 'التالي',
  'previous': 'السابق',
  'finish': 'إنهاء',
  'preview': 'معاينة',
  'view_all': 'عرض الكل',
  'success': 'نجاح',
  'resume_saved': 'تم حفظ السيرة الذاتية بنجاح',
  'resume_deleted': 'تم حذف السيرة الذاتية بنجاح',
  'no_resumes_found': 'لا توجد سير ذاتية',
  'no_favorites': 'لا توجد مفضلات بعد',
  'browse_templates': 'تصفح جميع القوالب',
  'create_new': 'إنشاء سيرة جديدة',
  'recent_activity': 'النشاطات الأخيرة',
  'featured_templates': 'قوالب مميزة',
  'use_template': 'استخدم القالب',
  'personal_info': 'المعلومات الشخصية',
  'education': 'التعليم',
  'experience': 'الخبرات',
  'skills': 'المهارات',
  'full_name': 'الاسم الكامل',
  'email': 'البريد الإلكتروني',
  'phone': 'رقم الهاتف',
  'address': 'العنوان',
  'summary': 'الملخص المهني',
  'degree': 'الشهادة',
  'institution': 'المؤسسة التعليمية',
  'graduation_year': 'سنة التخرج',
  'grade': 'التقدير',
  'add_education': 'إضافة تعليم',
  'edit_education': 'تعديل التعليم',
  'no_education_added': 'لم تتم إضافة تعليم',
  'degree_required': 'الشهادة مطلوبة',
  'institution_required': 'المؤسسة التعليمية مطلوبة',
  'year_required': 'سنة التخرج مطلوبة',
  'job_title': 'المسمى الوظيفي',
  'company': 'الشركة',
  'start_date': 'تاريخ البدء',
  'end_date': 'تاريخ الانتهاء',
  'current_job': 'وظيفة حالية',
  'description': 'الوصف',
  'add_experience': 'إضافة خبرة',
  'edit_experience': 'تعديل الخبرة',
  'no_experience_added': 'لم تتم إضافة خبرات',
  'job_title_required': 'المسمى الوظيفي مطلوب',
  'company_required': 'الشركة مطلوبة',
  'start_date_required': 'تاريخ البدء مطلوب',
  'skill_name': 'اسم المهارة',
  'skill_level': 'المستوى',
  'add_skill': 'إضافة مهارة',
  'no_skills_added': 'لم تتم إضافة مهارات',
  'language': 'اللغة',
  'change_app_language': 'تغيير لغة التطبيق',
  'dark_mode': 'الوضع الليلي',
  'switch_theme': 'التبديل بين الوضع الليلي والنهاري',
  'contact_us': 'اتصل بنا',
  'share_app': 'مشاركة التطبيق',
  'email_required': 'البريد الإلكتروني مطلوب',
  'invalid_email': 'الرجاء إدخال بريد إلكتروني صحيح',
  'phone_required': 'رقم الهاتف مطلوب',
  'invalid_phone': 'الرجاء إدخال رقم هاتف صحيح',
  'is_required': 'مطلوب',
  'create_resume': 'إنشاء سيرة ذاتية',
  'edit_resume': 'تعديل السيرة الذاتية',
  'customize_resume': 'تخصيص السيرة الذاتية',
  'apply_changes': 'تطبيق التغييرات',
  'customization_saved': 'تم حفظ التخصيص بنجاح',
  'failed_to_generate_preview': 'فشل في إنشاء المعاينة',
  'failed_to_export': 'فشل في تصدير PDF',
  'choose_color': 'اختر اللون',
  'preview_updated': 'تم تحديث المعاينة بنجاح',
  'update_preview': 'تحديث المعاينة',
  'courses': 'الدورات التدريبية',
  'certificates': 'الشهادات',
  'languages': 'اللغات',
  'add_course': 'إضافة دورة',
  'add_certificate': 'إضافة شهادة',
  'add_language': 'إضافة لغة',
  'course_name': 'اسم الدورة',
  'certificate_name': 'اسم الشهادة',
  'language_name': 'اسم اللغة',
  'provider': 'مقدم الدورة',
  'organization': 'الجهة المانحة',
  'proficiency_level': 'مستوى الإتقان',
  'no_courses_added': 'لم تتم إضافة دورات',
  'no_certificates_added': 'لم تتم إضافة شهادات',
  'no_languages_added': 'لم تتم إضافة لغات',
  'course_name_required': 'اسم الدورة مطلوب',
  'provider_required': 'مقدم الدورة مطلوب',
  'certificate_name_required': 'اسم الشهادة مطلوب',
  'organization_required': 'الجهة المانحة مطلوبة',
  'language_name_required': 'اسم اللغة مطلوب',
  'additional_info': 'معلومات إضافية',
  'projects': 'المشاريع',
  'achievements': 'الإنجازات',
  'interests': 'الاهتمامات',
  'project_name': 'اسم المشروع',
  'achievement': 'الإنجاز',
  'no_projects_added': 'لم تتم إضافة مشاريع',
  'no_achievements_added': 'لم تتم إضافة إنجازات',
  'no_additional_sections': 'لا توجد أقسام إضافية',
  'your_selected_interests': 'اهتماماتك المختارة:',
  'select_interests': 'اختر اهتماماتك',
  'linkedin': 'لينكد إن',
  'github': 'جيت هاب',
  'website': 'الموقع الإلكتروني',
  'portfolio': 'ملف الأعمال',
  'profile_image_updated': 'تم تحديث صورة الملف الشخصي بنجاح',
  'clear_cache': 'مسح الكاش',
  'clear_cache_description': 'إزالة الملفات المؤقتة وتحرير المساحة',
  'clear_cache_confirmation': 'هل أنت متأكد من مسح الكاش؟',
  'cache_cleared': 'تم مسح الكاش بنجاح',
  'cache_clear_failed': 'فشل في مسح الكاش',
  'data': 'البيانات',
  'about': 'حول التطبيق',
  'app_version': 'إصدار التطبيق',
  'version_1_0_0': 'الإصدار 1.0.0',
  'exit_app': 'الخروج من التطبيق',
  'exit_confirmation': 'هل أنت متأكد من الخروج من التطبيق؟',
  'exit': 'خروج',
  'yes': 'نعم',
  'no': 'لا',
  'logged_out': 'تم تسجيل الخروج',
  'come_back_soon': 'نتمنى رؤيتك مرة أخرى قريباً!',
  'logout_confirmation': 'هل أنت متأكد من تسجيل الخروج؟',
  'professional_resume_builder': 'منشئ السير الذاتية الاحترافي',
  'appearance': 'المظهر',
  'data_management': 'إدارة البيانات',
  'support': 'الدعم',
  'get_help_support': 'احصل على المساعدة والدعم',
  'rate_app': 'تقييم التطبيق',
  'rate_us_on_store': 'قيمنا في المتجر',
  'share_with_friends': 'شارك مع الأصدقاء',
  'cannot_open_email': 'لا يمكن فتح بريد إلكتروني',
  'select_language': 'اختر لغتك المفضلة',
  'add_project': 'إضافة مشروع',
  'edit_project': 'تعديل مشروع',
  'current_project': 'مشروع حالي',
  'technologies_used': 'التقنيات المستخدمة',
  'add_technology': 'إضافة تقنية',
  'project_name_required': 'اسم المشروع مطلوب',
  'description_required': 'الوصف مطلوب',
  'achievement_name': 'اسم الإنجاز',
  'achievement_name_required': 'اسم الإنجاز مطلوب',
  'category': 'التصنيف',
  'date_required': 'التاريخ مطلوب',
  'add_achievement': 'إضافة إنجاز',
  'edit_achievement': 'تعديل إنجاز',
  'cache_cleared_completely': 'تم مسح الكاش بالكامل',
  'clear_all_data': 'مسح جميع البيانات',
  'clear_all_data_confirmation':
      'سيؤدي هذا إلى حذف جميع سيرك الذاتية وإعداداتك. هذا الإجراء لا يمكن التراجع عنه. هل أنت متأكد؟',
  'clear_all': 'مسح الكل',
  'all_data_cleared': 'تم مسح جميع البيانات بنجاح',
  'clear_all_data_failed': 'فشل في مسح جميع البيانات',
  'close': 'إغلاق',
  'date': 'التاريخ',
  'year': 'السنة',
  'error': 'خطأ',
  'retry': 'إعادة المحاولة',
  'featured': 'مميز',
  'logout': 'تسجيل الخروج',
  'my_skills': 'مهاراتي',
  'resumes': 'السير الذاتية',
  'edit_certificate': 'تعديل الشهادة',
  'edit_course': 'تعديل الدورة',
  'edit_language': 'تعديل اللغة',
  'app_name': 'CV Builder Pro',
  'search_templates': 'البحث في القوالب',
  'search': 'بحث',
  'no_search_results': 'لا توجد نتائج مطابقة',
  'search_hint': 'ابحث بالاسم أو الوصف',
  'total_resumes': 'إجمالي السير',
  'favorite_resumes': 'السير المفضلة',
  'available_templates': 'القوالب المتاحة',
  'saving': 'جارٍ الحفظ…',
  'auto_saved': 'تم الحفظ تلقائياً',
  'last_saved': 'آخر حفظ: @time',
  'save_failed': 'تعذر حفظ التغييرات. أعد المحاولة.',
  'loading': 'جارٍ التحميل…',
  'please_wait': 'يرجى الانتظار',
  'storage_error': 'تعذرت عملية التخزين. تحقق من مساحة الجهاز وأعد المحاولة.',
  'startup_error':
      'تعذر فتح التخزين المحلي. أغلق التطبيق ثم أعد تشغيله. إذا استمرت المشكلة، تحقق من مساحة التخزين وصلاحيات التطبيق.',
  'field_required': '@field مطلوب',
  'invalid_url': 'أدخل رابطاً كاملاً يبدأ بـ http أو https',
  'invalid_date': 'استخدم تاريخاً صالحاً بصيغة MM/YYYY',
  'invalid_date_range': 'يجب ألا يسبق تاريخ الانتهاء تاريخ البدء',
  'choose_image': 'اختيار صورة',
  'remove_image': 'إزالة الصورة',
  'delete_resume_confirmation': 'هل تريد حذف هذه السيرة؟',
  'select_resume': 'اختر سيرة ذاتية',
  'export_json': 'تصدير JSON',
  'export_pdf': 'تصدير PDF',
  'share_json': 'مشاركة JSON',
  'share_pdf': 'مشاركة PDF',
  'print_pdf': 'طباعة PDF',
  'import_json': 'استيراد JSON',
  'import_pdf': 'استيراد PDF',
  'import_txt': 'استيراد TXT',
  'recommended': 'موصى به',
  'choose_file': 'اختيار ملف',
  'paste_json': 'لصق JSON',
  'paste_json_hint': 'الصق بيانات السيرة بصيغة JSON هنا',
  'json_import_description': 'يستعيد جميع الحقول من ملف JSON متوافق للسيرة.',
  'pdf_import_description':
      'يحاول استخراج النص من ملفات PDF النصية المدعومة. الملفات الممسوحة ضوئياً تحتاج إلى OCR.',
  'txt_import_description':
      'يستخرج بيانات الاتصال والنصوص التي يمكن التعرف عليها لمراجعتها.',
  'import_success': 'تم استيراد السيرة بنجاح',
  'import_failed': 'تعذر استيراد الملف. تحقق من صيغته ومحتواه.',
  'import_cancelled': 'لم يتم اختيار ملف',
  'unsupported_file': 'نوع الملف غير مدعوم',
  'file_too_large': 'يتجاوز الملف حد الاستيراد البالغ 10 ميجابايت',
  'invalid_json': 'بنية JSON أو أنواع الحقول غير صالحة',
  'pdf_import_unsupported':
      'تعذر استخراج النص من ملف PDF هذا. جرّب JSON أو TXT.',
  'review_before_save': 'راجع المعلومات المستوردة وصححها قبل الحفظ.',
  'save_and_edit': 'حفظ وتعديل',
  'export_success': 'اكتمل التصدير',
  'export_failed': 'تعذر تصدير السيرة',
  'export_cancelled': 'تم إلغاء التصدير',
  'export_quality': 'جودة التصدير',
  'quality_standard': 'قياسية',
  'quality_high': 'عالية',
  'customization': 'التخصيص',
  'font_family': 'الخط',
  'font_size': 'حجم الخط',
  'primary_color': 'اللون الرئيسي',
  'secondary_color': 'اللون الثانوي',
  'ats_checker': 'فحص ATS',
  'ats_score': 'نتيجة ATS',
  'ats_score_out_of': '@score من 100',
  'ats_recheck': 'إعادة الفحص',
  'ats_use_template': 'استخدام قالب ATS',
  'ats_edit_resume': 'انتقل للتعديل',
  'ats_issues': 'الملاحظات',
  'ats_suggestions': 'الاقتراحات',
  'ats_missing_keywords': 'الكلمات المفتاحية المفقودة',
  'ats_no_issues': 'لم تُكتشف ملاحظات وفق هذه القواعد',
  'ats_no_resume': 'اختر سيرة أو أنشئ سيرة لبدء الفحص',
  'ats_checking': 'جارٍ تحليل السيرة…',
  'ats_guidance':
      'هذا تقييم إرشادي قائم على قواعد، ولا يضمن القبول لدى أنظمة التوظيف.',
  'ats_formatting_note':
      'يعتمد فحص التنسيق على إعداد القالب، وليس على تحليل ملف PDF مصدّر.',
  'ats_template_applied': 'تم حفظ قالب ATS',
  'ats_section_contact': 'بيانات الاتصال',
  'ats_section_summary': 'الملخص المهني',
  'ats_section_experience': 'الخبرة',
  'ats_section_education': 'التعليم',
  'ats_section_skills': 'المهارات',
  'ats_section_keywords': 'الكلمات المفتاحية',
  'ats_section_formatting': 'التنسيق',
  'ats_severity_critical': 'حرجة',
  'ats_severity_warning': 'تنبيه',
  'ats_severity_info': 'معلومة',
  'ats_keyword_teamwork': 'العمل الجماعي',
  'ats_keyword_leadership': 'القيادة',
  'ats_keyword_communication': 'التواصل',
  'ats_keyword_problem_solving': 'حل المشكلات',
  'time_just_now': 'الآن',
  'time_ago': 'منذ @count @unit',
  'time_in': 'خلال @count @unit',
  'time_minute': 'دقيقة',
  'time_minutes': 'دقيقة',
  'time_hour': 'ساعة',
  'time_hours': 'ساعة',
  'time_day': 'يوم',
  'time_days': 'يوم',
  'ats_issue_name': 'السيرة لا تحتوي على اسم.',
  'ats_fix_name': 'أضف اسمك الكامل.',
  'ats_issue_email': 'البريد الإلكتروني مفقود أو غير صالح.',
  'ats_fix_email': 'أضف بريداً إلكترونياً صالحاً.',
  'ats_issue_phone': 'رقم الهاتف مفقود أو غير صالح.',
  'ats_fix_phone': 'أضف رقم هاتف صالحاً.',
  'ats_issue_linkedin': 'رابط LinkedIn صالح مفقود.',
  'ats_fix_linkedin': 'أضف رابط ملفك الكامل في LinkedIn.',
  'ats_issue_website': 'رابط الموقع أو معرض الأعمال مفقود.',
  'ats_fix_website': 'أضف رابط موقع أو معرض أعمال مناسب.',
  'ats_issue_summary_missing': 'الملخص المهني مفقود.',
  'ats_fix_summary_missing': 'اكتب ملخصاً مهنياً موجزاً.',
  'ats_issue_summary_length': 'طول الملخص خارج نطاق 50–300 حرف.',
  'ats_fix_summary_length': 'اجعل الملخص بين 50 و300 حرف.',
  'ats_issue_summary_keywords': 'الملخص يفتقر إلى كلمات وظيفية معروفة.',
  'ats_fix_summary_keywords': 'اذكر المهارات المرتبطة بالوظيفة في الملخص.',
  'ats_issue_experience_missing': 'لا توجد خبرة بمسمى وظيفي وشركة.',
  'ats_fix_experience_missing': 'أضف خبرة عمل أو تدريب أو تطوع مناسبة.',
  'ats_issue_experience_actions': 'أوصاف الخبرة تفتقر إلى أفعال إنجاز معروفة.',
  'ats_fix_experience_actions': 'صف إنجازاتك بأفعال مثل طورت أو قدت.',
  'ats_issue_experience_dates':
      'تواريخ الخبرة مفقودة أو غير مرتبة أو مستقبلية.',
  'ats_fix_experience_dates': 'استخدم MM/YYYY وحدد الوظائف المستمرة كعمل حالي.',
  'ats_issue_education_missing': 'التعليم يفتقر إلى المؤهل أو المؤسسة.',
  'ats_fix_education_missing': 'أضف المؤهل والمؤسسة التعليمية.',
  'ats_issue_education_year': 'سنة تخرج صالحة مفقودة.',
  'ats_fix_education_year': 'أضف سنة التخرج أو التخرج المتوقع بأربعة أرقام.',
  'ats_issue_skills_minimum': 'عدد المهارات المختلفة أقل من خمس.',
  'ats_fix_skills_minimum': 'أضف خمس مهارات مختلفة مرتبطة بالوظيفة على الأقل.',
  'ats_issue_skills_count': 'عدد المهارات المختلفة أقل من عشر.',
  'ats_fix_skills_count': 'أضف مهارات مناسبة إضافية تدعمها خبرتك.',
  'ats_issue_skills_diversity':
      'لم يظهر مزيج من المهارات التقنية والشخصية المعروفة.',
  'ats_fix_skills_diversity': 'اذكر مهارات تقنية وشخصية تستخدمها فعلياً.',
  'ats_issue_keywords_missing': 'لم تظهر كلمات المهارات العامة المعروفة.',
  'ats_fix_keywords_missing':
      'اذكر خبرة مناسبة في العمل الجماعي أو القيادة أو التواصل أو حل المشكلات.',
  'ats_issue_placeholders': 'ظهر نص تجريبي يحتاج إلى مراجعة.',
  'ats_fix_placeholders': 'استبدل النصوص التجريبية بمعلوماتك الصحيحة.',
  'ats_issue_photo': 'الإخراج المحدد يتضمن صورة.',
  'ats_fix_photo': 'استخدم قالب ATS لاستبعاد الصورة من الإخراج.',
  'ats_issue_font': 'الخط المحدد خارج قائمة الخطوط البسيطة.',
  'ats_fix_font': 'اختر Cairo أو Poppins أو استخدم قالب ATS.',
  'ats_issue_columns': 'لم يُعتمد تخطيط بعمود واحد لهذا الإعداد.',
  'ats_fix_columns': 'استخدم قالب ATS ذي العمود الواحد.',
  'ats_select_resume': 'اختر سيرة أو أنشئ سيرة قبل الفحص.',
  'ats_analysis_failed': 'تعذر تحليل السيرة. راجع بياناتها وأعد المحاولة.',
  'ats_save_failed': 'تعذر حفظ قالب ATS.',
  'ats_apply_failed': 'تعذر تطبيق قالب ATS.',
  'action_failed': 'تعذر إكمال العملية. أعد المحاولة.',
  'splash_tagline': 'أنشئ سيرتك الذاتية الاحترافية',
  'splash_preparing': 'جارٍ التجهيز…',
  'language_selection_title': 'اختر لغتك',
  'language_selection_subtitle':
      'اختر اللغة التي تفضلها. يمكنك تغييرها لاحقاً من الإعدادات.',
  'language_english': 'English',
  'language_arabic': 'العربية',
  'country_us': 'الولايات المتحدة',
  'country_sa': 'السعودية',
  'select_english': 'اختيار الإنجليزية',
  'select_arabic': 'اختيار العربية',
  'switch_to_english': 'استخدم التطبيق باللغة الإنجليزية',
  'switch_to_arabic': 'استخدم التطبيق باللغة العربية',
  'home_welcome': 'مرحباً بك!',
  'home_empty_description': 'ابدأ بإنشاء أول سيرة ذاتية احترافية لك.',
  'home_templates_description': 'اختر من تصاميمنا الاحترافية.',
  'home_recent_description': 'آخر السير الذاتية المحفوظة والتغييرات.',
  'show_recent': 'عرض الأحدث',
  'untitled_resume': 'سيرة بدون اسم',
  'no_templates_available': 'لا توجد قوالب متاحة',
  'template_position': '@current من @total',
  'add_favorite': 'إضافة إلى المفضلة',
  'remove_favorite': 'إزالة من المفضلة',
  'tip_action_verbs': 'استخدم أفعالاً قوية لوصف إنجازاتك.',
  'tip_tailor_resume': 'خصص سيرتك الذاتية لكل وظيفة تتقدم لها.',
  'tip_resume_length': 'اجعل سيرتك الذاتية موجزة ومرتبطة بالوظيفة.',
  'tip_relevant_skills': 'ركز على المهارات والخبرات الأكثر صلة بالوظيفة.',
  'tip_job_keywords': 'استخدم الكلمات المفتاحية المناسبة من وصف الوظيفة.',
  'clear_template_search': 'مسح البحث',
  'reset_template_filters': 'إعادة ضبط الفلاتر',
  'template_category_all': 'الكل',
  'template_category_ats': 'ATS',
  'template_category_business': 'أعمال',
  'template_category_classic': 'كلاسيكي',
  'template_category_modern': 'عصري',
  'template_category_technical': 'تقني',
  'favorite_remove_confirmation':
      'هل تريد إزالة «@name» من المفضلة؟ ستبقى السيرة محفوظة.',
  'favorites_empty_description': 'أضف سيرك المحفوظة إلى المفضلة لتظهر هنا.',
  'favorites_empty_title': 'لا توجد مفضلات بعد',
  'search_favorites': 'البحث في المفضلة',
  'change_profile_image': 'تغيير الصورة الشخصية',
  'profile_image_failed': 'تعذر اختيار الصورة الشخصية أو حفظها. حاول مرة أخرى.',
  'settings_data_description':
      'حذف جميع السير المحفوظة والمفضلة والصورة الشخصية والتفضيلات.',
  'settings_exit_confirmation':
      'هل تريد الخروج ومسح المسودة الحالية وتفضيل الصورة الشخصية؟ ستبقى السير المحفوظة.',
  'share_app_message': 'أنشئ سيراً ذاتية احترافية باستخدام CV Builder Pro.',
  'import_discard': 'تجاهل المعاينة',
  'import_edit_json': 'JSON السيرة القابل للتعديل',
  'import_empty': 'لا يحتوي الملف على نص.',
  'import_extension_mismatch': 'لا يطابق الملف المختار التنسيق المطلوب.',
  'import_invalid_json':
      'JSON السيرة غير صالح. استخدم كائناً يحتوي fullName كنص وحقول السيرة بأنواع صحيحة.',
  'import_invalid_pdf': 'ملف PDF تالف أو غير مدعوم.',
  'import_json_description':
      'يحفظ جميع أقسام السيرة. اختر ملف JSON بترميز UTF-8 أو UTF-16، بحد أقصى 10 ميغابايت.',
  'import_json_title': 'JSON — موصى به',
  'import_loading': 'جارٍ قراءة السيرة والتحقق منها…',
  'import_name_required': 'أدخل الاسم الكامل قبل الحفظ.',
  'import_paste_json': 'أو الصق JSON السيرة',
  'import_pdf_description':
      'يدعم ملفات PDF النصية البسيطة بأحرف ASCII، ومنها تدفقات Flate. لا يدعم الصور أو التشفير أو الخطوط المرمّزة. راجع المحتوى المستخرج.',
  'import_pdf_encrypted': 'لا يمكن استيراد PDF المحمي بكلمة مرور.',
  'import_pdf_font_unsupported':
      'يستخدم PDF ترميز خطوط غير مدعوم. استورد JSON أو انسخ نصه إلى ملف TXT بترميز UTF-8.',
  'import_pdf_no_text':
      'لم يُعثر على نص PDF مدعوم. الملفات المصوّرة تحتاج OCR؛ استخدم JSON أو TXT بدلاً منها.',
  'import_pdf_title': 'PDF — نص بسيط فقط',
  'import_preview': 'معاينة الاستيراد',
  'import_preview_description':
      'عدّل أي حقل في JSON الكامل أدناه، ثم احفظ نسخة جديدة وأكمل التعديل. يُعاد ضبط المعرّف والمفضلة ومسار الصورة المستوردة.',
  'import_preview_empty': 'ستظهر معاينة الاستيراد هنا',
  'import_preview_empty_description':
      'اختر ملفاً أو الصق JSON. لن تُحفظ بيانات قبل تأكيدك.',
  'import_read_failed':
      'تعذرت قراءة الملف. تحقق من صلاحية الوصول وحاول مرة أخرى.',
  'import_resume': 'استيراد سيرة',
  'import_save_edit': 'حفظ ومتابعة التعديل',
  'import_section_counts':
      'التعليم: @education • الخبرة: @experience • المهارات: @skills',
  'import_select_file': 'اختيار ملف @format',
  'import_text_encoding': 'احفظ الملف النصي بترميز UTF-8 أو UTF-16.',
  'import_too_large':
      'يتجاوز الملف 10 ميغابايت أو يتجاوز محتواه بعد فك الضغط الحد الآمن.',
  'import_txt_description':
      'يستخرج الاسم والبريد والهاتف والروابط والمهارات المفصولة بفواصل، ويحفظ النص الكامل في الملخص للمراجعة اليدوية.',
  'import_txt_title': 'TXT',
  'import_unsupported': 'اختر ملف JSON أو PDF أو TXT.',
};

```

## test/import_resume/import_service_test.dart

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';

Uint8List _pdf(String content, {bool compressed = false, String font = ''}) {
  final stream = compressed
      ? zlib.encode(ascii.encode(content))
      : ascii.encode(content);
  return Uint8List.fromList([
    ...ascii.encode(
      '%PDF-1.4\n$font\n1 0 obj\n<< /Length ${stream.length} ${compressed ? '/Filter /FlateDecode' : ''} >>\nstream\n',
    ),
    ...stream,
    ...ascii.encode('\nendstream\nendobj\n%%EOF'),
  ]);
}

Matcher _error(String key) => throwsA(
  isA<ImportException>().having((error) => error.messageKey, 'messageKey', key),
);

void main() {
  final service = ResumeImportService();
  test('full JSON round trip preserves every field', () {
    final resume = ResumeModel(
      fullName: 'عمر',
      id: 44,
      email: 'test@example.com',
      phone: '+966500000000',
      templateId: 'ats',
      summary: 'Summary',
      education: [
        Education(degree: 'BSc', institution: 'University', year: '2024'),
      ],
      experience: [
        Experience(
          jobTitle: 'Developer',
          company: 'Company',
          startDate: '01/2024',
          isCurrent: true,
        ),
      ],
      skills: [Skill(name: 'Dart')],
      courses: [
        Course.fromJson({'name': 'Course'}),
      ],
      certificates: [
        Certificate.fromJson({'name': 'Certificate'}),
      ],
      languages: [
        Language.fromJson({'name': 'English', 'level': 'Advanced'}),
      ],
      projects: [
        Project.fromJson({'name': 'Project'}),
      ],
      achievements: [
        Achievement.fromJson({'title': 'Award'}),
      ],
      interests: ['Reading'],
      linkedin: 'https://linkedin.com/in/test',
      github: 'https://github.com/test',
      website: 'https://example.com',
      portfolio: 'https://example.com/work',
      customization: {'fontSize': 12},
    );
    expect(service.fromJsonText(ResumeJson.encode(resume)), resume);
  });
  test('invalid schema and empty JSON are rejected with helpful keys', () {
    for (final source in [
      '',
      '[]',
      '{"email":"a"}',
      '{"fullName":"A","skills":"Dart"}',
      '{bad}',
    ]) {
      expect(() => service.fromJsonText(source), _error('import_invalid_json'));
    }
  });
  test('UTF8 BOM and UTF16 text are accepted', () {
    const json = '{"fullName":"عمر"}';
    expect(
      service
          .fromBytes(
            Uint8List.fromList([239, 187, 191, ...utf8.encode(json)]),
            'json',
          )
          .fullName,
      'عمر',
    );
    final utf16 = Uint8List.fromList([
      255,
      254,
      ...json.codeUnits.expand((code) => [code & 255, code >> 8]),
    ]);
    expect(service.fromBytes(utf16, 'json').fullName, 'عمر');
    expect(
      () => service.fromBytes(Uint8List.fromList([255, 0]), 'txt'),
      _error('import_text_encoding'),
    );
  });
  test('English text extracts contacts and skills and preserves source', () {
    const text =
        'Name: Alice\nEmail: alice@example.com\nPhone: +1 555 123 4567\nSkills: Dart, Flutter, Dart\nhttps://linkedin.com/in/alice\nEDUCATION\nBSc 2024';
    final result = service.fromPlainText(text);
    expect(result.fullName, 'Alice');
    expect(result.email, 'alice@example.com');
    expect(result.phone, '+1 555 123 4567');
    expect(result.skills.map((skill) => skill.name), ['Dart', 'Flutter']);
    expect(result.summary, text);
    expect(result.linkedin, 'https://linkedin.com/in/alice');
  });
  test('Arabic text labels and commas are extracted', () {
    final result = service.fromPlainText(
      'الاسم الكامل: عمر\nالهاتف: +966500000000\nالمهارات: برمجة، تواصل\nhttps://linkedin.com.evil.test/user',
    );
    expect(result.fullName, 'عمر');
    expect(result.phone, '+966500000000');
    expect(result.skills, hasLength(2));
    expect(result.linkedin, isNull);
  });
  for (final compressed in [false, true]) {
    test('simple PDF extraction compressed=$compressed', () {
      final result = service.fromBytes(
        _pdf(
          r'BT /F1 12 Tf (Alice) Tj (alice@example.com) Tj (Skills: Dart, Flutter) Tj ET',
          compressed: compressed,
        ),
        'pdf',
      );
      expect(result.fullName, 'Alice');
      expect(result.email, 'alice@example.com');
      expect(result.skills, hasLength(2));
    });
  }
  test('PDF escapes are decoded', () {
    final result = service.fromBytes(
      _pdf(r'BT (Alice \(Developer\)) Tj (Skills: D\141rt) Tj ET'),
      'pdf',
    );
    expect(result.fullName, 'Alice (Developer)');
    expect(result.skills.single.name, 'Dart');
  });
  test('PDF scans encryption and unsupported fonts fail explicitly', () {
    expect(
      () => service.fromBytes(_pdf('q Q'), 'pdf'),
      _error('import_pdf_no_text'),
    );
    expect(
      () => service.fromBytes(
        _pdf('BT (Alice) Tj ET', font: '/Encrypt 5 0 R'),
        'pdf',
      ),
      _error('import_pdf_encrypted'),
    );
    expect(
      () => service.fromBytes(
        _pdf('BT <00010002> Tj ET', font: '/Subtype /Type0'),
        'pdf',
      ),
      _error('import_pdf_font_unsupported'),
    );
    expect(
      () => service.fromBytes(
        Uint8List.fromList(ascii.encode('not a PDF')),
        'pdf',
      ),
      _error('import_invalid_pdf'),
    );
  });
  test('oversized empty and unknown formats fail', () {
    expect(
      () => service.fromBytes(Uint8List(0), 'txt'),
      _error('import_empty'),
    );
    expect(
      () => service.fromBytes(Uint8List(10 * 1024 * 1024 + 1), 'json'),
      _error('import_too_large'),
    );
    expect(
      () => service.fromBytes(Uint8List.fromList([65]), 'docx'),
      _error('import_unsupported'),
    );
  });
  test('compressed PDF expansion is bounded', () {
    final bomb = _pdf('A' * (21 * 1024 * 1024), compressed: true);
    expect(() => service.fromBytes(bomb, 'pdf'), _error('import_too_large'));
  });
}

```

## test/import_resume/import_screen_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/import_resume/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final saved = <ResumeModel>[];
  bool fail = false;
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    if (fail) throw Exception('disk failure');
    final value = resume.copyWith(id: saved.length + 1);
    saved.add(value);
    return value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Service extends ResumeImportService {
  ResumeModel? result;
  String? selected;
  bool fail = false;
  @override
  Future<ResumeModel?> pickAndImport(String extension) async {
    selected = extension;
    if (fail) throw const ImportException('import_invalid_pdf');
    return result;
  }
}

Widget _host(
  _Service service, {
  double scale = 1,
  bool arabic = false,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Locale(arabic ? 'ar' : 'en'),
  translations: AppTranslations(),
  theme: arabic ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: ImportResumeScreen(service: service),
  getPages: [
    GetPage(
      name: AppRoutes.resumeBuilder,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
  ],
);
Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Finder _field(String key) => find.descendant(
  of: find.byKey(ValueKey(key)),
  matching: find.byType(TextFormField),
);

void main() {
  tearDown(Get.reset);
  for (final width in [320.0, 800.0, 1920.0]) {
    testWidgets('import fits width $width with Arabic large text and preview', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, width == 800 ? 400 : 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final service = _Service()..result = ResumeModel(fullName: 'عمر');
      Get.put(ResumeController(repository: _Repository()));
      await tester.pumpWidget(_host(service, scale: 2, arabic: true));
      await tester.pumpAndSettle();
      final button = find.text(
        'import_select_file'.trParams({'format': 'JSON'}),
      );
      await _tap(tester, button);
      await tester.ensureVisible(
        find.byKey(const ValueKey('save-imported-resume')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ImportPreviewWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('paste preview edit save imports new ID and opens builder', (
    tester,
  ) async {
    final repository = _Repository();
    Get.put(ResumeController(repository: repository));
    ResumeModel? draft;
    await tester.pumpWidget(
      _host(_Service(), capture: (value) => draft = value as ResumeModel),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(_field('paste-resume-json'));
    await tester.enterText(
      _field('paste-resume-json'),
      '{"fullName":"Alice","id":999,"profilePicture":"/foreign/file","isFavorite":true,"skills":[{"name":"Dart","level":3}]}',
    );
    await _tap(tester, find.byKey(const ValueKey('parse-pasted-json')));
    expect(repository.saved, isEmpty);
    await tester.enterText(
      _field('import-preview-json'),
      '{"fullName":"Edited","id":999,"profilePicture":"/foreign/file","isFavorite":true,"skills":[{"name":"Flutter","level":3}]}',
    );
    await _tap(tester, find.byKey(const ValueKey('save-imported-resume')));
    expect(repository.saved.single.fullName, 'Edited');
    expect(draft!.id, 1);
    expect(draft!.profilePicture, isNull);
    expect(draft!.isFavorite, false);
    expect(draft!.skills.single.name, 'Flutter');
  });
  testWidgets('picker cancel leaves preview empty and PDF error is reported', (
    tester,
  ) async {
    Get.put(ResumeController(repository: _Repository()));
    final service = _Service();
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await _tap(
      tester,
      find.text('import_select_file'.trParams({'format': 'TXT'})),
    );
    expect(service.selected, 'txt');
    expect(find.byType(ImportPreviewWidget), findsNothing);
    service.fail = true;
    await _tap(
      tester,
      find.text('import_select_file'.trParams({'format': 'PDF'})),
    );
    expect(find.text('import_invalid_pdf'.tr), findsOneWidget);
  });
  testWidgets('invalid JSON does not create preview', (tester) async {
    final repository = _Repository();
    Get.put(ResumeController(repository: repository));
    await tester.pumpWidget(_host(_Service()));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('parse-pasted-json')));
    expect(find.text('import_invalid_json'.tr), findsOneWidget);
    expect(repository.saved, isEmpty);
  });
  testWidgets('failed save keeps editable preview', (tester) async {
    final repository = _Repository()..fail = true;
    Get.put(ResumeController(repository: repository));
    final service = _Service()..result = ResumeModel(fullName: 'Alice');
    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();
    await _tap(
      tester,
      find.text('import_select_file'.trParams({'format': 'JSON'})),
    );
    await _tap(tester, find.byKey(const ValueKey('save-imported-resume')));
    expect(find.byType(ImportPreviewWidget), findsOneWidget);
    expect(repository.saved, isEmpty);
  });
}

```

## test/home/home_test.dart

```dart
import 'package:carousel_slider/carousel_slider.dart' as carousel;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/home/index.dart';
import 'package:cv_builder_pro/translations/index.dart';

class _Repository implements ResumeRepository {
  final entries = List.generate(
    7,
    (index) => ResumeModel(
      id: index + 1,
      fullName: 'User ${index + 1}',
      createdAt: DateTime(2026, 1, index + 1),
      isFavorite: index < 3,
      skills: [
        Skill(name: 'Flutter'),
        Skill(name: 'Communication'),
        Skill(name: 'SQL'),
      ],
    ),
  );
  int loads = 0;
  int saves = 0;
  @override
  List<ResumeModel> loadResumes() {
    loads++;
    return entries.map((entry) => entry.copyWith()).toList();
  }

  @override
  Future<ResumeModel> saveResume(ResumeModel resume) async {
    saves++;
    final saved = resume.copyWith(
      id: resume.id ?? 99,
      updatedAt: DateTime.now(),
    );
    final index = entries.indexWhere((entry) => entry.id == saved.id);
    if (index < 0) {
      entries.add(saved);
    } else {
      entries[index] = saved;
    }
    return saved.copyWith();
  }

  @override
  Future<void> deleteResume(int id) async {
    entries.removeWhere((entry) => entry.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host({
  bool dark = false,
  double scale = 1,
  bool reducedMotion = true,
  void Function(Object?)? capture,
}) => GetMaterialApp(
  locale: Get.locale ?? const Locale('en', 'US'),
  translations: AppTranslations(),
  theme: dark ? AppTheme.dark : AppTheme.light,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reducedMotion,
    ),
    child: child!,
  ),
  home: const HomeScreen(),
  getPages: [
    GetPage(
      name: AppRoutes.importResume,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('import-marker')),
    ),
    GetPage(
      name: AppRoutes.resumeBuilder,
      transition: Transition.noTransition,
      page: () {
        capture?.call(Get.arguments);
        return const Scaffold(body: Text('builder-marker'));
      },
    ),
    GetPage(
      name: AppRoutes.templates,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('templates-marker')),
    ),
    GetPage(
      name: AppRoutes.favorites,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('favorites-marker')),
    ),
    GetPage(
      name: AppRoutes.settings,
      transition: Transition.noTransition,
      page: () => const Scaffold(body: Text('settings-marker')),
    ),
  ],
);

void size(WidgetTester tester, double width, [double height = 900]) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> reveal(WidgetTester tester, Finder target) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    if (target.hitTestable().evaluate().isNotEmpty) return;
    final viewport = tester.getRect(find.byKey(const ValueKey('home-scroll')));
    final exists = target.evaluate().isNotEmpty;
    final above = exists && tester.getCenter(target).dy < viewport.top;
    await tester.dragFrom(
      Offset(viewport.left + 6, viewport.center.dy),
      Offset(0, above ? 300 : -300),
    );
    await tester.pumpAndSettle();
  }
  throw StateError('Unable to reveal $target');
}

void main() {
  late _Repository repository;
  late ResumeController resumes;
  late TemplateController templates;
  void prepare() {
    resumes = Get.put(ResumeController(repository: repository));
    templates = Get.put(TemplateController());
  }

  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en', 'US');
    repository = _Repository();
  });
  tearDown(() {
    Get.reset();
  });

  testWidgets('Import action opens the import screen', (tester) async {
    prepare();
    await tester.pumpWidget(host());
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('import-resume'));
    await reveal(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('import-marker'), findsOneWidget);
  });

  testWidgets(
    'Statistics reflect all seven resumes, five templates and three favorites',
    (tester) async {
      prepare();
      await tester.pumpWidget(host());
      for (final value in ['7', '5', '3']) {
        expect(
          find.descendant(
            of: find.byType(StatsCards),
            matching: find.text(value),
          ),
          findsOneWidget,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Home responds at mobile, tablet, desktop and large Arabic text sizes',
    (tester) async {
      prepare();
      size(tester, 320);
      for (final entry in <double, double>{
        320: 2,
        600: 2,
        1200: 2,
        1920: 1,
      }.entries) {
        tester.view.physicalSize = Size(entry.key, 900);
        Get.locale = const Locale('ar', 'SA');
        await tester.pumpWidget(host(dark: true, scale: entry.value));
        await tester.pump();
        final expected = entry.key < 600 ? 'recent-list' : 'recent-grid';
        await reveal(tester, find.byKey(ValueKey(expected)));
        expect(find.byKey(ValueKey(expected)), findsOneWidget);
        await tester.pump();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        Get.reset();
        Get.testMode = true;
        resumes = Get.put(ResumeController(repository: repository));
        templates = Get.put(TemplateController());
      }
    },
  );

  testWidgets(
    'Carousel fractions are 0.85, 0.5 and 0.33 and manual controls work',
    (tester) async {
      prepare();
      size(tester, 390);
      for (final entry in <double, double>{
        390: 0.85,
        800: 0.5,
        1440: 0.33,
      }.entries) {
        tester.view.physicalSize = Size(entry.key, 1000);
        await tester.pumpWidget(host());
        final widget = tester.widget<carousel.CarouselSlider>(
          find.byType(carousel.CarouselSlider),
        );
        expect(widget.options.viewportFraction, entry.value);
        expect(widget.options.autoPlay, false);
        await reveal(tester, find.byTooltip('Next'));
        await tester.tap(find.byTooltip('Next'));
        await tester.pumpAndSettle();
        expect(find.text('2 of 5'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        Get.reset();
        Get.testMode = true;
        resumes = Get.put(ResumeController(repository: repository));
        templates = Get.put(TemplateController());
      }
    },
  );

  testWidgets(
    'View all displays older resumes instead of navigating to favorites',
    (tester) async {
      prepare();
      size(tester, 390);
      await tester.pumpWidget(host());
      expect(find.byKey(const ValueKey('recent-1')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('stat-0')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('recent-1')), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Create and use-template actions open the builder with the correct arguments',
    (tester) async {
      prepare();
      size(tester, 800, 1200);
      Object? argument;
      await tester.pumpWidget(
        host(
          capture: (value) {
            argument = value;
          },
        ),
      );
      await reveal(tester, find.byKey(const ValueKey('create-resume')));
      await tester.tap(find.byKey(const ValueKey('create-resume')));
      await tester.pumpAndSettle();
      expect(find.text('builder-marker'), findsOneWidget);
      expect(argument, isNull);
      Get.back<void>();
      await tester.pumpAndSettle();
      final use = find.byKey(const ValueKey('use-template-modern')).first;
      await reveal(tester, use);
      await tester.tap(use);
      await tester.pumpAndSettle();
      expect(argument, 'modern');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'Favorite and edit actions update live counts and pass an independent resume',
    (tester) async {
      prepare();
      size(tester, 800, 1200);
      Object? argument;
      await tester.pumpWidget(
        host(
          capture: (value) {
            argument = value;
          },
        ),
      );
      final card = find.byKey(const ValueKey('recent-7'));
      await reveal(tester, card);
      final favorite = find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('favorite-resume-7')),
      );
      await reveal(tester, favorite);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.widget<RecentActivityCard>(card).resume.id, 7);
      expect(tester.widget<IconButton>(favorite).onPressed, isNotNull);
      await tester.tap(favorite);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(
        repository.saves,
        1,
        reason:
            'Favorite should save without navigating; route: ${Get.currentRoute}',
      );
      expect(resumes.getFavoriteResumes(), hasLength(4));
      final edit = find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('edit-resume-7')),
      );
      await reveal(tester, edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      expect(argument, isA<ResumeModel>());
      final edited = argument as ResumeModel;
      expect(edited.id, 7);
      edited.fullName = 'Unsaved change';
      expect(
        resumes.resumes.firstWhere((resume) => resume.id == 7).fullName,
        'User 7',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Delete requires confirmation before removing a resume', (
    tester,
  ) async {
    prepare();
    size(tester, 800, 1200);
    await tester.pumpWidget(host());
    final card = find.byKey(const ValueKey('recent-7'));
    await reveal(tester, card);
    await reveal(
      tester,
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.pumpAndSettle();
    expect(resumes.resumes, hasLength(7));
    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('Cancel')),
    );
    await tester.pumpAndSettle();
    expect(resumes.resumes, hasLength(7));
    await tester.tap(
      find.descendant(
        of: card,
        matching: find.byKey(const ValueKey('delete-resume-7')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find
          .descendant(of: find.byType(Dialog), matching: find.text('Delete'))
          .last,
    );
    await tester.pump();
    expect(resumes.resumes, hasLength(6));
    expect(repository.entries.any((resume) => resume.id == 7), false);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Bottom navigation opens the selected destination', (
    tester,
  ) async {
    prepare();
    size(tester, 800);
    await tester.pumpWidget(host());
    final destination = find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.favorite_outline),
    );
    await tester.tap(destination);
    await tester.pumpAndSettle();
    expect(find.text('favorites-marker'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Empty data and invalid template colors render without crashes', (
    tester,
  ) async {
    prepare();
    size(tester, 320);
    resumes.resumes.clear();
    templates.templates.assignAll([
      const TemplateModel(
        id: 'custom',
        name: 'Custom',
        nameAr: 'مخصص',
        description: 'Description',
        descriptionAr: 'وصف',
        type: 'classic',
        language: 'en',
        previewColor: 'invalid',
        isFeatured: true,
      ),
    ]);
    await tester.pumpWidget(host(scale: 3));
    await reveal(tester, find.text('No resumes found'));
    expect(find.text('No resumes found'), findsOneWidget);
    expect(tester.takeException(), isNull);
    templates.templates.clear();
    await tester.pump();
    expect(find.text('No templates are available'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

```
