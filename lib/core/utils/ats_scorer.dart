import '../../data/models/resume_model.dart';
import 'date_formatter.dart';

/// Deterministic ATS scoring rules; these are application heuristics.
abstract final class AtsScorer {
  static const sectionMaximums = <String, int>{
    'contact': 20,
    'summary': 15,
    'experience': 20,
    'education': 10,
    'skills': 15,
    'keywords': 10,
    'formatting': 10,
  };

  static const keywordGroups = <String, List<String>>{
    'teamwork': ['teamwork', 'team work', 'العمل الجماعي', 'التعاون'],
    'leadership': ['leadership', 'القيادة', 'قيادة'],
    'communication': ['communication', 'التواصل', 'تواصل'],
    'problem-solving': [
      'problem-solving',
      'problem solving',
      'حل المشكلات',
      'حل المشاكل',
    ],
  };

  static const technicalTerms = [
    'dart',
    'flutter',
    'python',
    'java',
    'javascript',
    'typescript',
    'sql',
    'excel',
    'figma',
    'git',
    'c++',
    'c#',
    'html',
    'css',
    'aws',
    'docker',
    'data analysis',
    'programming',
    'تحليل البيانات',
    'البرمجة',
    'برمجة',
  ];

  static const actionVerbs = [
    'led',
    'managed',
    'developed',
    'increased',
    'delivered',
    'implemented',
    'designed',
    'achieved',
    'optimized',
    'built',
    'created',
    'reduced',
    'قاد',
    'قدت',
    'أدار',
    'أدرت',
    'طور',
    'طورت',
    'حققت',
    'حقق',
    'صممت',
    'نفذت',
    'حسنت',
    'خفضت',
    'أنجزت',
  ];

  static const reviewTerms = [
    'lorem ipsum',
    'your name',
    'insert here',
    'تحتاج إلى مراجعة',
    'نص تجريبي',
    'اسمك هنا',
  ];

