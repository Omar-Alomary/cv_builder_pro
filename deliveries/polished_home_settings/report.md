# تقرير توحيد الخطوط وتصميم الرئيسية والإعدادات

## التغييرات

- HomeCtaCard: gradient بنفسجي/أزرق ناعم، زوايا 24، ظل خفيف، ودائرة شفافة للأيقونة. العنوان 20/700 والوصف 13/400.
- الأزرار الثلاثة في صف واحد: زر أساسي متدرج وزران بإطار، زوايا 12، ارتفاع تصميم أدنى 44، ومسافات 8. مساحة اللمس تبقى 48 على الأقل، وتسمح الأزرار بزيادة الارتفاع عند تكبير النص. الأيقونات الصغيرة تتكيف مع ضيق العرض وتكبير الخط.
- الضغط يخفض opacity إلى 0.76 ويطلق HapticFeedback.lightImpact. تعذر الاهتزاز لا يمنع فتح الشاشة.
- SettingsProfileHeader: خلفية محايدة فاتحة بتدرج خفيف، وصورة 72 بإطار أبيض وظل خفيف، وعنوان 18/700 ووصف 12 وزر Outlined بحجم خط 12 وأيقونة كاميرا. ارتفاع عادي يقارب 120–140، ويزيد عند الحاجة لاستيعاب تكبير النص.
- AppTextStyles: تصحيح اختيار Cairo عند اتجاه العربية حتى عندما تستخدم Material لغة إنجليزية احتياطية؛ الإنجليزية تستخدم Poppins. كان هذا سبب استخدام Poppins لبعض الكلمات والأزرار في واجهة عربية رغم اتجاهها الصحيح.
- قسم السير الأخيرة وقسم القوالب المميزة يعرضان العنوان و«عرض الكل» في Row واحد حتى عند 320px. المسافة إلى المحتوى 8، وبين الأقسام 16.
- بقي ربط الصورة والحفظ والاستيراد ومسارات التنقل كما هي. الملفات القديمة HomePrimaryAction وProfileHeader أصبحت مداخل توافق للبطاقات الجديدة، دون كسر استخداماتها الحالية.

## التحقق

| الحالة | النتيجة |
|---|---|
| اسم الخط الفعلي للأزرار والعناوين بالعربية والإنجليزية | ✅ Cairo/Poppins عبر AppTextStyles |
| حالة الضغط والاهتزاز وفشل خدمة الاهتزاز | ✅ |
| الصف الثلاثي عند 320px مع تكبير النص إلى الضعف | ✅ |
| عرض الكل بجانب العنوان عند 320px في RTL وLTR | ✅ |
| مصفوفة الرئيسية والإعدادات من 320 إلى 1920 مع Light/Dark وتكبير النص | ✅ |
| فتح الإنشاء والاستيراد وفحص ATS من الهاتف | ✅ |
| التحليل | ✅ No issues found |
| جميع الاختبارات | ✅ 667 اختباراً ناجحاً |

[سجل التحليل](flutter_analyze.log) — [سجل الاختبارات](flutter_test.log) — [سجل التشغيل](flutter_run.log).

## لقطات Samsung SM-N975U

| الشاشة | فاتح | داكن |
|---|---|---|
| الرئيسية | [لقطة](home_light.png) | [لقطة](home_dark.png) |
| الإعدادات | [لقطة](settings_light.png) | [لقطة](settings_dark.png) |

عرض 320 منطقي فعلي على الهاتف: [الرئيسية](home_320.png) — [الإعدادات](settings_320.png).

لقطات العرض الصغير بدقة 960×2027 عند كثافة 480، أي عرض Flutter منطقي 320. أُعيدت دقة الهاتف السابقة 1080×2280 وكثافته دون تغيير، وأُعيد تفضيل الوضع الفاتح بعد التصوير. [توثيق القياسات والاستعادة](device_metrics.json).

## الملفات

- lib/features/home/presentation/widgets/home_cta_card.dart — جديد
- lib/features/home/presentation/widgets/home_primary_action.dart — مدخل توافق
- lib/features/home/presentation/pages/home_screen.dart
- lib/features/home/index.dart
- lib/features/settings/presentation/widgets/settings_profile_header.dart — جديد
- lib/features/settings/presentation/widgets/profile_header.dart — مدخل توافق
- lib/features/settings/index.dart
- lib/shared_widgets/app_section_header.dart — خيار inlineAction اختياري، والاستخدامات الأخرى تحتفظ بسلوكها
- lib/app/theme/app_text_styles.dart
- test/home/polished_cards_test.dart — جديد

لا اعتماديات جديدة ولا تغييرات في منطق السير أو استيرادها.
