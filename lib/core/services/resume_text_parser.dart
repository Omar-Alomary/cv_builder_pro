import '../../data/index.dart';

/// Parses explicit bilingual section headings without mixing adjacent sections.
abstract final class ResumeTextParser {
  static String _key(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064b-\u065f\u0670ـ:：&]'), '')
      .replaceAll('ی', 'ي')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  static const _headings = {
    'professional profile': 'summary',
    'professional summary': 'summary',
    'summary': 'summary',
    'profile': 'summary',
    'الملخص المهني': 'summary',
    'ملخص مهني': 'summary',
    'نبذة شخصية': 'summary',
    'technical skills': 'skills',
    'skills': 'skills',
    'المهارات التقنية': 'skills',
    'المهارات': 'skills',
    'work experience': 'experience',
    'professional experience': 'experience',
    'experience': 'experience',
    'الخبرات العملية': 'experience',
    'الخبرات المهنية': 'experience',
    'الخبرة': 'experience',
    'education training': 'education',
    'education and training': 'education',
    'education': 'education',
    'التعليم والتدريب': 'education',
    'التعليم': 'education',
    'المؤهلات العلمية': 'education',
    'projects': 'projects',
    'المشاريع': 'projects',
    'المشروعات': 'projects',
    'certifications': 'certificates',
    'certificates': 'certificates',
    'الشهادات': 'certificates',
    'language skills': 'languages',
    'languages': 'languages',
    'المهارات اللغوية': 'languages',
    'اللغات': 'languages',
    'courses': 'courses',
    'الدورات': 'courses',
    'achievements': 'achievements',
    'الانجازات': 'achievements',
    'interests': 'interests',
    'الاهتمامات': 'interests',
  };
  static final _date = RegExp(
    r'\b(?:\d{1,2}/\d{1,2}/\d{4}|\d{1,2}/\d{4}|(?:19|20)\d{2})\b',
  );
  static List<String> _dates(String line) {
    final dates = _date.allMatches(line).map((m) => m[0]!).toList();
    DateTime comparable(String date) {
      final parts = date.split('/').map(int.parse).toList();
      return DateTime(
        parts.last,
        parts.length > 1 ? parts[parts.length - 2] : 1,
        parts.length > 2 ? parts.first : 1,
      );
    }

    dates.sort((a, b) => comparable(a).compareTo(comparable(b)));
    return dates.map((date) {
      final p = date.split('/');
      return p.length == 3 ? '${p[1]}/${p[2]}' : date;
    }).toList();
  }

  static bool _current(String line) => RegExp(
    r'current|present|حتى|الآن|الان',
    caseSensitive: false,
  ).hasMatch(line);
  static String _clean(String line) =>
      line.replaceAll(RegExp(r'^[•●▪\s]+'), '').trim();

