import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_builder_pro/core/services/resume_import_service.dart';
import 'package:cv_builder_pro/core/services/simple_pdf_text_extractor.dart';

void main() {
  test(
    'inspect real device PDF imports',
    () async {
      final folder = Directory('tmp/device_matrix/real_imports');
      for (final file in folder.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.pdf'),
      )) {
        final bytes = await file.readAsBytes();
        final raw = SimplePdfTextExtractor.extract(bytes);
        await File('${file.path}.extracted.txt').writeAsString(raw);
        final model = ResumeImportService().fromBytes(bytes, 'pdf');
        expect(model.email, 'omar.alomary129@gmail.com');
        expect(model.phone, '+967779218017');
        expect(model.education, hasLength(1));
        expect(model.experience, hasLength(2));
        expect(model.languages, hasLength(2));
        expect(model.projects, hasLength(5));
        expect(model.certificates, hasLength(7));
        expect(
          model.skills.map((s) => s.name).toSet().length,
          model.skills.length,
        );
        expect(model.address, isNot(contains('@')));
        expect(model.summary, isNot(contains('omar.alomary129@gmail.com')));

        await File(
          '${file.path}.json',
        ).writeAsString(jsonEncode(model.toJson()));
        // ignore: avoid_print
        print(
          '${file.path}: ${model.education.length} education, ${model.experience.length} experience, ${model.skills.length} skills',
        );
      }
    },
    skip: !Directory('tmp/device_matrix/real_imports').existsSync()
        ? 'Connect the authorized device files to run this audit'
        : false,
  );
}
