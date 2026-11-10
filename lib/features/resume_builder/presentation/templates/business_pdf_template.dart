import 'styled_pdf_template.dart';

/// Corporate color bands and clear section hierarchy.
class BusinessPdfTemplate extends StyledPdfTemplate {
  const BusinessPdfTemplate({
    super.options,
    super.fallbackFont,
    super.boldFont,
    super.photo,
  }) : super(layout: PdfLayoutStyle.business);
}
