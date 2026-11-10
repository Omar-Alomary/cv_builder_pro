import 'dart:convert';

/// Visibility options used by template selection and the resume builder.
class TemplateFields {
  final bool showProfilePicture;
  final bool showSummary;
  final bool showAddress;
  final bool showLinkedin;
  final bool showGithub;
  final bool showPortfolio;
  final bool showWebsite;
  final bool showProjects;
  final bool showAchievements;
  final bool showInterests;
  final bool showCourses;
  final bool showCertificates;
  final bool showLanguages;

  const TemplateFields({
    required this.showProfilePicture,
    required this.showSummary,
    required this.showAddress,
    required this.showLinkedin,
    required this.showGithub,
    required this.showPortfolio,
    required this.showWebsite,
    required this.showProjects,
    required this.showAchievements,
    required this.showInterests,
    required this.showCourses,
    required this.showCertificates,
    required this.showLanguages,
  });

  factory TemplateFields.fromJson(Map<String, dynamic> json) => TemplateFields(
    showProfilePicture: json['showProfilePicture'] as bool? ?? false,
    showSummary: json['showSummary'] as bool? ?? false,
    showAddress: json['showAddress'] as bool? ?? false,
    showLinkedin: json['showLinkedin'] as bool? ?? false,
    showGithub: json['showGithub'] as bool? ?? false,
    showPortfolio: json['showPortfolio'] as bool? ?? false,
    showWebsite: json['showWebsite'] as bool? ?? false,
    showProjects: json['showProjects'] as bool? ?? false,
    showAchievements: json['showAchievements'] as bool? ?? false,
    showInterests: json['showInterests'] as bool? ?? false,
    showCourses: json['showCourses'] as bool? ?? false,
    showCertificates: json['showCertificates'] as bool? ?? false,
    showLanguages: json['showLanguages'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'showProfilePicture': showProfilePicture,
    'showSummary': showSummary,
    'showAddress': showAddress,
    'showLinkedin': showLinkedin,
    'showGithub': showGithub,
    'showPortfolio': showPortfolio,
    'showWebsite': showWebsite,
    'showProjects': showProjects,
    'showAchievements': showAchievements,
    'showInterests': showInterests,
    'showCourses': showCourses,
    'showCertificates': showCertificates,
    'showLanguages': showLanguages,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateFields &&
          jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;

  @override
  String toString() => 'TemplateFields(${toJson()})';
}