  static ResumeModel parse(String source) {
    final text = source
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll('\u00a0', ' ')
        .trim();
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where(
          (l) =>
              l.isNotEmpty &&
              !RegExp(
                r'^(?:Page\s+\d+\s*/\s*\d+|\d+\s*/\s*\d+\s+صفحة|صفحة\s+\d+\s*/\s*\d+)$',
                caseSensitive: false,
              ).hasMatch(l),
        )
        .toList();
    final sections = <String, List<String>>{};
    final contact = <String>[];
    String? active;
    for (final line in lines) {
      final heading = _headings[_key(line)];
      if (heading != null) {
        active = heading;
        sections.putIfAbsent(active, () => []);
        continue;
      }
      if (active == null) {
        contact.add(line);
      } else {
        sections[active]!.add(line);
      }
    }
    String? labeled(String labels) => RegExp(
      '^(?:$labels)\\s*[:：]\\s*(.+)\$',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(text)?.group(1)?.trim();
    final email =
        RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}').firstMatch(text)?[0] ?? '';
    final parenthesized = RegExp(
      r'\(\+(\d{1,4})\)\s*(\d[\d -]{5,}\d)',
    ).firstMatch(contact.join('\n'));
    final phone = parenthesized != null
        ? '+${parenthesized[1]}${parenthesized[2]!.replaceAll(RegExp(r'\D'), '')}'
        : labeled('phone|mobile|هاتف|الهاتف|الجوال') ??
              RegExp(
                r'(?:\+?\d[\d ()-]{6,}\d)',
              ).firstMatch(contact.join('\n'))?[0] ??
              '';
    String? address = labeled('address|location|العنوان|الموقع');
    if (address == null) {
      for (var i = 0; i < contact.length; i++) {
        final contactLine = contact[i].replaceAll(
          RegExp(r'Email\s+address\s*:', caseSensitive: false),
          'Email:',
        );
        final m = RegExp(
          r'(?:Address|العنوان)\s*[:：]\s*(.*)$',
          caseSensitive: false,
        ).firstMatch(contactLine);
        if (m != null) {
          address = m[1]!.isNotEmpty
              ? m[1]
              : (i + 1 < contact.length ? contact[i + 1] : null);
          break;
        }
      }
    }
    final links = RegExp(
      r'(?:https?://|www\.|github\.com/|linkedin\.com/)[^\s<>]+',
      caseSensitive: false,
    ).allMatches(text).map((m) => m[0]!).toList();
    String? link(String domain) {
      for (final raw in links) {
        final url = raw.startsWith('http') ? raw : 'https://$raw';
        final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
        if (host == domain || host.endsWith('.$domain')) return url;
      }
      return null;
    }

    final skills = <String>{};
    final skillLines = sections['skills'] ?? [];
    final inlineSkills = labeled('skills|المهارات');
    final skillGroups = <String>[];
    var categorized = false;
    for (final line in skillLines) {
      if (line.contains(':')) {
        skillGroups.add(line);
        categorized = true;
      } else if (categorized && skillGroups.isNotEmpty) {
        // PDF line wrapping must not split a phrase into separate skills.
        skillGroups[skillGroups.length - 1] += ' $line';
      } else {
        skillGroups.add(line);
      }
    }
    for (final line in [...skillGroups, ?inlineSkills]) {
      final value = line.contains(':')
          ? line.substring(line.indexOf(':') + 1)
          : line;
      for (final part in value.split(RegExp(r'[,،;؛|\n]'))) {
        final skill = _clean(part)
            .replaceFirst(RegExp(r'^[.،]\s+'), '')
            .replaceAll(RegExp(r'[.،]+$'), '')
            .trim();
        if (skill.isNotEmpty &&
            !skills.any((s) => s.toLowerCase() == skill.toLowerCase())) {
          skills.add(skill);
        }
      }
    }
    final education = <Education>[];
    final edu = sections['education'] ?? [];
    for (var i = 0; i < edu.length; i++) {
      if (!RegExp(
        r'bachelor|master|degree|bsc|msc|بكالوريوس|ماجستير|دكتوراه|دبلوم',
        caseSensitive: false,
      ).hasMatch(edu[i])) {
        continue;
      }
      final degree = edu[i];
      final next = i + 1 < edu.length ? edu[i + 1] : '';
      final dates = _dates('$degree $next');
      education.add(
        Education(
          degree: degree.replaceAll(RegExp(r'\[[^\]]*\]'), '').trim(),
          institution: next
              .replaceAll(RegExp(r'[\[\]][^\[\]]*[\[\]]'), '')
              .trim(),
          year: dates.isEmpty ? '' : dates.last.split('/').last,
        ),
      );
    }
    final experience = <Experience>[];
    final work = sections['experience'] ?? [];
    final workDates = [
      for (var i = 0; i < work.length; i++)
        if (_dates(work[i]).isNotEmpty && !work[i].startsWith('•')) i,
    ];
    for (var d = 0; d < workDates.length; d++) {
      final at = workDates[d], dates = _dates(work[at]);
      final inline = work[at]
          .replaceAll(_date, '')
          .replaceAll(
            RegExp(r'[\[\]()]|current|present|حتى الآن', caseSensitive: false),
            '',
          )
          .replaceAll(RegExp(r'^\s*[-–—]+|[-–—]+\s*$'), '')
          .trim();
      final headers = at >= 2
          ? work.sublist(at - 2, at)
          : work.take(at).toList();
      final end = d + 1 < workDates.length
          ? (workDates[d + 1] - 2).clamp(at + 1, work.length)
          : work.length;
      var company = headers.isEmpty ? '' : headers.first;
      var title = headers.length > 1
          ? headers.last
          : headers.isEmpty
          ? ''
          : headers.first;
      if (inline.contains('@')) {
        final parts = inline.split('@');
        title = parts.first.trim();
        company = parts.last.trim();
      }
      experience.add(
        Experience(
          jobTitle: title,
          company: company,
          startDate: dates.first,
          endDate: _current(work[at])
              ? null
              : dates.length > 1
              ? dates.last
              : null,
          isCurrent: _current(work[at]),
          description: work.sublist(at + 1, end).map(_clean).join('\n'),
        ),
      );
    }
    final projects = <Project>[];
    final projectLines = sections['projects'] ?? [];
    final projectDates = [
      for (var i = 0; i < projectLines.length; i++)
        if (_dates(projectLines[i]).isNotEmpty &&
            !projectLines[i].startsWith('•'))
          i,
    ];
    for (var d = 0; d < projectDates.length; d++) {
      final at = projectDates[d];
      if (at + 1 >= projectLines.length) continue;
      final dates = _dates(projectLines[at]);
      final title = projectLines[at + 1].split('|');
      final end = d + 1 < projectDates.length
          ? projectDates[d + 1]
          : projectLines.length;
      projects.add(
        Project(
          name: title.first.trim(),
          startDate: dates.first,
          endDate: dates.length > 1 ? dates.last : null,
          description: projectLines.sublist(at + 2, end).map(_clean).join('\n'),
          technologies: title.length > 1
              ? title.last
                    .replaceFirst(RegExp(r'^.*?:'), '')
                    .split(RegExp(r'[,،]'))
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList()
              : [],
        ),
      );
    }
    final certificates = <Certificate>[];
    final certs = sections['certificates'] ?? [];
    for (var i = 0; i < certs.length; i++) {
      final dates = _dates(certs[i]);
      if (dates.isEmpty || i + 1 >= certs.length) continue;
      certificates.add(
        Certificate(
          name: certs[i + 1],
          organization: certs[i]
              .replaceAll(RegExp(r'[\[\]]'), '')
              .replaceAll(_date, '')
              .replaceAll(RegExp(r'^[,،\s]+|[,،\s]+$'), '')
              .trim(),
          year: dates.last.split('/').last,
        ),
      );
      i++;
    }
    final languages = <Language>[];
    for (final line in sections['languages'] ?? <String>[]) {
      for (final pair in [('Arabic', 'العربية'), ('English', 'الإنجليزية')]) {
        if (!line.toLowerCase().contains(pair.$1.toLowerCase()) &&
            !line.contains(pair.$2)) {
          continue;
        }
        if (languages.any((l) => l.name == pair.$1 || l.name == pair.$2)) {
          continue;
        }
        final arabic = line.contains(pair.$2);
        final native = RegExp(
          r'mother|native|الام|الأم|اصلية|أصلية',
          caseSensitive: false,
        ).hasMatch(line);
        languages.add(
          Language(
            name: arabic ? pair.$2 : pair.$1,
            level: native ? 'Native' : line.split(RegExp(r'[:：—]')).last.trim(),
          ),
        );
      }
    }
    return ResumeModel(
      fullName:
          labeled('full name|name|الاسم|الاسم الكامل') ??
          (contact.isEmpty ? lines.first : contact.first),
      email: email,
      phone: phone,
      address: address,
      summary: sections['summary']?.join('\n') ?? text,
      education: education,
      experience: experience,
      skills: skills.map((s) => Skill(name: s)).toList(),
      projects: projects,
      certificates: certificates,
      languages: languages,
      linkedin: link('linkedin.com'),
      github: link('github.com'),
      website: labeled('website|الموقع الإلكتروني'),
      portfolio: labeled('portfolio|معرض الأعمال'),
      interests: sections['interests']
          ?.expand((s) => s.split(RegExp(r'[,،;؛|]')))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList(),
      achievements: (sections['achievements'] ?? [])
          .map((s) => Achievement(name: _clean(s), description: '', date: ''))
          .toList(),
    );
  }
}
