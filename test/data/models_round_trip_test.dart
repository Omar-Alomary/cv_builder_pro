import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/data/models/achievement.dart';
import 'package:cv_builder_pro/data/models/certificate.dart';
import 'package:cv_builder_pro/data/models/course.dart';
import 'package:cv_builder_pro/data/models/education.dart';
import 'package:cv_builder_pro/data/models/experience.dart';
import 'package:cv_builder_pro/data/models/language.dart';
import 'package:cv_builder_pro/data/models/project.dart';
import 'package:cv_builder_pro/data/models/skill.dart';

Map<String, dynamic> roundTrip(Map<String, dynamic> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, dynamic>;

void main() {
  test('All resume entries survive actual JSON encoding and decoding', () {
    final education = Education(
      degree: 'بكالوريوس',
      institution: 'جامعة',
      year: '2024',
      grade: 'A',
      description: 'علوم الحاسب',
    );
    final experience = Experience(
      jobTitle: 'Developer',
      company: 'Company',
      startDate: '01/2024',
      endDate: '10/2025',
      description: 'Developed applications',
    );
    final skill = Skill(name: 'Dart', level: 5);
    final course = Course(
      name: 'Flutter',
      provider: 'Provider',
      year: '2025',
      certificateUrl: 'https://example.com/course',
    );
    final certificate = Certificate(
      name: 'Certificate',
      organization: 'Organization',
      year: '2025',
      credentialId: '123',
    );
    final language = Language(name: 'العربية', level: 'Native');
    final project = Project(
      name: 'CV',
      description: 'Builder',
      startDate: '01/2025',
      isCurrent: true,
      technologies: ['Dart', 'Flutter'],
    );
    final achievement = Achievement(
      name: 'Award',
      description: 'First place',
      date: '2025',
      organization: 'Organization',
      category: 'Technology',
    );
    final pairs = <(Object, Object)>[
      (education, Education.fromJson(roundTrip(education.toJson()))),
      (experience, Experience.fromJson(roundTrip(experience.toJson()))),
      (skill, Skill.fromJson(roundTrip(skill.toJson()))),
      (course, Course.fromJson(roundTrip(course.toJson()))),
      (certificate, Certificate.fromJson(roundTrip(certificate.toJson()))),
      (language, Language.fromJson(roundTrip(language.toJson()))),
      (project, Project.fromJson(roundTrip(project.toJson()))),
      (achievement, Achievement.fromJson(roundTrip(achievement.toJson()))),
    ];
    for (final (original, decoded) in pairs) {
      expect(decoded, original);
      expect(decoded.hashCode, original.hashCode);
    }
  });

  test('Missing optional data uses safe defaults', () {
    expect(Skill.fromJson({'name': 'Dart'}).level, 3);
    final project = Project.fromJson({'name': 'Project'});
    expect(project.isCurrent, false);
    expect(project.technologies, isEmpty);
    expect(project.endDate, isNull);
  });

  test('Project serialization does not expose its technology list', () {
    final project = Project(
      name: 'App',
      description: '',
      startDate: '',
      technologies: ['Dart'],
    );
    final json = project.toJson();
    (json['technologies'] as List<String>).add('Other');
    expect(project.technologies, ['Dart']);
  });

  test('Invalid skill level type is rejected instead of silently coerced', () {
    expect(
      () => Skill.fromJson({'name': 'Dart', 'level': 'advanced'}),
      throwsA(isA<TypeError>()),
    );
  });
}
