# Part 3 — تقرير فحص المعاينة على Samsung SM-N975U

تاريخ الفحص: 24 أكتوبر 2026. الجهاز: Samsung SM-N975U، Android 12، الرقم R38M906C8XE.

اكتملت مراجعة 45 تركيبة في Light وDark: **90 حالة**. حُفظت 90 لقطة شاشة أولى و90 ملف PDF مولّداً على الهاتف، إضافة إلى 10 لقطات للصفحة الثانية في الحالات متعددة الصفحات. راجعت صور شاشة الهاتف بصرياً، ثم دُقّقت الملفات للتحقق من النصوص والتواريخ وحدود الصفحة.

## طريقة التحقق وحدوده

شُغّلت شاشة PreviewScreen الأصلية وخدمة PdfExportService الأصلية وعارض printing على الجهاز، عبر نقطة تشغيل للفحص في tool/device_preview_matrix.dart. جرى التنقل آلياً بين بيانات عينات مؤقتة؛ المراجعة البصرية أُجريت على لقطات الهاتف الفعلية، وليست محاكاة سطح مكتب. يوضح شريط QA NEXT معرّف الحالة في الصور.

مستودع الفحص للقراءة فقط ولا يقرأ السير الشخصية أو يحفظ بيانات العينات. بعد الفحص أُعيد بناء وتشغيل lib/main.dart، وظل التطبيق مثبتاً. تظهر الشاشة الرئيسية العادية السير الخمس المحفوظة واللغة العربية والوضع الفاتح: [دليل تشغيل التطبيق](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_app_restored.png).

العينات تضم الاسم وبيانات الاتصال والملخص والخبرة والتعليم والمهارات واللغات والمشاريع، وتواريخ وأرقاماً ونسباً مئوية. هذه المراجعة تثبت نتائج العينات المرفقة؛ لا تعني اختبار كل طول محتمل لكل حقل أو كل رمز وخط خارج الأصول الحالية. الأقسام الاختيارية غير المعبأة في العينة لم يُدّعَ فحصها يدوياً في هذه المصفوفة.

## نتائج الفحص

| المعيار | النتيجة |
|---|---|
| السيرة تظهر أولاً، ولوحة التخصيص مغلقة عند الفتح | ✅ 90 حالة |
| الحروف العربية والإنجليزية بلا مربعات ظاهرة | ✅ 90 حالة |
| اتجاه المقاطع الإنجليزية داخل العربية والفواصل | ✅ بعد الإصلاح |
| التواريخ والهاتف والأرقام ضمن حدود الصفحة | ✅ 90 ملفاً |
| الورقة بيضاء في الوضعين | ✅ |
| ملف PDF لا يتغير بصرياً بتغيير وضع الواجهة | ✅ مقارنة جميع صفحات أزواج Light/Dark |
| ATS نص أسود فقط دون صور أو زخارف ملونة | ✅ 18 حالة |
| ترتيب الأقسام الظاهرة | ✅؛ Technical يقدّم المهارات والمشاريع |
| عدم قص النصوص أو تجاوز هوامش الصفحة | ✅ مراجعة بصرية وتدقيق إحداثيات النص |
| الحالات متعددة الصفحات | ✅؛ فُتحت الصفحة الثانية على الهاتف |
| Flutter analyze | ✅ No issues found |
| الاختبارات القائمة | ✅ 620 / 620 |
| التطبيق العادي مثبت ويعمل بعد الفحص | ✅ |

## جدول التركيبات الكامل

كل صف يمثل لغة وخطاً وقالباً، مع فحص مستقل للوضعين.

| القالب | اللغة | اختيار الخط | Light | Dark |
|---|---|---|---|---|
| Modern | عربي | Cairo | ✅ | ✅ |
| Modern | عربي | Sukar | ✅ | ✅ |
| Modern | عربي | Poppins | ✅ * | ✅ * |
| Modern | إنجليزي | Cairo | ✅ | ✅ |
| Modern | إنجليزي | Sukar | ✅ | ✅ |
| Modern | إنجليزي | Poppins | ✅ | ✅ |
| Modern | مختلط | Cairo | ✅ | ✅ |
| Modern | مختلط | Sukar | ✅ | ✅ |
| Modern | مختلط | Poppins | ✅ * | ✅ * |
| Classic | عربي | Cairo | ✅ | ✅ |
| Classic | عربي | Sukar | ✅ | ✅ |
| Classic | عربي | Poppins | ✅ * | ✅ * |
| Classic | إنجليزي | Cairo | ✅ | ✅ |
| Classic | إنجليزي | Sukar | ✅ | ✅ |
| Classic | إنجليزي | Poppins | ✅ | ✅ |
| Classic | مختلط | Cairo | ✅ | ✅ |
| Classic | مختلط | Sukar | ✅ | ✅ |
| Classic | مختلط | Poppins | ✅ * | ✅ * |
| Business | عربي | Cairo | ✅ | ✅ |
| Business | عربي | Sukar | ✅ | ✅ |
| Business | عربي | Poppins | ✅ * | ✅ * |
| Business | إنجليزي | Cairo | ✅ | ✅ |
| Business | إنجليزي | Sukar | ✅ | ✅ |
| Business | إنجليزي | Poppins | ✅ | ✅ |
| Business | مختلط | Cairo | ✅ | ✅ |
| Business | مختلط | Sukar | ✅ | ✅ |
| Business | مختلط | Poppins | ✅ * | ✅ * |
| Technical | عربي | Cairo | ✅ | ✅ |
| Technical | عربي | Sukar | ✅ | ✅ |
| Technical | عربي | Poppins | ✅ * | ✅ * |
| Technical | إنجليزي | Cairo | ✅ | ✅ |
| Technical | إنجليزي | Sukar | ✅ | ✅ |
| Technical | إنجليزي | Poppins | ✅ | ✅ |
| Technical | مختلط | Cairo | ✅ | ✅ |
| Technical | مختلط | Sukar | ✅ | ✅ |
| Technical | مختلط | Poppins | ✅ * | ✅ * |
| ATS | عربي | Cairo | ✅ † | ✅ † |
| ATS | عربي | Sukar | ✅ † | ✅ † |
| ATS | عربي | Poppins | ✅ † | ✅ † |
| ATS | إنجليزي | Cairo | ✅ † | ✅ † |
| ATS | إنجليزي | Sukar | ✅ † | ✅ † |
| ATS | إنجليزي | Poppins | ✅ † | ✅ † |
| ATS | مختلط | Cairo | ✅ † | ✅ † |
| ATS | مختلط | Sukar | ✅ † | ✅ † |
| ATS | مختلط | Poppins | ✅ † | ✅ † |

