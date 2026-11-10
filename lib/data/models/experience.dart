/// Serializable experience entry in a resume.
class Experience {
  String jobTitle;
  String company;
  String startDate;
  String? endDate;
  bool isCurrent;
  String? description;

  Experience({
    required this.jobTitle,
    required this.company,
    required this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    jobTitle: json['jobTitle'] as String? ?? '',
    company: json['company'] as String? ?? '',
    startDate: json['startDate'] as String? ?? '',
    endDate: json['endDate'] as String?,
    isCurrent: json['isCurrent'] as bool? ?? false,
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'jobTitle': jobTitle,
    'company': company,
    'startDate': startDate,
    'endDate': endDate,
    'isCurrent': isCurrent,
    'description': description,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Experience &&
          jobTitle == other.jobTitle &&
          company == other.company &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          isCurrent == other.isCurrent &&
          description == other.description;

  @override
  int get hashCode => Object.hash(
    jobTitle,
    company,
    startDate,
    endDate,
    isCurrent,
    description,
  );

  @override
  String toString() => 'Experience(${toJson()})';
}
