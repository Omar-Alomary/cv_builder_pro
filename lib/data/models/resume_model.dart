import 'dart:convert';
import 'education.dart';
import 'experience.dart';
import 'skill.dart';
import 'course.dart';
import 'certificate.dart';
import 'language.dart';
import 'project.dart';
import 'achievement.dart';

const _unset = Object();

/// Complete resume data retaining the original storage schema.
class ResumeModel {
  int? id;
  String fullName;
  String email;
  String phone;
  String? address;
  String? profilePicture;
  String? summary;
  List<Education> education;
  List<Experience> experience;
  List<Skill> skills;
  List<Course> courses;
  List<Certificate> certificates;
  List<Language> languages;
  List<Project> projects;
  List<Achievement> achievements;
  String? linkedin;
  String? github;
  String? website;
  String? portfolio;
  List<String>? interests;
  String templateId;
  DateTime createdAt;
  DateTime? updatedAt;
  bool isFavorite;
  Map<String, dynamic>? customization;

  ResumeModel({
    this.id,
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.address,
    this.profilePicture,
    this.summary,
    List<Education> education = const [],
    List<Experience> experience = const [],
    List<Skill> skills = const [],
    List<Course> courses = const [],
    List<Certificate> certificates = const [],
    List<Language> languages = const [],
    List<Project> projects = const [],
    List<Achievement> achievements = const [],
    this.linkedin,
    this.github,
    this.website,
    this.portfolio,
    this.interests,
    this.templateId = 'modern',
    DateTime? createdAt,
    this.updatedAt,
    this.isFavorite = false,
    this.customization,
  }) : createdAt = createdAt ?? DateTime.now(),
       education = List.of(education),
       experience = List.of(experience),
       skills = List.of(skills),
       courses = List.of(courses),
       certificates = List.of(certificates),
       languages = List.of(languages),
       projects = List.of(projects),
       achievements = List.of(achievements);

