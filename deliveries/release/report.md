# Release APK — CV Maker Pro

31 أكتوبر 2026 — Samsung SM-N975U، الرقم R38M906C8XE.

- APK: `build/app/outputs/flutter-apk/app-release.apk`.
- الحجم: **60,034,954 بايت**، أي **57.25 MiB** (يعرض Flutter: 57.3MB).
- SHA-256: `4D3F138709127E6CCD4D58ACCDA4D2050D222B07D65297E6FFEF10144D60A8B8`.
- الإصدار: 1.0.0، build 1، minSdk 24، targetSdk 36.
- التوقيع: شهادة Android Debug الموجودة؛ لا Keystore مخصص جديد. تحقق apksigner ناجح، APK Signature Scheme v2.
- `pkgFlags` على الهاتف لا تتضمن DEBUGGABLE: النسخة المثبتة Release فعلاً.
- تفعيل R8 minification وresource shrinking وربط proguard-rules.pro؛ ملفات configuration/mapping/usage/resources الناتجة موجودة في `build/app/outputs/mapping/release/`.
- flutter analyze: No issues found!، السجل analyze.log.
- لم تُرصد FATAL EXCEPTION أو Unhandled Exception أو MissingPluginException أو E/flutter في سجل عملية التطبيق أثناء هذه التجربة؛ device.log وartifact_manifest.json.

## فحص نسخة Release الفعلية على الهاتف

| العملية | النتيجة | الدليل |
|---|---|---|
| تثبيت APK وتشغيله | ✅ Success؛ التطبيق يعمل | install.log، release_launch.png |
| ATS بدون سيرة | ✅ EmptyState دون انهيار | ats_empty.png |
| إنشاء سيرة وإدخال الاسم والبريد والهاتف | ✅ | resume_created.png |
| الحفظ التلقائي والحفظ اليدوي | ✅ ظهرت السيرة في الرئيسية بعد إغلاق المحرر | saved_resume_home.png |
| تحليل ATS | ✅ نتيجة 21/100 مناسبة لبيانات الاختبار الناقصة | ats_result.png |
| Go to edit من مشكلة ATS | ✅ فتح السيرة المحفوظة في المحرر | ats_edit.png |
| توليد PDF وعرض صفحته | ✅ شوهد الاسم والبريد والهاتف والخط على الهاتف | pdf_preview.png |
| تصدير PDF عبر نافذة الحفظ الأصلية | ✅ ملف فعلي 7020 بايت، يبدأ %PDF وينتهي %%EOF | pdf_saved.png، exported_test.pdf |
| تغيير اللغة من الإعدادات | ✅ الرئيسية انتقلت للعربية وRTL | release_final_home.png |
| تنظيف بيانات الفحص | ✅ حذف سيرة Release QA 20261031 وملفها التجريبي فقط | الرئيسية النهائية تظهر صفر سير |

التطبيق باقٍ مثبتاً ومفتوحاً على الرئيسية العربية. لم يتغير منطق العمل. هذا فحص تشغيل للميزات المذكورة على نسخة Release، وليس ادعاءً بإعادة فحص كل حالات التطبيق أو تشغيل مجموعة الاختبارات الـ671 في هذه المهمة.

## ملفات symbols المطابقة لهذا APK

المسار المطلوب: `build/app/outputs/symbols/`، ويحتوي:

- app.android-arm.symbols
- app.android-arm64.symbols
- app.android-x64.symbols

نسخة محفوظة خارج build: `deliveries/release/symbols/` مع `r8-mapping.txt`. احتفظ بهذه الملفات مع هذا APK؛ يلزم التطابق بين النسخة وخريطة رموزها عند تشخيص الأخطاء.

## البناء

```powershell
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
adb -s R38M906C8XE install -r -t build/app/outputs/flutter-apk/app-release.apk
```

توقف التنزيل البعيد لمكتبات محرك Release في المحاولة الأولى. استُخدمت مكتبات المحرك الرسمية من Flutter SDK المحلي، بنفس engine hash `587c18f873b8ab57330422bce09047420d9c7f42`، دون تغيير بايتات الكلاسات أو ملفات libflutter.so. جرى التحقق أن كلاسات embedding الـ417 مطابقة لمكتبة Maven الرسمية لنفس الإصدار.

المستودع المحلي في `tmp/release_engine_maven/`. دعم المستودع اختياري ومحصور بمجموعة io.flutter في android/build.gradle.kts؛ بدونه يُستخدم مسار التنزيل المعتاد. لإعادة استخدامه على هذا الجهاز:

```powershell
$env:CV_FLUTTER_ENGINE_MAVEN = (Resolve-Path tmp/release_engine_maven).Path
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

تفاصيل التوقيع في signature.log والبناء الناجح في build_final.log. GetX وpdf مكتبتا Dart؛ تتعامل معهما أداة تعتيم Dart، بينما تحمي قواعد R8 نقاط JNI وplugin registration وPDF printing وParcelable الخاصة بمكتبات Google إن وُجدت.

التعتيم يصعّب قراءة أسماء الكود، ولا يعني تشفير موارد التطبيق أو منع الهندسة العكسية بالكامل. [توثيق Flutter](https://docs.flutter.dev/deployment/obfuscate).
