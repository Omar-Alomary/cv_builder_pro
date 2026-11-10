/// Serializable language entry in a resume.
class Language {
  String name;
  String level;

  Language({required this.name, required this.level});

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    name: json['name'] as String? ?? '',
    level: json['level'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'name': name, 'level': level};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language && name == other.name && level == other.level;

  @override
  int get hashCode => Object.hash(name, level);

  @override
  String toString() => 'Language(${toJson()})';
}