\* عند اختيار Poppins للنص العربي أو المختلط، يُستخدم Cairo لدعم العربية. هذه نتيجة سليمة وفق آلية الخط البديل؛ ليست حروفاً عربية من ملف Poppins.

† قالب ATS يلتزم Cairo Regular دائماً وفق مواصفاته، حتى عندما يكون اختيار التخصيص Sukar أو Poppins؛ لذلك لا تعني هذه العلامات أن ATS يستخدم ثلاثة خطوط مختلفة.

## الإصلاحات المنفذة

عُزلت المقاطع اللاتينية باتجاه LTR داخل الفقرات العربية، مع قياس عرضها وخط أساسها بالخط الفعلي. أُبقيت الفواصل الطرفية ضمن السياق العربي. عالج ذلك انتقال النقطة إلى بداية الجملة الإنجليزية، وارتفاع النص الإنجليزي عن السطر، وتغيّر ترتيب الحقول الإنجليزية المفصولة بعلامة |.

التعديل في عرض PDF فقط: pdf_directional_text.dart وربطه بقالب ATS وبعارض القوالب الأخرى StyledPdfTemplate. لم تتغير نماذج البيانات أو الحفظ أو الاستيراد أو منطق العمل، ولم تُضف اعتمادية.

Technical أنتج صفحتين في خمس تركيبات (عشر حالات مع الوضعين): عربي Cairo وPoppins، إنجليزي Cairo، ومختلط Cairo وPoppins. انتقل قسم اللغات كاملاً للصفحة الثانية، دون نص مفقود أو عنوان منفرد. لقطات الصفحات الثانية محفوظة بأسماء تنتهي بـ _page2.png.

## صور القوالب من الهاتف

- [Modern](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_modern_preview.png)
- [Classic](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_classic_preview.png)
- [Business](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_business_preview.png)
- [Technical](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_technical_preview.png)
- [ATS](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_ats_preview.png)

الصور الخمس عينات مختلطة اللغة. صورة Technical تستخدم Sukar؛ الأربع الأخرى Cairo.

## أدلة الفحص

- [سجل الحالات والصور وبصمات PDF](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/capture_manifest.json)
- [تدقيق ملفات PDF](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/pdf_audit.json)
- [سجل الاختبارات الـ620](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_preview_tests.log)
- [سجل التحليل](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_preview_analyze.log)
- [سجل إعادة تشغيل التطبيق العادي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_app_restored.log)
- [مراجعة الصفحات الثانية من لقطات الهاتف](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_extra_pages.jpg)

الملفات المعتمدة لهذا التقرير داخل device_matrix_v5؛ المجلدات السابقة توثق جولات ما قبل اكتمال الإصلاح.


صور مقارنة Modern: [عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_modern_ar.jpg)، [إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_modern_en.jpg)، [مختلط](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_modern_mixed.jpg).

صور مقارنة Classic: [عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_classic_ar.jpg)، [إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_classic_en.jpg)، [مختلط](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_classic_mixed.jpg).

صور مقارنة Business: [عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_business_ar.jpg)، [إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_business_en.jpg)، [مختلط](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_business_mixed.jpg).

صور مقارنة Technical: [عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_technical_ar.jpg)، [إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_technical_en.jpg)، [مختلط](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_technical_mixed.jpg).

صور مقارنة ATS: [عربي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_ats_ar.jpg)، [إنجليزي](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_ats_en.jpg)، [مختلط](C:/Flutter/flutter_apps/cv_builder_pro/deliveries/ui_redesign/device_matrix_v5/review_ats_mixed.jpg).

## التشغيل النهائي

من مجلد المشروع:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d R38M906C8XE -t lib/main.dart
```

عند الاكتفاء بتثبيت التطبيق وتركه مفتوحاً دون جلسة تصحيح مستمرة:

```powershell
flutter run -d R38M906C8XE -t lib/main.dart --no-resident
```

رسالة `Picked up JAVA_TOOL_OPTIONS` طبيعية في هذا المشروع: تُظهر أن Java طبّق إعداد مجلد الملفات المؤقتة المعرّف لتشغيل Gradle. ليست خطأ تشغيل بحد ذاتها، وقد ظهرت أثناء البناء الناجح المثبت في السجل.

## القيود المتبقية

- PDF المكوّن من صور فقط يحتاج OCR لاستخراج النص؛ لا توجد إضافة OCR ضمن الاعتماديات المسموح بها.
- Poppins لا يزوّد الحروف العربية هنا؛ Cairo هو الخط البديل، وATS ثابت على Cairo.
- نتائج المصفوفة تخص الجهاز والعينات والخطوط المرفقة. مراجعة عينات من صفحة أو صفحتين لا تعني فحصاً يدوياً لكل سيرة طويلة أو كل قسم اختياري.

