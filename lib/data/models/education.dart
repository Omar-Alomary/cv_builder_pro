/// Serializable education entry in a resume.
class Education {
  String degree;
  String institution;
  String year;
  String? grade;
  String? description;

  Education({
    required this.degree,
    required this.institution,
    required this.year,
    this.grade,
    this.description,
  });

  factory Education.fromJson(Map<String, dynamic> json) => Education(
    degree: json['degree'] as String? ?? '',
    institution: json['institution'] as String? ?? '',
    year: json['year'] as String? ?? '',
    grade: json['grade'] as String?,
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'degree': degree,
    'institution': institution,
    'year': year,
    'grade': grade,
    'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Education &&
          degree == other.degree &&
          institution == other.institution &&
          year == other.year &&
          grade == other.grade &&
          description == other.description;

  @override
  int get hashCode =>
      Object.hash(degree, institution, year, grade, description);

  @override
  String toString() => 'Education(${toJson()})';
}
