import 'styled_pdf_template.dart';

/// Skills and projects prioritized before employment and education.
class TechnicalPdfTemplate extends StyledPdfTemplate {
  const TechnicalPdfTemplate({
    super.options,
    super.fallbackFont,
    super.boldFont,
    super.photo,
  }) : super(layout: PdfLayoutStyle.technical);
}
