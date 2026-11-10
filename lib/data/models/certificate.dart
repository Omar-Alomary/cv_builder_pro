/// Serializable certificate entry in a resume.
class Certificate {
  String name;
  String organization;
  String year;
  String? credentialId;

  Certificate({
    required this.name,
    required this.organization,
    required this.year,
    this.credentialId,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    name: json['name'] as String? ?? '',
    organization: json['organization'] as String? ?? '',
    year: json['year'] as String? ?? '',
    credentialId: json['credentialId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'organization': organization,
    'year': year,
    'credentialId': credentialId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Certificate &&
          name == other.name &&
          organization == other.organization &&
          year == other.year &&
          credentialId == other.credentialId;

  @override
  int get hashCode => Object.hash(name, organization, year, credentialId);

  @override
  String toString() => 'Certificate(${toJson()})';
}
