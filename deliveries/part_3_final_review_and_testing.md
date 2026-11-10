# Part 3 — التشغيل والمراجعة النهائية واختبار الميزات

تاريخ المراجعة: 23 أكتوبر 2026. المشروع: cv_builder_pro. بيئة المراجعة: Windows، Flutter 3.38.9، Dart 3.10.8.

## النتيجة الفعلية

| التحقق | النتيجة |
|---|---|
| flutter pub get | نجح؛ جميع الاعتماديات حُلّت دون إضافة اعتمادية مباشرة غير file_picker |
| flutter analyze | نجح للمشروع كاملاً: No issues found |
| flutter test --no-pub | نجحت الاختبارات الـ257 |
| ملفات Dart داخل lib | 128 ملفاً؛ القائمة المرقمة أدناه |
| GetStorage | محصور في ResumeRepository |
| الواجهة القديمة | حُذف lib/legacy_app.dart بعد فصل جميع أجزائه |
| توليد PDF | اختبارات للقوالب الخمسة؛ فُحصت عينات القوالب الأربعة بصرياً ونصياً في الدفعة 22 |
| تشغيل Windows | جرت المحاولة، وتوقفت قبل البناء بسبب عدم توفر دعم الروابط الرمزية؛ يتطلب تفعيل Developer Mode |
| تشغيل Android/iOS | ظهر هاتف Android لاحقاً أثناء فحص البيئة وجرت محاولة تشغيله؛ راجع النتيجة النهائية أدناه. iOS غير مختبر |
| الطباعة والمشاركة ونوافذ اختيار الملفات | اختُبرت بالمحاكاة؛ لم تُختبر على جهاز فعلي |

نجاح التحليل والاختبارات لا يساوي اجتياز اختبار الجهاز أو ضمان عمل كل نظام تشغيل. توجد قيود صريحة لاستيراد PDF أدناه.

## تشغيل المشروع

افتح المشروع في المسار:

```text
C:\Flutter\flutter_apps\cv_builder_pro
```

إذا كان Flutter مضافاً إلى PATH:

```powershell
flutter pub get
flutter analyze
flutter test --no-pub
flutter devices
flutter run -d windows
```

المسار المتحقق لأداة Flutter على هذا الجهاز:

```powershell
& 'C:\Flutter\Android\FlutterSDK\bin\flutter.bat' pub get
& 'C:\Flutter\Android\FlutterSDK\bin\flutter.bat' analyze
& 'C:\Flutter\Android\FlutterSDK\bin\flutter.bat' test --no-pub
& 'C:\Flutter\Android\FlutterSDK\bin\flutter.bat' run -d windows --no-pub
```

### عائق التشغيل الحالي على Windows

أعادت محاولة التشغيل الرسالة التالية:

