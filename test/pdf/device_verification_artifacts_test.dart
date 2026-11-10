import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/pdf_service.dart';
import 'package:cv_builder_pro/data/json/resume_json.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'regenerate authorized device inputs with the latest PDF renderer',
    () async {
      final output = Directory('tmp/device_matrix/latest_pdf_review');
      await output.create(recursive: true);
      for (final file
          in Directory(
            'deliveries/ui_redesign/device_verify',
          ).listSync().whereType<File>().where(
            (f) => RegExp(
              r'(modern|classic|business|technical|ats)_(ar|en)\.json$',
            ).hasMatch(f.path),
          )) {
        final resume = ResumeJson.decode(await file.readAsString());
        final bytes = await PdfService().generate(
          resume,
          locale: file.path.endsWith('_ar.json') ? 'ar' : 'en',
        );
        await File(
          '${output.path}/${file.uri.pathSegments.last.replaceAll('.json', '.pdf')}',
        ).writeAsBytes(bytes);
      }
    },
    skip:
        !File(
          'deliveries/ui_redesign/device_verify/modern_ar.json',
        ).existsSync()
        ? 'Requires the authorized device verification captures'
        : false,
  );
}
