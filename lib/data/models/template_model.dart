import 'dart:convert';
import 'package:get/get.dart';

/// Template metadata, including the original localized labels.
class TemplateModel {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final String type;
  final String language;
  final String? icon;
  final String? previewImage;
  final String? previewColor;
  final bool isFeatured;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.type,
    required this.language,
    this.icon,
    this.previewImage,
    this.previewColor,
    this.isFeatured = false,
  });

  String get localizedName => Get.locale?.languageCode == 'ar' ? nameAr : name;
  String get localizedDescription =>
      Get.locale?.languageCode == 'ar' ? descriptionAr : description;

  factory TemplateModel.fromJson(Map<String, dynamic> json) => TemplateModel(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    nameAr: json['nameAr'] as String? ?? '',
    description: json['description'] as String? ?? '',
    descriptionAr: json['descriptionAr'] as String? ?? '',
    type: json['type'] as String? ?? '',
    language: json['language'] as String? ?? '',
    icon: json['icon'] as String?,
    previewImage: json['previewImage'] as String?,
    previewColor: json['previewColor'] as String?,
    isFeatured: json['isFeatured'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAr': nameAr,
    'description': description,
    'descriptionAr': descriptionAr,
    'type': type,
    'language': language,
    'icon': icon,
    'previewImage': previewImage,
    'previewColor': previewColor,
    'isFeatured': isFeatured,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateModel &&
          jsonEncode(toJson()) == jsonEncode(other.toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;

  @override
  String toString() => 'TemplateModel(id: $id, type: $type)';
}
