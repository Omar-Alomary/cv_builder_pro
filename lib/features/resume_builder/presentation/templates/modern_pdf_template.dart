import 'styled_pdf_template.dart';

/// Timeline accents for work and project entries.
class ModernPdfTemplate extends StyledPdfTemplate {
  const ModernPdfTemplate({
    super.options,
    super.fallbackFont,
    super.boldFont,
    super.photo,
  }) : super(layout: PdfLayoutStyle.modern);
}
