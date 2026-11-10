import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cv_builder_pro/main.dart' as application;
import 'package:cv_builder_pro/app/routes/app_routes.dart';
import 'package:cv_builder_pro/controllers/index.dart';
import 'package:cv_builder_pro/core/services/pdf_export_service.dart';
import 'package:cv_builder_pro/data/index.dart';

/// Complete, mixed-script fixture shared across all ten native previews.
ResumeModel verificationResume(String id) => ResumeModel(
  templateId: id,
  fullName: 'أحمد محمد العُمري',
  email: 'ahmed.omari@example.com',
  phone: '+966501234567',
  address: 'الرياض، السعودية',
  summary:
      'Senior Software Engineer\nمهندس برمجيات بخبرة 8+ سنوات في تطوير تطبيقات موثوقة وقابلة للتوسع باستخدام Flutter وPython. قيادة الفرق وتحسين الأداء بنسبة 35%.',
  education: [
    Education(
      degree: 'بكالوريوس علوم حاسب',
      institution: 'جامعة الملك سعود',
      year: '2016',
      description: '2012–2016',
    ),
  ],
  experience: [
    Experience(
      jobTitle: 'Senior Software Engineer',
      company: 'Google',
      startDate: '01/2020',
      isCurrent: true,
      description:
          'Led teams developing reliable applications.\nقيادة فريق هندسي وتحسين الأداء بنسبة 35%.',
    ),
    Experience(
      jobTitle: 'Software Engineer',
      company: 'Microsoft',
      startDate: '01/2018',
      endDate: '12/2020',
      description:
          'Developed cloud services using Python and AWS.\nتطوير خدمات سحابية ومراجعة جودة البرمجيات.',
    ),
  ],
  skills: [
    for (final name in ['Flutter', 'Dart', 'Python', 'React', 'AWS'])
      Skill(name: name, level: 5),
  ],
  languages: [
    Language(name: 'العربية', level: 'أصلية'),
    Language(name: 'English', level: 'Fluent'),
  ],
  projects: [
    Project(
      name: 'منصة إدارة المشاريع | Project Hub',
      description: 'تطبيق متجاوب لإدارة المشاريع ومتابعة فرق العمل.',
      startDate: '01/2024',
      endDate: '12/2024',
      technologies: ['Flutter', 'AWS'],
    ),
  ],
  achievements: [
    Achievement(
      name: 'Engineering Excellence Award',
      description: 'جائزة التميز الهندسي وتحسين تجربة المستخدم.',
      date: '2024',
    ),
  ],
  certificates: [
    Certificate(
      name: 'AWS Solutions Architect',
      organization: 'Amazon Web Services',
      year: '2023',
    ),
  ],
  interests: ['القراءة', 'Open-source software'],
  customization: {
    'fontFamily': id.endsWith('_en') ? 'Poppins' : 'Cairo',
    'fontSize': 10.0,
    'verificationCase': id,
  },
);

/// Device QA launcher: opens production routes and retains the real repository.
class DeviceVerificationLauncher extends StatelessWidget {
  const DeviceVerificationLauncher({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Device verification')),
    body: ListView(
      children: [
        for (final id in [
          'modern',
          'classic',
          'business',
          'technical',
          'ats',
          'modern_en',
          'classic_en',
          'business_en',
          'technical_en',
          'ats_en',
        ])
          ListTile(
            title: Text('Create $id'),
            onTap: () async {
              await Get.find<LanguageController>().changeLanguage(
                id.endsWith('_en') ? 'en' : 'ar',
              );
              await Get.toNamed<void>(
                AppRoutes.resumeBuilder,
                arguments:
                    Get.find<ResumeController>().resumes
                        .where(
                          (r) => r.customization?['verificationCase'] == id,
                        )
                        .lastOrNull
                        ?.copyWith() ??
                    verificationResume(id),
              );
            },
          ),
        ListTile(
          title: const Text('Import real files'),
          onTap: () => Get.toNamed<void>(AppRoutes.importResume),
        ),
        ListTile(
          title: const Text('Home'),
          onTap: () => Get.toNamed<void>(AppRoutes.home),
        ),
      ],
    ),
  );
}

/// Launches native review and archives equivalent PDF input/output for auditing.
Future<void> main() async {
  await application.main();
  Timer(const Duration(seconds: 5), () async {
    if (const bool.fromEnvironment('QA_REIMPORT_ONLY')) {
      final controller = Get.find<ResumeController>();
      // Only these exact records were created by this task's two PDF imports.
      for (final id in [1793305803222641, 1793306405143387]) {
        final record = controller.resumes.where((r) => r.id == id).firstOrNull;
        if (record != null &&
            record.email == 'omar.alomary129@gmail.com' &&
            record.phone == '+967779218017' &&
            ['عمر العمري', 'Omar Al-Omari'].contains(record.fullName)) {
          await controller.deleteResume(id);
        }
      }
    }
    Get.offAll<void>(() => const DeviceVerificationLauncher());
  });
  var previous = '';
  var writing = false;
  Timer.periodic(const Duration(seconds: 1), (_) async {
    if (writing) return;
    if (Get.currentRoute != AppRoutes.preview) {
      previous = '';
      return;
    }
    final resume = Get.find<ResumeController>().currentResume.value?.copyWith();
    if (resume == null) return;
    final key =
        '${resume.customization?['verificationCase'] ?? 'import'}_${resume.templateId}_${Get.locale?.languageCode}';
    if (previous == key) return;
    writing = true;
    try {
      final directory = Directory(
        '${(await getTemporaryDirectory()).path}/device_verify_20261029',
      );
      await directory.create(recursive: true);
      final bytes = await PdfExportService().generate(
        resume,
        locale: Get.locale?.languageCode ?? 'en',
      );
      await File('${directory.path}/$key.pdf').writeAsBytes(bytes, flush: true);
      await File(
        '${directory.path}/$key.json',
      ).writeAsString(jsonEncode(resume.toJson()), flush: true);
      previous = key;
      debugPrint('DEVICE_VERIFY_READY $key');
    } catch (error) {
      debugPrint('DEVICE_VERIFY_ERROR $error');
    } finally {
      writing = false;
    }
  });
}