  factory ResumeModel.fromJson(Map<String, dynamic> json) => ResumeModel(
    id: json['id'] as int?,
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    address: json['address'] as String?,
    profilePicture: json['profilePicture'] as String?,
    summary: json['summary'] as String?,
    education: _entries(json['education'], 'education', Education.fromJson),
    experience: _entries(json['experience'], 'experience', Experience.fromJson),
    skills: _entries(json['skills'], 'skills', Skill.fromJson),
    courses: _entries(json['courses'], 'courses', Course.fromJson),
    certificates: _entries(
      json['certificates'],
      'certificates',
      Certificate.fromJson,
    ),
    languages: _entries(json['languages'], 'languages', Language.fromJson),
    projects: _entries(json['projects'], 'projects', Project.fromJson),
    achievements: _entries(
      json['achievements'],
      'achievements',
      Achievement.fromJson,
    ),
    linkedin: json['linkedin'] as String?,
    github: json['github'] as String?,
    website: json['website'] as String?,
    portfolio: json['portfolio'] as String?,
    interests: json['interests'] == null
        ? null
        : List<String>.from(json['interests'] as List),
    templateId: json['templateId'] as String? ?? 'modern',
    createdAt: _date(json['createdAt'], 'createdAt'),
    updatedAt: _date(json['updatedAt'], 'updatedAt'),
    isFavorite: json['isFavorite'] as bool? ?? false,
    customization: json['customization'] == null
        ? null
        : Map<String, dynamic>.from(
            jsonDecode(jsonEncode(json['customization'])) as Map,
          ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'address': address,
    'profilePicture': profilePicture,
    'summary': summary,
    'education': education.map((entry) => entry.toJson()).toList(),
    'experience': experience.map((entry) => entry.toJson()).toList(),
    'skills': skills.map((entry) => entry.toJson()).toList(),
    'courses': courses.map((entry) => entry.toJson()).toList(),
    'certificates': certificates.map((entry) => entry.toJson()).toList(),
    'languages': languages.map((entry) => entry.toJson()).toList(),
    'projects': projects.map((entry) => entry.toJson()).toList(),
    'achievements': achievements.map((entry) => entry.toJson()).toList(),
    'linkedin': linkedin,
    'github': github,
    'website': website,
    'portfolio': portfolio,
    'interests': interests == null ? null : List<String>.of(interests!),
    'templateId': templateId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isFavorite': isFavorite,
    'customization': customization == null
        ? null
        : jsonDecode(jsonEncode(customization)),
  };

  /// Returns an independent copy; explicit null clears nullable fields.
  ResumeModel copyWith({
    Object? id = _unset,
    String? fullName,
    String? email,
    String? phone,
    Object? address = _unset,
    Object? profilePicture = _unset,
    Object? summary = _unset,
    List<Education>? education,
    List<Experience>? experience,
    List<Skill>? skills,
    List<Course>? courses,
    List<Certificate>? certificates,
    List<Language>? languages,
    List<Project>? projects,
    List<Achievement>? achievements,
    Object? linkedin = _unset,
    Object? github = _unset,
    Object? website = _unset,
    Object? portfolio = _unset,
    Object? interests = _unset,
    String? templateId,
    DateTime? createdAt,
    Object? updatedAt = _unset,
    bool? isFavorite,
    Object? customization = _unset,
  }) {
    final changes = <String, dynamic>{};
    if (!identical(id, _unset)) changes['id'] = id;
    if (fullName != null) changes['fullName'] = fullName;
    if (email != null) changes['email'] = email;
    if (phone != null) changes['phone'] = phone;
    if (!identical(address, _unset)) changes['address'] = address;
    if (!identical(profilePicture, _unset)) {
      changes['profilePicture'] = profilePicture;
    }
    if (!identical(summary, _unset)) changes['summary'] = summary;
    if (education != null) {
      changes['education'] = education.map((entry) => entry.toJson()).toList();
    }
    if (experience != null) {
      changes['experience'] = experience
          .map((entry) => entry.toJson())
          .toList();
    }
    if (skills != null) {
      changes['skills'] = skills.map((entry) => entry.toJson()).toList();
    }
    if (courses != null) {
      changes['courses'] = courses.map((entry) => entry.toJson()).toList();
    }
    if (certificates != null) {
      changes['certificates'] = certificates
          .map((entry) => entry.toJson())
          .toList();
    }
    if (languages != null) {
      changes['languages'] = languages.map((entry) => entry.toJson()).toList();
    }
    if (projects != null) {
      changes['projects'] = projects.map((entry) => entry.toJson()).toList();
    }
    if (achievements != null) {
      changes['achievements'] = achievements
          .map((entry) => entry.toJson())
          .toList();
    }
    if (!identical(linkedin, _unset)) changes['linkedin'] = linkedin;
    if (!identical(github, _unset)) changes['github'] = github;
    if (!identical(website, _unset)) changes['website'] = website;
    if (!identical(portfolio, _unset)) changes['portfolio'] = portfolio;
    if (!identical(interests, _unset)) {
      changes['interests'] = interests == null
          ? null
          : List<String>.of(interests as List<String>);
    }
    if (templateId != null) changes['templateId'] = templateId;
    if (createdAt != null) changes['createdAt'] = createdAt.toIso8601String();
    if (!identical(updatedAt, _unset)) {
      changes['updatedAt'] = (updatedAt as DateTime?)?.toIso8601String();
    }
    if (isFavorite != null) changes['isFavorite'] = isFavorite;
    if (!identical(customization, _unset)) {
      changes['customization'] = customization == null
          ? null
          : jsonDecode(jsonEncode(customization));
    }
    return ResumeModel.fromJson({...toJson(), ...changes});
  }

  static DateTime? _date(Object? value, String field) {
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('$field must be an ISO date string');
    }
    final date = DateTime.tryParse(value);
    if (date == null) throw FormatException('Invalid $field');
    // DateTime.tryParse normalizes overflowing days; reject such values.
    final calendar = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(value);
    if (calendar == null) throw FormatException('Invalid $field');
    final year = int.parse(calendar.group(1)!);
    final month = int.parse(calendar.group(2)!);
    final day = int.parse(calendar.group(3)!);
    if (month < 1 ||
        month > 12 ||
        day < 1 ||
        day > DateTime.utc(year, month + 1, 0).day) {
      throw FormatException('Invalid $field');
    }
    return date;
  }

  static List<T> _entries<T>(
    Object? value,
    String field,
    T Function(Map<String, dynamic>) decode,
  ) {
    if (value == null) return [];
    if (value is! List) throw FormatException('$field must be a list');
    return value.map((item) {
      if (item is! Map) throw FormatException('$field entries must be objects');
      return decode(Map<String, dynamic>.from(item));
    }).toList();
  }

  static Object? _canonical(Object? value) {
    if (value is Map) {
      final keys = value.keys.cast<String>().toList()..sort();
      return {for (final key in keys) key: _canonical(value[key])};
    }
    if (value is List) return value.map(_canonical).toList();
    return value;
  }

  String get _comparisonKey => jsonEncode(_canonical(toJson()));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeModel && _comparisonKey == other._comparisonKey;

  @override
  int get hashCode => _comparisonKey.hashCode;

  @override
  String toString() => 'ResumeModel(id: $id, templateId: $templateId)';
}
