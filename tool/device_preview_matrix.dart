import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cv_builder_pro/app/theme/app_theme.dart';
import 'package:cv_builder_pro/controllers/resume_controller.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';
import 'package:cv_builder_pro/features/resume_builder/presentation/pages/preview_screen.dart';
import 'package:cv_builder_pro/translations/app_translations.dart';

/// Device-only visual QA repository: never reads or writes the user's resumes.
class MatrixRepository implements ResumeRepository {
  @override
  List<ResumeModel> loadResumes() => [];
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Read-only QA');
}

/// Real PDF exporter with an extra copy of the generated test document.
class MatrixExport extends PdfExportService {
  MatrixExport(this.id);
  final String id;
  @override
  Future<Uint8List> generate(
    ResumeModel resume, {
    String locale = 'en',
    PdfExportQuality quality = PdfExportQuality.standard,
  }) async {
    final bytes = await super.generate(
      resume,
      locale: locale,
      quality: quality,
    );
    final directory = Directory(
      '${(await getTemporaryDirectory()).path}/cv_qa_matrix_v5',
    );
    await directory.create(recursive: true);
    await File('${directory.path}/$id.pdf').writeAsBytes(bytes, flush: true);
    debugPrint('MATRIX_READY $id');
    return bytes;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ResumeController(repository: MatrixRepository()));
  runApp(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en'),
      home: const MatrixScreen(),
    ),
  );
}

/// Drives actual PreviewScreen states; PDF rendering is never mocked.
class MatrixScreen extends StatefulWidget {
  const MatrixScreen({super.key});
  @override
  State<MatrixScreen> createState() => _MatrixScreenState();
}

class _MatrixScreenState extends State<MatrixScreen> {
  static const multipage = bool.fromEnvironment('QA_MULTIPAGE');
  static const extraPages = [54, 55, 58, 59, 60, 61, 66, 67, 70, 71];
  int index = multipage ? extraPages.first : 0;
  late MatrixExport exporter;
  String get template =>
      ['modern', 'classic', 'business', 'technical', 'ats'][index ~/ 18];
  String get language => ['ar', 'en', 'mixed'][(index ~/ 6) % 3];
  String get font => ['Cairo', 'Sukar', 'Poppins'][(index ~/ 2) % 3];
  bool get dark => index.isOdd;
  String get id =>
      '${index.toString().padLeft(2, '0')}_${template}_${language}_${font}_${dark ? 'dark' : 'light'}';
  @override
  void initState() {
    super.initState();
    prepare();
  }

  void prepare() {
    Get.locale = Locale(language == 'en' ? 'en' : 'ar');
    String t(String ar, String en) => language == 'en'
        ? en
        : language == 'ar'
        ? ar
        : '$ar | $en';
    Get.find<ResumeController>().currentResume.value = ResumeModel(
      templateId: template,
      fullName: t('عمر أحمد', 'Omar Ahmed'),
      email: 'omar@example.com',
      phone: '+966500123456',
      address: t('الرياض', 'Riyadh'),
      summary: t(
        'مطور تطبيقات بخبرة 5 سنوات. تحسين الأداء بنسبة 30%.',
        'Developer with 5 years of experience. Improved performance by 30%.',
      ),
      experience: [
        Experience(
          jobTitle: t('مطور تطبيقات', 'Mobile Developer'),
          company: 'Studio',
          startDate: '01/2021',
          endDate: '12/2024',
          description: t('تطوير حلول موثوقة.', 'Developed reliable software.'),
        ),
      ],
      education: [
        Education(
          degree: t('بكالوريوس حاسب', 'BSc Computer Science'),
          institution: 'University',
          year: '2020',
        ),
      ],
      skills: [
        Skill(name: 'Flutter / Dart', level: 5),
        Skill(name: t('تواصل', 'Communication'), level: 4),
      ],
      projects: [
        Project(
          name: 'CV Builder',
          description: t('تطبيق للسير الذاتية.', 'Accessible resume builder.'),
          startDate: '01/2024',
          endDate: '06/2024',
        ),
      ],
      languages: [
        Language(
          name: t('العربية والإنجليزية', 'Arabic and English'),
          level: 'advanced',
        ),
      ],
      customization: {'fontFamily': font, 'fontSize': 9.0},
    );
    exporter = MatrixExport(id);
  }

  void next() {
    if (multipage) {
      final position = extraPages.indexOf(index);
      if (position < extraPages.length - 1) {
        setState(() {
          index = extraPages[position + 1];
          prepare();
        });
      }
      return;
    }
    if (index < 89) {
      setState(() {
        index++;
        prepare();
      });
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.forLocale(
      dark ? Brightness.dark : Brightness.light,
      Get.locale!,
    ),
    child: Directionality(
      textDirection: language == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(id, style: const TextStyle(fontSize: 11)),
                      ),
                      TextButton(onPressed: next, child: const Text('QA NEXT')),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PreviewScreen(
                  key: ValueKey(id),
                  exportService: exporter,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
