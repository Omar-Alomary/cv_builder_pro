# تقرير تعديل الرئيسية والإعدادات

تم تنفيذ التصميم والتحقق منه على Samsung SM-N975U.

## ما تغير

- البطاقة الرئيسية: الأيقونة بجانب عمود النصوص، وثلاثة أزرار متساوية في صف واحد: ابدأ، استيراد، فحص ATS. أُزيل زر ATS السفلي المكرر.
- الأزرار تحتفظ بمساحة لمس لا تقل عن 48px، وتسمح بلف النص دون قصه عند تكبيره.
- هيدر الإعدادات: gradient خفيف، وصورة دائرية 64px في بداية الصف حسب الاتجاه، واسم 16px ونص فرعي 11px وزر تغيير صورة صغير.
- بطاقات الإعدادات: عنوان 14px، وصف 11px، أيقونة 18px، مسافات 8px، وحشو 12px. مفتاح الوضع الداكن يبقى بجانب النص حين تتسع الشاشة.
- ProfileController يقرأ profile_image عبر ResumeRepository، ويحفظ التغيير في المفتاح نفسه ثم يطلق update(). الرئيسية والإعدادات تستمعان إليه عبر GetBuilder.
- ProfileAvatar يستخدم ClipOval وImage.file عند وجود الملف؛ الملف المفقود أو غير القابل للعرض يعود إلى الأيقونة الافتراضية.
- منطق حفظ السير واستيرادها لم يتغير، ولم تُضف اعتماديات.

## التحقق

| الاختبار | النتيجة |
|---|---|
| الصف الثلاثي عند 320px، عربي/إنجليزي، Light/Dark، ومقياس نص 1 و2 | ✅ الأزرار في نفس الصف، متساوية العرض، دون تجاوز، وكل إجراء يعمل |
| تغيير صورة من الإعدادات والعودة إلى نفس Home دون إعادة إنشائها | ✅ المفتاح محفوظ والصورة تتحدث فوراً |
| فشل حفظ الصورة | ✅ الصورة السابقة تبقى دون استبدال |
| مسار صورة مفقود | ✅ الأيقونة الافتراضية دون خطأ |
| تغيير اللغة من الإعدادات والرئيسية موجودة | ✅ |
| أزرار ابدأ/استيراد/ATS على الهاتف | ✅ فتحت شاشاتها الصحيحة |
| جميع اختبارات المشروع | ✅ 660 اختباراً ناجحاً |
| flutter analyze | ✅ No issues found |

اختبار تحديث الصورة استخدم ملف PNG مؤقتاً مع مستودع اختبار حتى لا تُستبدل صورة المستخدم على الهاتف. الصور الأربع أدناه لقطات فعلية من الهاتف. أُعيد تفضيل الوضع الفاتح بعد التقاط الوضع الداكن.

## اللقطات والسجلات

| الشاشة | Light | Dark |
|---|---|---|
| الرئيسية | [لقطة](home_light.png) | [لقطة](home_dark.png) |
| الإعدادات | [لقطة](settings_light.png) | [لقطة](settings_dark.png) |

[سجل التحليل](flutter_analyze.log) — [سجل الاختبارات](flutter_test.log) — [سجل التشغيل](flutter_run.log).

## الملفات المعدلة والمضافة

- lib/features/home/presentation/pages/home_screen.dart
- lib/features/home/presentation/widgets/home_primary_action.dart
- lib/features/settings/presentation/pages/settings_screen.dart
- lib/features/settings/presentation/widgets/profile_header.dart
- lib/features/settings/presentation/widgets/settings_card.dart
- lib/controllers/profile_controller.dart — جديد
- lib/controllers/index.dart
- lib/app/bindings/initial_binding.dart
- lib/shared_widgets/profile_avatar.dart — جديد
- lib/shared_widgets/index.dart
- lib/translations/ar_sa.dart
- lib/translations/en_us.dart
- test/home/compact_home_settings_test.dart — جديد
- test/polish/language_home_regression_test.dart
