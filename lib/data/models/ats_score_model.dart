import 'dart:convert';
import 'package:flutter/foundation.dart';

/// An ATS finding with its severity and an actionable improvement.
class AtsIssue {
  static const severities = ['critical', 'warning', 'info'];
  final String severity;
  final String category;
  final String description;
  final String suggestion;

  AtsIssue({
    required this.severity,
    required this.category,
    required this.description,
    required this.suggestion,
  }) {
    if (!severities.contains(severity)) {
      throw ArgumentError.value(
        severity,
        'severity',
        'Unsupported ATS severity',
      );
    }
  }

  factory AtsIssue.fromJson(Map<String, dynamic> json) => AtsIssue(
    severity: json['severity'] as String? ?? 'info',
    category: json['category'] as String? ?? '',
    description: json['description'] as String? ?? '',
    suggestion: json['suggestion'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'severity': severity,
    'category': category,
    'description': description,
    'suggestion': suggestion,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AtsIssue &&
          severity == other.severity &&
          category == other.category &&
          description == other.description &&
          suggestion == other.suggestion;

  @override
  int get hashCode => Object.hash(severity, category, description, suggestion);

  @override
  String toString() => 'AtsIssue($severity, $category)';
}

/// Immutable ATS analysis result with a score out of one hundred.
class AtsScoreModel {
  final int overallScore;
  final Map<String, int> sectionScores;
  final List<AtsIssue> issues;
  final List<String> suggestions;
  final List<String> missingKeywords;

  AtsScoreModel({
    required this.overallScore,
    required Map<String, int> sectionScores,
    required List<AtsIssue> issues,
    required List<String> suggestions,
    required List<String> missingKeywords,
  }) : sectionScores = Map.unmodifiable(sectionScores),
       issues = List.unmodifiable(issues),
       suggestions = List.unmodifiable(suggestions),
       missingKeywords = List.unmodifiable(missingKeywords) {
    if (overallScore < 0 || overallScore > 100) {
      throw RangeError.range(overallScore, 0, 100, 'overallScore');
    }
    if (sectionScores.values.any((score) => score < 0 || score > 100)) {
      throw ArgumentError('Section scores must be between 0 and 100');
    }
  }

  factory AtsScoreModel.fromJson(Map<String, dynamic> json) => AtsScoreModel(
    overallScore: json['overallScore'] as int? ?? 0,
    sectionScores: Map<String, int>.from(
      json['sectionScores'] as Map? ?? const {},
    ),
    issues: (json['issues'] as List? ?? const [])
        .map(
          (entry) => AtsIssue.fromJson(Map<String, dynamic>.from(entry as Map)),
        )
        .toList(),
    suggestions: List<String>.from(json['suggestions'] as List? ?? const []),
    missingKeywords: List<String>.from(
      json['missingKeywords'] as List? ?? const [],
    ),
  );

  Map<String, dynamic> toJson() => {
    'overallScore': overallScore,
    'sectionScores': Map<String, int>.of(sectionScores),
    'issues': issues.map((issue) => issue.toJson()).toList(),
    'suggestions': List<String>.of(suggestions),
    'missingKeywords': List<String>.of(missingKeywords),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AtsScoreModel &&
          overallScore == other.overallScore &&
          mapEquals(sectionScores, other.sectionScores) &&
          listEquals(issues, other.issues) &&
          listEquals(suggestions, other.suggestions) &&
          listEquals(missingKeywords, other.missingKeywords);

  @override
  int get hashCode {
    final keys = sectionScores.keys.toList()..sort();
    return Object.hash(
      overallScore,
      Object.hashAll(keys.map((key) => Object.hash(key, sectionScores[key]))),
      Object.hashAll(issues),
      Object.hashAll(suggestions),
      Object.hashAll(missingKeywords),
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