```text
Error: Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

فعّل Developer Mode من إعدادات Windows، ثم افتح نافذة الطرفية مجدداً وأعد محاولة التشغيل. يمكن فتح صفحة الإعدادات يدوياً بهذا الأمر:

```powershell
Start-Process 'ms-settings:developers'
```

لم تُغيّر المراجعة إعدادات النظام. لا توجد نتيجة تؤكد أن التطبيق وصل إلى الشاشة الرئيسية على Windows حتى الآن.

### Android

ظهر هاتف SM N975U بمعرّف R38M906C8XE خلال فحص البيئة بعد قائمة الأجهزة الأولى. للتحقق من جهازك، صل جهازاً مع تفعيل USB debugging، أو شغّل محاكياً من بيئة Android لديك. تحقق من ظهوره عبر flutter devices ثم استخدم:

```powershell
flutter run -d DEVICE_ID
```

استبدل DEVICE_ID بالمعرّف الفعلي الظاهر. أشار flutter doctor إلى وجود بعض تراخيص Android غير المقبولة؛ يمكن مراجعتها يدوياً عبر flutter doctor --android-licenses. لم تقبل المراجعة أي ترخيص نيابة عن المستخدم. iOS يحتاج جهاز Mac وبيئة Xcode؛ لم تُختبر هذه البيئة هنا. وجود Chrome وEdge ضمن أجهزة Flutter لا يثبت دعم الويب: بعض الخدمات الحالية تعتمد على dart:io، ولم يُختبر بناء ويب في هذه المراجعة.

## ملفات تجريبية

ملف JSON كامل لتجربة جميع الأقسام وقالب ATS:

[resume_full.json](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/fixtures/resume_full.json)

ملف TXT بسيط لتجربة استخراج الاتصال والمهارات:

[resume_simple.txt](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/fixtures/resume_simple.txt)

البيانات تجريبية، وليست حسابات اتصال حقيقية. استورد نسخة JSON أولاً ثم احتفظ بها مرجعاً للمقارنة. لا تتوقع أن يكون استيراد TXT مطابقاً لـJSON: يحتفظ TXT بالنص الكامل في الملخص ويستخرج الحقول البسيطة التي يتعرف عليها.

## خطة اختبار الجهاز

سجّل لكل بند: ناجح، فاشل، أو غير مختبر. لم تُنفّذ البنود التالية يدوياً على جهاز في هذه المراجعة.

### 1. البداية واللغة

1. افتح التطبيق لأول مرة وتحقق من شاشة البداية والانتقال لاختيار اللغة.
2. اختر العربية وتحقق من اتجاه RTL، ثم أغلق التطبيق وافتحه وتحقق من بقاء اللغة.
3. غيّر اللغة إلى الإنجليزية من الإعدادات وتحقق من اتجاه LTR.
4. تحقق من إتاحة المحتوى مع تكبير النص وتقليل الحركة في النظام.

### 2. إنشاء سيرة وجميع أقسامها

1. اختر قالباً وأنشئ سيرة جديدة. أدخل الاسم والبريد والهاتف وبقية حقول الاتصال الظاهرة.
2. حاول الانتقال ببيانات شخصية غير صالحة، وتحقق من ظهور خطأ واضح وعدم تجاوز التحقق.
3. أضف تعليماً مع وصف وتقدير، ثم عدّل واحذف وأعد الإضافة.
4. أضف خبرة بتاريخ بدء وانتهاء؛ يجب رفض تاريخ انتهاء أسبق من البدء. فعّل الوظيفة الحالية وتحقق من عدم اشتراط تاريخ انتهاء.
5. أضف مهارات مع مستويات مختلفة؛ جرّب تكرار الاسم والتحقق من منعه.
6. أضف دورة برابط شهادة وشهادة بمعرّف اعتماد، ثم عدّل الاسم فقط وتحقق من بقاء الرابط والمعرّف.
7. أضف لغة ومستوى. عند استيراد مستوى مخصّص، يجب الاحتفاظ به عند تعديل الاسم.
8. أضف مشروعاً ووصفاً وتقنيات؛ أدخل كل تقنية في سطر مستقل. جرّب اسم تقنية يتضمن فاصلة مثل Web, Mobile وتحقق من بقائه اسماً واحداً.
9. أضف إنجازاً بجهة وتصنيف مخصّص وتاريخ MM/YYYY، ثم عدّل الاسم وتحقق من بقاء بقية الحقول.
10. أضف اهتماماً مخصّصاً واختر اقتراحاً؛ جرّب التكرار والتعديل والإلغاء والحذف.

الأقسام الظاهرة في المحرر تتبع إعدادات القالب؛ اختيار قالب يخفي حقلاً لا يمحو بياناته المحفوظة. قالب ATS يتيح تجربة الأقسام النصية الكاملة. عند إدخال سنوات أو تواريخ بأرقام عربية، تُطبّع إلى الصيغة القابلة للتخزين.

### 3. الحفظ والتعديل والحذف

1. أدخل اسماً للسيرة، وانتظر أكثر من خمس ثوانٍ، ثم تحقق من مؤشر الحفظ التلقائي.
2. غادر المحرر ثم افتح السيرة من الرئيسية، وتحقق من استرجاع جميع البيانات.
3. عدّل السيرة واحفظها، ثم أعد تشغيل التطبيق وتحقق من الاستمرار في التخزين.
4. أنشئ مسودة جديدة دون بيانات ثم ارجع؛ يجب ألا تنشأ سيرة فارغة لمجرد فتح المحرر.
5. احذف سيرة تجريبية وتحقق من اختفائها من الرئيسية والمفضلة.
6. عند تعذّر الحفظ، تحقق من رسالة خطأ وبقاء بيانات المسودة قابلة لإعادة المحاولة.

### 4. استيراد JSON

1. استورد resume_full.json من زر الاستيراد في الرئيسية.
2. راجع المعاينة وعدّل حقلاً قبل الحفظ، ثم افتح منشئ السيرة.
3. تحقق من الأقسام العشرة والروابط وتقنيات المشروع والتصنيف المخصّص.
4. جرّب لصق محتوى JSON نفسه مباشرة.
5. جرّب JSON تالفاً، أو جذراً ليس كائناً، أو نوع حقل غير صحيح؛ يجب عرض خطأ مفهوم دون فقد السيرة الحالية.
6. ألغِ نافذة اختيار الملف وتحقق من عدم إنشاء سيرة.

### 5. استيراد TXT وPDF وحدوده

1. استورد resume_simple.txt وتحقق من الاسم والبريد والهاتف والمهارات، ومن بقاء النص في الملخص للمراجعة.
2. جرّب PDF بسيطاً يحتوي نص ASCII غير مشفّر بخط بسيط وعمليات نص مدعومة؛ راجع كل حقل مستخرج يدوياً.
3. جرّب PDF مصوّراً أو مشفّراً أو ذا ترميز خطوط غير مدعوم، وتحقق من رسالة خطأ مفيدة.
4. لا تتوقع OCR أو استخراجاً عاماً من جميع ملفات PDF. الملف الذي يتضمن ToUnicode أو Type0 أو Identity encoding يُرفض بدلاً من تخمين الأحرف.
5. ملفات PDF المصدّرة من التطبيق تستخدم خطوطاً مضمنة، وقد لا يقبلها مستورد PDF البسيط. استخدم JSON للنقل الكامل ذهاباً وإياباً.
6. الحد الأقصى لحجم ملف الاستيراد 10 ميجابايت، مع حد داخلي إضافي لفك ضغط تدفقات PDF.

هذه الحدود تعني أن مطلب استيراد أي سيرة PDF بالكامل غير متحقق. لم تُضف مكتبة لاستخراج PDF أو OCR التزاماً بقيد الاعتماديات.

### 6. تصدير JSON والعودة منه

1. من المحرر أو المعاينة اختر تصدير JSON ثم الحفظ.
2. استورد الملف المحفوظ كسيرة جديدة وقارن الأقسام والروابط والتخصيص.
3. جرّب مشاركة JSON وإلغاء لوحة المشاركة.
4. تحقق من عدم ظهور نجاح عند إلغاء حوار الحفظ.
5. مسار الصورة الشخصية في JSON مرجع محلي؛ الصورة ليست مضمّنة، وقد لا تتوفر على جهاز آخر.

### 7. معاينة PDF والتخصيص

1. افتح المعاينة لكل من Modern وClassic وBusiness وTechnical وATS.
2. تحقق من ظهور جميع الصفحات ومن عدم قص النصوص العربية أو الروابط الطويلة.
3. في Technical يجب أن تظهر المهارات والمشاريع قبل الخبرة والتعليم.
4. غيّر لوناً وخطاً وحجماً دون حفظ، ثم حدّث المعاينة. يجب ألا تُعدّل السيرة المخزنة بعد.
5. اختر التراجع وتحقق من استعادة التخصيص المحفوظ.
6. احفظ التخصيص وأعد فتح السيرة للتحقق من استمراره.
7. غادر مع تغييرات غير محفوظة وجرّب خيارات الحفظ والتجاهل والإلغاء.
8. النص العربي يستخدم Cairo لضمان اتصال الحروف، حتى عند اختيار خط إنجليزي مختلف.

### 8. حفظ PDF والطباعة والمشاركة والجودة

1. اختر حفظ PDF وحدد وجهة، ثم افتح الملف بعارض خارجي.
2. قارن عدد الصفحات بالمعاينة، وجرّب تحديد النص ونسخه.
3. أضف صورة شخصية واضحة، وصدّر بالجودات الصغيرة والقياسية والعالية؛ تتغير دقة الصورة إلى حد أقصى 96/256/768 بكسل مع الحفاظ على النسبة.
4. النص يظل متجهياً في كل الخيارات؛ دون صورة قد لا يوجد فرق ملحوظ في حجم الملفات.
5. جرّب الطباعة إلى طابعة متاحة أو إلى PDF، واختبر الإلغاء.
6. جرّب المشاركة لتطبيق فعلي، واختبر الإلغاء؛ لا ينبغي عرض نجاح عند إلغاء عملية تدعم الإبلاغ عن الإلغاء.
7. تحقق من رسالة مفيدة عند تعذّر الحفظ أو عدم توفر الطباعة أو المشاركة.

### 9. ATS

1. افحص سيرة ناقصة ثم سيرة مكتملة، وتحقق من تغيّر المجموع والأقسام والمشاكل.
2. تحقق من ترتيب المشاكل: حرجة ثم تحذيرات ثم معلومات.
3. استخدم الانتقال للتعديل، ثم عد إلى الفحص وأعد التحليل.
4. اختر استخدام قالب ATS، ثم افتح المعاينة وتحقق من اختفاء ضوابط التخصيص الزخرفي.
5. صدّر وتحقق من النص الأسود والخط الواحد وعدم وجود صورة أو أعمدة جانبية.
6. التقييم حساب إرشادي بقواعد التطبيق من 100، وليس نتيجة اختبار من نظام توظيف خارجي أو ضماناً لقبول السيرة.

### 10. المفضلة والبحث

1. أضف سيرة إلى المفضلة، وافتح شاشة المفضلة ثم أزلها.
2. أغلق التطبيق وافتحه للتأكد من استمرار حالة المفضلة.
3. ابحث في القوالب بكلمات عربية وإنجليزية وجرّب مرشح الفئة وإلغاء البحث.
4. جرّب عبارة بلا نتائج وتحقق من الحالة الفارغة وإمكانية إعادة الضبط.

### 11. الإعدادات

1. بدّل الوضع الفاتح والداكن ووضع النظام، وافتح كل شاشة جديدة وحوار الألوان.
2. جرّب تغيير اللغة مع الاحتفاظ بالبيانات.
3. اختبر مشاركة التطبيق والتقييم والدعم بعد ضبط بيانات النشر الحقيقية أدناه.
4. اختبر مسح البيانات على بيانات تجريبية فقط؛ تحقق من شاشة التأكيد ثم من خلو القوائم.

### 12. التجاوب

اختبر عروض 320 و800 و1920 بكسل، والوضع الأفقي 800×400، وتكبير النص إلى 200%. تحقق من الوصول لكل زر بالتمرير ومن عدم وجود تجاوزات أو نص مقصوص. المعاينة ولوحة التخصيص متجاورتان على التابلت وسطح المكتب، ومتتابعتان على الجوال. هذه المقاسات اختُبرت آلياً؛ ما زال اختبارها على الجهاز والعارض الأصلي مطلوباً.

## بيانات النشر المطلوبة

SettingsService يدعم APP_STORE_URL وSUPPORT_EMAIL عبر dart-define. القيم الافتراضية الموروثة ليست بيانات نشر متحققاً منها لهذا المشروع. معرّف Android الحالي com.example.cv_builder_pro بينما رابط المتجر الافتراضي يشير إلى حزمة مختلفة. لا تنشر التطبيق قبل ضبط الرابط والبريد والمعرّف والتوقيع بمعلوماتك الفعلية.

يمكن تمرير الإعدادات عند التشغيل أو البناء؛ استبدل القيم التوضيحية التالية قبل التنفيذ:

```powershell
flutter run -d windows --dart-define=APP_STORE_URL=https://YOUR_ACTUAL_STORE_URL --dart-define=SUPPORT_EMAIL=YOUR_ACTUAL_SUPPORT_EMAIL
```

المشروع يستخدم توقيع debug في إعداد release الحالي لـAndroid؛ إعداد نشر المتجر ليس جزءاً مكتملاً من هذه المراجعة.

## التسليمات

- ملفات lib مطبقة داخل المشروع، وليست مجرد أمثلة في المحادثة.
- الدفعات الكاملة محفوظة تحت deliveries/part_2_batch_*.md.
- القائمة الفعلية للملفات: deliveries/final_file_manifest.txt.
- تقرير فحص صفحات PDF السابق: deliveries/part_2_batch_22_pdf_verification.json.
- ملفات الاستيراد التجريبية: deliveries/fixtures/.
- الاختبارات: test/؛ أدوات فحص PDF: tool/verify_ats_pdf.py وtool/verify_pdf_templates.py.

## قائمة ملفات lib المرقمة

1. lib\app\app.dart
2. lib\app\bindings\initial_binding.dart
3. lib\app\index.dart
4. lib\app\routes\app_pages.dart
5. lib\app\routes\app_routes.dart
6. lib\app\theme\app_colors.dart
7. lib\app\theme\app_text_styles.dart
8. lib\app\theme\app_theme.dart
9. lib\controllers\ats_controller.dart
10. lib\controllers\index.dart
11. lib\controllers\language_controller.dart
12. lib\controllers\resume_controller.dart
13. lib\controllers\template_controller.dart
14. lib\controllers\theme_controller.dart
15. lib\core\constants\app_constants.dart
16. lib\core\constants\storage_keys.dart
17. lib\core\extensions\context_extensions.dart
18. lib\core\index.dart
19. lib\core\services\ats_analyzer_service.dart
20. lib\core\services\pdf_export_service.dart
21. lib\core\services\pdf_service.dart
22. lib\core\services\resume_export_service.dart
23. lib\core\services\resume_import_service.dart
24. lib\core\services\settings_service.dart
25. lib\core\services\simple_pdf_text_extractor.dart
26. lib\core\services\storage_service.dart
27. lib\core\utils\app_snackbar.dart
28. lib\core\utils\ats_scorer.dart
29. lib\core\utils\date_formatter.dart
30. lib\core\utils\responsive.dart
31. lib\core\utils\validators.dart
32. lib\data\index.dart
33. lib\data\json\resume_json.dart
34. lib\data\models\achievement.dart
35. lib\data\models\ats_score_model.dart
36. lib\data\models\certificate.dart
37. lib\data\models\course.dart
38. lib\data\models\education.dart
39. lib\data\models\experience.dart
40. lib\data\models\language.dart
41. lib\data\models\project.dart
42. lib\data\models\resume_model.dart
43. lib\data\models\skill.dart
44. lib\data\models\template_fields.dart
45. lib\data\models\template_model.dart
46. lib\data\repositories\resume_repository.dart
47. lib\features\ats_checker\index.dart
48. lib\features\ats_checker\presentation\pages\ats_checker_screen.dart
49. lib\features\ats_checker\presentation\widgets\ats_issues_list.dart
50. lib\features\ats_checker\presentation\widgets\ats_score_gauge.dart
51. lib\features\ats_checker\presentation\widgets\ats_suggestions_card.dart
52. lib\features\favorites\index.dart
53. lib\features\favorites\presentation\pages\favorites_screen.dart
54. lib\features\favorites\presentation\widgets\favorite_card.dart
55. lib\features\home\index.dart
56. lib\features\home\presentation\pages\home_screen.dart
57. lib\features\home\presentation\widgets\home_header.dart
58. lib\features\home\presentation\widgets\marquee_header.dart
59. lib\features\home\presentation\widgets\recent_activity_card.dart
60. lib\features\home\presentation\widgets\stats_cards.dart
61. lib\features\home\presentation\widgets\template_carousel.dart
62. lib\features\import_resume\index.dart
63. lib\features\import_resume\presentation\pages\import_resume_screen.dart
64. lib\features\import_resume\presentation\widgets\import_loading_widget.dart
65. lib\features\import_resume\presentation\widgets\import_option_card.dart
66. lib\features\import_resume\presentation\widgets\import_preview_widget.dart
67. lib\features\index.dart
68. lib\features\language\index.dart
69. lib\features\language\presentation\pages\language_selection_screen.dart
70. lib\features\resume_builder\index.dart
71. lib\features\resume_builder\presentation\dialogs\achievement_dialog.dart
72. lib\features\resume_builder\presentation\dialogs\certificate_dialog.dart
73. lib\features\resume_builder\presentation\dialogs\course_dialog.dart
74. lib\features\resume_builder\presentation\dialogs\education_dialog.dart
75. lib\features\resume_builder\presentation\dialogs\experience_dialog.dart
76. lib\features\resume_builder\presentation\dialogs\language_dialog.dart
77. lib\features\resume_builder\presentation\dialogs\project_dialog.dart
78. lib\features\resume_builder\presentation\pages\preview_screen.dart
79. lib\features\resume_builder\presentation\pages\resume_builder_screen.dart
80. lib\features\resume_builder\presentation\steps\achievements_step.dart
81. lib\features\resume_builder\presentation\steps\additional_info_step.dart
82. lib\features\resume_builder\presentation\steps\certificates_step.dart
83. lib\features\resume_builder\presentation\steps\courses_step.dart
84. lib\features\resume_builder\presentation\steps\education_step.dart
85. lib\features\resume_builder\presentation\steps\experience_step.dart
86. lib\features\resume_builder\presentation\steps\interests_step.dart
87. lib\features\resume_builder\presentation\steps\languages_step.dart
88. lib\features\resume_builder\presentation\steps\personal_info_step.dart
89. lib\features\resume_builder\presentation\steps\projects_step.dart
90. lib\features\resume_builder\presentation\steps\skills_step.dart
91. lib\features\resume_builder\presentation\templates\ats_pdf_template.dart
92. lib\features\resume_builder\presentation\templates\base_pdf_template.dart
93. lib\features\resume_builder\presentation\templates\business_pdf_template.dart
94. lib\features\resume_builder\presentation\templates\classic_pdf_template.dart
95. lib\features\resume_builder\presentation\templates\modern_pdf_template.dart
96. lib\features\resume_builder\presentation\templates\pdf_template_options.dart
97. lib\features\resume_builder\presentation\templates\styled_pdf_template.dart
98. lib\features\resume_builder\presentation\templates\technical_pdf_template.dart
99. lib\features\resume_builder\presentation\widgets\customization_panel.dart
100. lib\features\resume_builder\presentation\widgets\navigation_buttons.dart
101. lib\features\resume_builder\presentation\widgets\pdf_preview_view.dart
102. lib\features\resume_builder\presentation\widgets\resume_entry_card.dart
103. lib\features\resume_builder\presentation\widgets\resume_form_dialog.dart
104. lib\features\resume_builder\presentation\widgets\resume_json_export_button.dart
105. lib\features\resume_builder\presentation\widgets\step_indicator.dart
106. lib\features\settings\index.dart
107. lib\features\settings\presentation\pages\settings_screen.dart
108. lib\features\settings\presentation\widgets\language_dialog.dart
109. lib\features\settings\presentation\widgets\profile_header.dart
110. lib\features\settings\presentation\widgets\settings_card.dart
111. lib\features\splash\index.dart
112. lib\features\splash\presentation\pages\splash_screen.dart
113. lib\features\splash\presentation\widgets\particle_painter.dart
114. lib\features\templates\index.dart
115. lib\features\templates\presentation\pages\templates_screen.dart
116. lib\features\templates\presentation\widgets\template_grid_card.dart
117. lib\main.dart
118. lib\shared_widgets\app_button.dart
119. lib\shared_widgets\app_empty_state.dart
120. lib\shared_widgets\app_loading.dart
121. lib\shared_widgets\app_section_header.dart
122. lib\shared_widgets\app_text_field.dart
123. lib\shared_widgets\index.dart
124. lib\shared_widgets\responsive_builder.dart
125. lib\translations\app_translations.dart
126. lib\translations\ar_sa.dart
127. lib\translations\en_us.dart
128. lib\translations\index.dart


## نتيجة محاولة تشغيل Android

جرت محاولتان على الهاتف SM N975U بمعرّف R38M906C8XE. توقفتا أثناء assembleDebug بالرسالة:

```text
java.io.IOException: Unable to establish loopback connection
Error: Gradle task assembleDebug failed with exit code 1
```

استُخدم في المحاولة الثانية تفضيل IPv4 داخل عملية البناء فقط، ولم يغيّر النتيجة. لم تتغير إعدادات Java أو شبكة النظام بصورة دائمة. لم يصل التطبيق إلى مرحلة تثبيت وتشغيل مؤكدة على الهاتف؛ هذه مشكلة في مسار بناء Gradle المحلي، وليست نتيجة اختبار ناجح للتطبيق.

بعد معالجة اتصال Gradle المحلي وتراخيص Android في بيئة التطوير، أعد المحاولة:

```powershell
flutter run -d R38M906C8XE --no-pub
```

إذا استمر الخطأ، يمكن جمع تفاصيله من مجلد android عبر:

```powershell
.\gradlew.bat assembleDebug --stacktrace
```

لم يُحسم السبب الجذري لخطأ الاتصال المحلي في هذه المراجعة. تفعيل Developer Mode يعالج العائق الذي ظهر في محاولة Windows فقط؛ لا توجد نتيجة تثبت أنه يعالج خطأ Android.
