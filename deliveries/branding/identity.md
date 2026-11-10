# CV Maker Pro — هوية التطبيق

- الاسم الظاهر: **CV Maker Pro** (Android وiOS وواجهة التطبيق).
- الوصف العربي: صانع السيرة.
- اللون الأساسي وشاشة البداية: `#4F46E5`.
- الأيقونة: مستند أبيض وعلامة صح على تدرج بنفسجي/أزرق، دون شعار Flutter.
- أصل المتجر: `assets/icon/app_icon.png` — PNG معتم، 1024×1024.
- رمز شاشة البداية: `assets/icon/splash_mark.png` — PNG شفاف بهوامش آمنة لقناع Android 12.
- الإنشاء: أداة image_gen المدمجة؛ حُفظ الناتج الأصلي أيضاً في مجلد generated_images. اقتصر تجهيز الملف على تغيير الحجم إلى 1024×1024.
- لم تتغير معرفات الحزمة أو منطق الحفظ أو الاستيراد.

## وصف التوليد المستخدم

Use case: logo-brand. Create a polished production mobile app launcher icon for CV Maker Pro. Exactly square 1024x1024 pixels, full bleed opaque background, smooth premium indigo purple to cobalt blue gradient (#4F46E5 to #2563EB). Centered crisp white document silhouette with one folded upper corner, three simple indigo text lines, and a bold white checkmark in a small indigo/blue circular badge overlapping its lower right. Clean minimal geometric design, strong contrast at tiny launcher sizes. Entire document and badge contained within central 60% of canvas for Android adaptive icon safe area. Subtle depth only, no photorealism. No text, letters, watermark, Flutter logo, exterior border or pre-rounded outer corners. This is the final app icon artwork, not a phone mockup.

## أدوات التوليد

- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons): 0.14.4.
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash): 2.4.7، متوافق مع Flutter الحالي؛ الإصدار 2.4.8 يتعارض مع نسخة meta المثبتة من flutter_test.
- وُحّدت إضافة شاشة البداية مع Android Gradle Plugin 8.11.1 وcompileSdk 36 المستخدمين في المشروع، لتجنب تنزيل AGP 8.7 ومنصة API 35 إضافيين. التعديل محصور بهذه الإضافة في `android/build.gradle.kts`.

```powershell
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter analyze --no-pub
flutter test --no-pub
flutter run --no-pub -d R38M906C8XE -t lib/main.dart
```

على Windows ظهر تنبيه الحاجة إلى Developer Mode لإنشاء روابط إضافات سطح المكتب أثناء pub get؛ عولج بروابط Junction داخل مجلدات ephemeral في المشروع، دون تغيير إعدادات النظام. أُعيد `flutter pub get` وانتهى بنجاح: `Got dependencies!`، والسجل في `pub_get_final.log`.

## وصف إنشاء الرمز الشفاف

Use case: background-extraction. Edit target: supplied CV Maker Pro icon. Produce a transparent PNG companion for Android adaptive launcher foreground and native splash. Keep the same white folded document, three indigo lines and blue circular badge with white checkmark, same smooth edges and subtle depth. Remove ONLY the entire square purple/blue background to real transparency. Fit the complete document and badge together into the central 50% of a square 1024x1024 transparent canvas (25% transparent padding on every side); center the whole combined mark. No square tile behind the mark, no added text, no watermark. Preserve white paper as opaque white and blue check badge as opaque blue. The outside must be genuine alpha transparency, not a checkerboard illustration.

`Picked up JAVA_TOOL_OPTIONS` رسالة إعداد Java طبيعية وليست خطأً بحد ذاتها.

أصول iOS واسم التطبيق وشاشة البداية مولّدة؛ تشغيل iOS يحتاج macOS/Xcode وجهازاً أو محاكي iOS، ولم يُختبر على Samsung.
