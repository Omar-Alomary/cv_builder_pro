# إصلاح الصفحة الرئيسية والقوالب واللغة

## التغييرات

- صفحة رئيسية بخطوة واضحة لإنشاء السيرة واستيرادها، شريط أرقام صغير، وسير حديثة أفقية قبل القوالب. بقيت إجراءات التعديل والحذف والمفضلة وفحص ATS والتنقل تعمل عبر المسارات الحالية.
- معاينات مرسومة بعناصر Flutter للقوالب الخمسة، بلا emoji، في الصفحة الرئيسية وشبكة القوالب. الضغط على المعاينة يفتح نافذة أكبر مع اختيار القالب أو إغلاقها دون تغيير البيانات.
- ربط جذر التطبيق بتفضيل اللغة باستخدام Obx، وتوحيد اتجاه العرض، وتحديث الصفحة الرئيسية الموجودة عند العودة من الإعدادات. لم تتغير آلية حفظ اللغة أو منطق السيرة أو المستودعات.

## قرارات العرض

- اعتمدت ارتفاع 180 للعارض في الحجم العادي لتلبية شرط الصفحة الخفيفة؛ يزيد الارتفاع عند تكبير النص. كان الطلب يتضمن أيضاً أبعاد 220×260 متعارضة مع هذا الارتفاع.
- نسب عرض العارض .85/.5/.35. الشبكة 2/3/4 أعمدة ونسب .65/.75/.85، مع حد أدنى لارتفاع البطاقة يسمح بعرض الأزرار والنصوص المكبرة دون تجاوز الحدود.
- المعاينات توضيح لتخطيط القالب بعناصر Flutter، وليست صور صفحات PDF المصدّرة.
- لا اعتماديات جديدة.

## التحقق

- نجحت مجموعة الاختبارات الكاملة: 581 اختباراً. السجل: tmp/ui_redesign/focused_final_suite.log.
- نجحت 100 حالة موجهة للصفحة الرئيسية والقوالب واللغة، وتشمل معاينة القوالب الخمسة وإلغاء الاختيار، والعودة من الإعدادات بعد تبديل العربية والإنجليزية دون إعادة إنشاء حالة الصفحة الرئيسية أو فقد السير.
- تغطية أحجام 320 و390 و600 و1024 و1920، والعربية والإنجليزية والوضعين الليلي والنهاري وتكبير النص للضعف.
- flutter analyze: لا ملاحظات.
- الصور من اختبارات Flutter؛ ليست إثبات تشغيل أصلي على الجهاز. تشغيل Windows السابق توقف بسبب ضرورة تفعيل Developer Mode لدعم الروابط الرمزية.

## صور المراجعة

- [الرئيسية الإنجليزية](focused_home_light_en.png)
- [الرئيسية العربية الداكنة](focused_home_dark_ar.png)
- [الرئيسية على سطح المكتب](focused_home_desktop.png)
- [شبكة القوالب العربية](focused_templates_dark_ar.png)
- [تخطيطات القوالب الخمسة](focused_template_layouts.png)

## الملفات الأساسية

- lib/app/app.dart
- lib/features/home/presentation/pages/home_screen.dart
- lib/features/home/presentation/widgets/home_primary_action.dart
- lib/features/home/presentation/widgets/stats_cards.dart
- lib/features/home/presentation/widgets/recent_activity_card.dart
- lib/features/home/presentation/widgets/template_carousel.dart
- lib/features/templates/presentation/pages/templates_screen.dart
- lib/features/templates/presentation/widgets/template_grid_card.dart
- lib/features/templates/presentation/widgets/template_mini_preview.dart
- lib/translations/en_us.dart
- lib/translations/ar_sa.dart

كما حُدّثت ملفات التصدير index والاختبارات المرتبطة بالتصميم الجديد.
