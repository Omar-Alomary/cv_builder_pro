# تحديث القوالب والاستيراد وشاشة الإنشاء

تاريخ التنفيذ: 24 أكتوبر 2026.

## ما تغيّر

- شاشة قوالب جديدة بعنوان تمهيدي وبحث وتصنيفات؛ بطاقة واسعة في الجوال، وعمودان في التابلت وثلاثة على سطح المكتب. معاينات تحتوي أمثلة نصية عربية وإنجليزية، مع معاينة مكبرة قبل الاختيار.
- إزالة خلفية Material الافتراضية خلف خطوات إنشاء السيرة، مع إبقاء الدوائر وأسماء المراحل قابلة للاختيار.
- تثبيت أزرار التنقل أسفل مساحة النموذج، خارج التمرير. اختُبر ظهور «التالي» على شاشة 320×640 عند فتح لوحة مفاتيح بارتفاع 260.
- عرض ورقة السيرة أولاً في معاينة الجوال، ثم أدوات التصدير والتخصيص، مع ضبط ارتفاع مساحة العرض وفق مقاس الورقة.
- تحسين عناوين PDF والمسافات والتسلسل البصري ومحاذاة العربية. يحتفظ Modern بخط الزمن، وClassic بالتنسيق التقليدي، وBusiness بالهوية المؤسسية، وTechnical بأولوية المهارات والمشاريع، وATS بتنسيقه الخطي الأسود.
- استخدام الخطوط المحلية وأوزانها الصحيحة. يدعم Cairo وSukar العربية والإنجليزية؛ عند اختيار Poppins، تستخدم المقاطع العربية Cairo احتياطياً لأن Poppins لا يحتوي الحروف العربية. لا خطوط تُحمّل من الشبكة ولا اعتماديات جديدة.

## إصلاح استيراد PDF

كان القارئ يرفض ملفات Type0 وToUnicode وIdentity قبل محاولة قراءتها. يقرأ الآن خرائط Unicode بصيغتي bfchar وbfrange، والنصوص السداسية والنصية، وتدفقات Flate وقواميس الكائنات المضغوطة. يجمع الكلمات وفق مواضعها، ويعيد الأشكال العربية الموصولة إلى حروفها، بدلاً من إظهار أرقام المحارف كأنها نصوص.

تبقى حدود الذاكرة وحجم الملفات ورفض الملفات المشفرة قائمة. ملفات الصور الممسوحة تحتاج إلى OCR، والخط الذي لا يقدم خريطة Unicode صالحة قد يتعذر استخلاصه؛ تظهر رسالة توضح البديل. الاستيراد النصي يحتاج مراجعة الحقول، ويحفظ النص المستخرج في الملخص حتى لا يُفقد المحتوى غير المصنف.

## التحقق

- مجموعة الاختبارات الكاملة: 620 اختباراً ناجحاً.
- 30 حالة تصدير وإعادة استيراد فعلية: 5 قوالب × 3 خطوط × لغتين.
- 6 حالات نص مختلط مع اختلاف لغة الواجهة، وحالتا CMap خارجي بصيغتي النطاق المتتابع والمصفوفة.
- اختبارات التعديل والحفظ والتنقل والتجاوب والوضع الليلي والعربية وتكبير النص.
- فحص 30 ملف PDF وتحويل أمثلة إلى صور، ثم فحص ملفات كاملة ومتعددة الصفحات وحدود النصوص باستخدام pypdf وpdfplumber وpypdfium2.
- flutter analyze: لا ملاحظات. صور الواجهة ناتجة من اختبارات Flutter؛ لم يُنفّذ تشغيل أصلي جديد على جهاز فعلي.

## صور المراجعة

- refreshed_catalog_dark_ar.png
- refreshed_catalog_desktop.png
- refreshed_builder_dark_ar.png
- refreshed_preview_dark_ar.png
- refreshed_pdf_templates.png

## الملفات الأساسية

- lib/features/templates/presentation/pages/templates_screen.dart
- lib/features/templates/presentation/widgets/template_grid_card.dart
- lib/features/templates/presentation/widgets/template_mini_preview.dart
- lib/features/resume_builder/presentation/pages/resume_builder_screen.dart
- lib/features/resume_builder/presentation/pages/preview_screen.dart
- lib/features/resume_builder/presentation/widgets/step_indicator.dart
- lib/features/resume_builder/presentation/templates/styled_pdf_template.dart
- lib/features/resume_builder/presentation/templates/ats_pdf_template.dart
- lib/core/services/pdf_service.dart
- lib/core/services/simple_pdf_text_extractor.dart
- lib/core/services/pdf_unicode_map.dart
- lib/translations/en_us.dart
- lib/translations/ar_sa.dart
- pubspec.yaml

سجلات التحقق في tmp/ui_redesign/refreshed_final_suite.log وrefreshed_final_analyze.log وrefreshed_final_pdf_checks.log.
