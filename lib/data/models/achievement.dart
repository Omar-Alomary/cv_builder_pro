/// Serializable achievement entry in a resume.
class Achievement {
  String name;
  String description;
  String date;
  String? organization;
  String? category;

  Achievement({
    required this.name,
    required this.description,
    required this.date,
    this.organization,
    this.category,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    date: json['date'] as String? ?? '',
    organization: json['organization'] as String?,
    category: json['category'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'date': date,
    'organization': organization,
    'category': category,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Achievement &&
          name == other.name &&
          description == other.description &&
          date == other.date &&
          organization == other.organization &&
          category == other.category;

  @override
  int get hashCode =>
      Object.hash(name, description, date, organization, category);

  @override
  String toString() => 'Achievement(${toJson()})';
}
