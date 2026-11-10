/// Serializable skill entry in a resume.
class Skill {
  String name;
  int level;

  Skill({required this.name, this.level = 3});

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    name: json['name'] as String? ?? '',
    level: json['level'] as int? ?? 3,
  );

  Map<String, dynamic> toJson() => {'name': name, 'level': level};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill && name == other.name && level == other.level;

  @override
  int get hashCode => Object.hash(name, level);

  @override
  String toString() => 'Skill(${toJson()})';
}
