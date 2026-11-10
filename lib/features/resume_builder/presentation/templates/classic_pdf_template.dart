import 'styled_pdf_template.dart';

/// Traditional centered name and understated section rules.
class ClassicPdfTemplate extends StyledPdfTemplate {
  const ClassicPdfTemplate({
    super.options,
    super.fallbackFont,
    super.boldFont,
    super.photo,
  }) : super(layout: PdfLayoutStyle.classic);
}