  static String normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'[أإآ]'), 'ا')
      .replaceAll(RegExp(r'[-_\u2010-\u2015]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static bool containsTerm(String text, String term) {
    final escaped = RegExp.escape(normalize(term));
    if (escaped.isEmpty) return false;
    return RegExp(
      r'(^|[^a-z0-9\u0600-\u06ff])' + escaped + r'(?=$|[^a-z0-9\u0600-\u06ff])',
    ).hasMatch(normalize(text));
  }

  static bool containsAny(String text, Iterable<String> terms) =>
      terms.any((term) => containsTerm(text, term));

  static bool validEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim());

  static bool validPhone(String value) => RegExp(
    r'^\+?[0-9]{7,15}$',
  ).hasMatch(value.replaceAll(RegExp(r'[\s()\-]'), ''));

  static bool validUrl(String? value, {String? host}) {
    final text = value?.trim() ?? '';
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !['http', 'https'].contains(uri.scheme) ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(text)) {
      return false;
    }
    return host == null || uri.host == host || uri.host.endsWith('.$host');
  }

  static int contact(ResumeModel resume) =>
      (validEmail(resume.email) ? 5 : 0) +
      (validPhone(resume.phone) ? 5 : 0) +
      (validUrl(resume.linkedin, host: 'linkedin.com') ? 5 : 0) +
      (validUrl(resume.website) || validUrl(resume.portfolio) ? 5 : 0);

  static int summary(ResumeModel resume) {
    final text = resume.summary?.trim() ?? '';
    return (text.isNotEmpty ? 5 : 0) +
        (text.length >= 50 && text.length <= 300 ? 5 : 0) +
        (containsAny(text, [
              ...keywordGroups.values.expand((terms) => terms),
              ...technicalTerms,
            ])
            ? 5
            : 0);
  }

  static bool validExperienceDates(ResumeModel resume, {DateTime? now}) {
    if (resume.experience.isEmpty) return false;
    final today = now ?? DateTime.now();
    final month = DateTime(today.year, today.month);
    return resume.experience.every((entry) {
      final start = DateFormatter.parseMonthYear(entry.startDate);
      if (start == null || start.isAfter(month)) return false;
      if (entry.isCurrent) return true;
      final end = DateFormatter.parseMonthYear(entry.endDate);
      return end != null && !end.isBefore(start) && !end.isAfter(month);
    });
  }

  static int experience(ResumeModel resume, {DateTime? now}) {
    final hasEntry = resume.experience.any(
      (entry) =>
          entry.jobTitle.trim().isNotEmpty && entry.company.trim().isNotEmpty,
    );
    final hasVerb = resume.experience.any(
      (entry) =>
          entry.jobTitle.trim().isNotEmpty &&
          entry.company.trim().isNotEmpty &&
          containsAny(entry.description ?? '', actionVerbs),
    );
    return (hasEntry ? 5 : 0) +
        (hasVerb ? 10 : 0) +
        (hasEntry && validExperienceDates(resume, now: now) ? 5 : 0);
  }

  static int education(ResumeModel resume, {DateTime? now}) {
    final entries = resume.education.where(
      (entry) =>
          entry.degree.trim().isNotEmpty && entry.institution.trim().isNotEmpty,
    );
    final yearLimit = (now ?? DateTime.now()).year + 10;
    final hasYear = entries.any((entry) {
      final year = int.tryParse(entry.year.trim());
      return RegExp(r'^[0-9]{4}$').hasMatch(entry.year.trim()) &&
          year != null &&
          year >= 1900 &&
          year <= yearLimit;
    });
    return (entries.isNotEmpty ? 5 : 0) + (hasYear ? 5 : 0);
  }

  static Set<String> uniqueSkills(ResumeModel resume) => resume.skills
      .map((entry) => normalize(entry.name))
      .where((name) => name.isNotEmpty)
      .toSet();

  static bool diverseSkills(ResumeModel resume) {
    final names = uniqueSkills(resume);
    return names.any((name) => containsAny(name, technicalTerms)) &&
        names.any(
          (name) =>
              containsAny(name, keywordGroups.values.expand((terms) => terms)),
        );
  }

  static int skills(ResumeModel resume) {
    final count = uniqueSkills(resume).length;
    return (count >= 5 ? 5 : 0) +
        (count >= 10 ? 5 : 0) +
        (diverseSkills(resume) ? 5 : 0);
  }

  static String searchableText(ResumeModel resume) => [
    resume.summary ?? '',
    ...resume.experience.map(
      (entry) => '${entry.jobTitle} ${entry.description ?? ''}',
    ),
    ...resume.education.map(
      (entry) => '${entry.degree} ${entry.description ?? ''}',
    ),
    ...resume.skills.map((entry) => entry.name),
    ...resume.courses.map((entry) => entry.name),
    ...resume.certificates.map((entry) => entry.name),
    ...resume.projects.map(
      (entry) =>
          '${entry.name} ${entry.description} ${entry.technologies.join(' ')}',
    ),
    ...resume.achievements.map((entry) => '${entry.name} ${entry.description}'),
    ...?resume.interests,
  ].join('\n');

  static int keywords(ResumeModel resume) {
    final text = searchableText(resume);
    return (containsAny(text, keywordGroups.values.expand((terms) => terms))
            ? 5
            : 0) +
        (!containsAny(text, reviewTerms) ? 5 : 0);
  }

  static int formatting({
    required bool hasPhoto,
    required bool simpleFont,
    required bool singleColumn,
  }) => (!hasPhoto ? 3 : 0) + (simpleFont ? 3 : 0) + (singleColumn ? 4 : 0);

  static Map<String, int> sectionScores(
    ResumeModel resume, {
    required bool hasPhoto,
    required bool simpleFont,
    required bool singleColumn,
    DateTime? now,
  }) => {
    'contact': contact(resume),
    'summary': summary(resume),
    'experience': experience(resume, now: now),
    'education': education(resume, now: now),
    'skills': skills(resume),
    'keywords': keywords(resume),
    'formatting': formatting(
      hasPhoto: hasPhoto,
      simpleFont: simpleFont,
      singleColumn: singleColumn,
    ),
  };
}
