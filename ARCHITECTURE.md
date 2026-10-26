# معمارية المشروع (Clean Architecture)

التطبيق مبني على **Clean Architecture** بنمط **feature-first**: كل ميزة (feature) مستقلة وتنقسم إلى ثلاث طبقات، واتجاه الاعتماد دائمًا من الخارج للداخل:

```
presentation  ──►  domain  ◄──  data
 (واجهة + Cubit)   (قواعد العمل)   (مصادر البيانات)
```

## الهيكل

```
lib/
├── main.dart                     نقطة البداية (تهيئة DI واللغة)
├── app/
│   ├── app.dart                  MaterialApp + BlocProvider + التنقل بين الأدوار
│   └── navigation/               غلاف التبويبات لكل دور (admin / finance / head / ...)
├── core/                         كل ما هو مشترك بين الميزات
│   ├── theme/
│   │   ├── app_colors.dart       ألوان دلالية (brand / surface / text / حالات)
│   │   ├── app_palette.dart      ألوان خام مرتبة حسب العائلة (neutral, blue, red, ...)
│   │   ├── app_text_theme.dart   الخطوط وأنماط النص
│   │   ├── app_component_themes.dart   AppBar / الأزرار / Divider / SnackBar
│   │   └── app_theme.dart        يجمع كل ما سبق في ThemeData واحد
│   ├── localization/             التحكم في لغة التطبيق
│   ├── security/                 تجزئة كلمات المرور (PasswordHasher)
│   ├── di/                       تسجيل التبعيات (GetIt)
│   ├── network/                  إعدادات الـ API والعميل
│   ├── errors/                   Failure classes
│   ├── utils/                    أدوات عامة (تنسيق العملة ...)
│   └── widgets/                  ويدجتات مشتركة (SnackBar, Splash, BrandMark)
├── features/
│   └── <feature>/
│       ├── domain/
│       │   ├── entities/         كائنات الأعمال (بدون اعتماد على Flutter قدر الإمكان)
│       │   ├── repositories/     عقود (abstract)
│       │   └── usecases/         حالة استخدام واحدة لكل ملف
│       ├── data/
│       │   ├── datasources/      mock / API / SharedPreferences stores
│       │   ├── models/           نماذج التحويل من/إلى JSON
│       │   ├── repositories/     تنفيذ العقود
│       │   └── services/         سياسات وخدمات تعتمد على المخازن
│       └── presentation/
│           ├── controllers/      Cubit + State
│           ├── screens/          الشاشات
│           ├── widgets/          ويدجتات الميزة (sheets / dialogs / بطاقات)
│           └── utils/            مساعدات العرض (نصوص ثنائية اللغة، مُصدِّرات)
├── l10n/                         ملفات الترجمة (مولّدة من arb)
└── generated/                    ملفات مولّدة
```

## الميزات

| الميزة | الوصف |
|---|---|
| `auth` | تسجيل الدخول وتحديد الدور (`LoginUseCase` → `AuthRepository`) |
| `admin` | حساب الأدمن: طابور القرارات، الحسابات، الأمان، سجل التدقيق، شاشات PUSE |
| `finance` | المشرف المالي: السحوبات، الاشتراكات، التسويات، المطابقة البنكية |
| `head_supervisor` | رئيس المشرفين: المشرفون، الشكاوى، التدخل، المحفظة |
| `merchants` | مشرف التجار |
| `products` | مشرف المنتجات |
| `wasalny_supervisor` | مشرف وصلني |
| `services_supervisor` | مشرف الخدمات |
| `messaging` | الإشعارات المحلية والمحادثات بين الحسابات |

## قواعد

1. **الاستيراد بمسار package** دائمًا: `import 'package:barwah_app/...'`، لا مسارات نسبية `../../`.
2. `domain` لا يستورد `data` ولا `presentation`.
3. الألوان لا تُكتب كـ `Color(0x...)` داخل الشاشات: استخدم `AppColors` (الدلالي) ثم `AppPalette` (الخام).
4. كل Cubit يتلقى حالات الاستخدام عبر المُنشئ ويُسجَّل في `core/di/injection_container.dart`.
5. الكيانات (`entities`) منفصلة عن المخازن (`datasources`) حتى لو كانت محلية.
6. الاختبارات تعكس هيكل `lib/`: `test/features/<feature>/...`، والمساعدات المشتركة في `test/support/`.

## ملاحظات انتقالية

- بعض شاشات الميزات ما زالت تقرأ من المخازن المحلية (`*Store`) مباشرة بدل المرور بـ repository/usecase. عند ربط الـ backend يُنقل كل مخزن خلف `Repository` + `UseCase` دون تغيير الشاشات.
- المصادقة الحالية محلية (`AuthRepositoryImpl`) وتُستبدل بنداء الـ backend.
