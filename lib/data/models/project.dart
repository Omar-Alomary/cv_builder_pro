import 'package:flutter/foundation.dart';

/// Serializable project entry in a resume.
class Project {
  String name;
  String description;
  String startDate;
  String? endDate;
  bool isCurrent;
  List<String> technologies;

  Project({
    required this.name,
    required this.description,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.technologies = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    startDate: json['startDate'] as String? ?? '',
    endDate: json['endDate'] as String?,
    isCurrent: json['isCurrent'] as bool? ?? false,
    technologies: List<String>.from(json['technologies'] as List? ?? const []),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'startDate': startDate,
    'endDate': endDate,
    'isCurrent': isCurrent,
    'technologies': List<String>.of(technologies),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          name == other.name &&
          description == other.description &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          isCurrent == other.isCurrent &&
          listEquals(technologies, other.technologies);

  @override
  int get hashCode => Object.hash(
    name,
    description,
    startDate,
    endDate,
    isCurrent,
    Object.hashAll(technologies),
  );

  @override
  String toString() => 'Project(${toJson()})';
}
