import 'package:pdf/pdf.dart';

/// Validated appearance settings retaining the existing customization schema.
class PdfTemplateOptions {
  const PdfTemplateOptions({
    this.primaryColor = 0xff1565c0,
    this.secondaryColor = 0xff546e7a,
    this.fontFamily = 'Cairo',
    this.fontSize = 11,
  });
  final int primaryColor;
  final int secondaryColor;
  final String fontFamily;
  final double fontSize;
  PdfColor get primary => PdfColor.fromInt(primaryColor);
  PdfColor get secondary => PdfColor.fromInt(secondaryColor);
  Map<String, dynamic> toJson() => {
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'fontFamily': fontFamily,
    'fontSize': fontSize,
  };
  PdfTemplateOptions copyWith({
    int? primaryColor,
    int? secondaryColor,
    String? fontFamily,
    double? fontSize,
  }) => PdfTemplateOptions(
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    fontFamily: fontFamily ?? this.fontFamily,
    fontSize: fontSize ?? this.fontSize,
  );
  @override
  bool operator ==(Object other) =>
      other is PdfTemplateOptions &&
      primaryColor == other.primaryColor &&
      secondaryColor == other.secondaryColor &&
      fontFamily == other.fontFamily &&
      fontSize == other.fontSize;
  @override
  int get hashCode =>
      Object.hash(primaryColor, secondaryColor, fontFamily, fontSize);
  factory PdfTemplateOptions.fromJson(Map<String, dynamic>? json) {
    int color(String key, int fallback) {
      final value = json?[key];
      return value is int && value >= 0 && value <= 0xffffffff
          ? value
          : fallback;
    }

    final size = json?['fontSize'];
    final family = json?['fontFamily'];
    return PdfTemplateOptions(
      primaryColor: color('primaryColor', 0xff1565c0),
      secondaryColor: color('secondaryColor', 0xff546e7a),
      fontFamily: ['Cairo', 'Sukar', 'Poppins'].contains(family)
          ? family as String
          : 'Cairo',
      fontSize: size is num && size.isFinite
          ? size.toDouble().clamp(8, 16)
          : 11,
    );
  }
}
