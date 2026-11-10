/// Serializable course entry in a resume.
class Course {
  String name;
  String provider;
  String year;
  String? certificateUrl;

  Course({
    required this.name,
    required this.provider,
    required this.year,
    this.certificateUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    name: json['name'] as String? ?? '',
    provider: json['provider'] as String? ?? '',
    year: json['year'] as String? ?? '',
    certificateUrl: json['certificateUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'provider': provider,
    'year': year,
    'certificateUrl': certificateUrl,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          name == other.name &&
          provider == other.provider &&
          year == other.year &&
          certificateUrl == other.certificateUrl;

  @override
  int get hashCode => Object.hash(name, provider, year, certificateUrl);

  @override
  String toString() => 'Course(${toJson()})';
}
