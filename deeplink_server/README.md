# 🔗 Deep Links — ملفات السيرفر (driveshield.net)

الملفات دي بتترفع على دومين **driveshield.net** عشان الـ App Links (أندرويد) و
الـ Universal Links (iOS) تشتغل، وعشان اللي معندوش التطبيق يتحوّل للستور.

## الروابط النهائية اللي بتتشارك من التطبيق
| الصفحة | الرابط |
|--------|--------|
| Home   | `https://driveshield.net/app/home`   |
| Offers | `https://driveshield.net/app/offers` |

> أي رابط تحت `/app/...` بيشتغل. عايز تزوّد صفحات بعدين؟ ضيف الـ target في
> `lib/core/deep_links/deep_link_service.dart` (دالة `_parse`).

## 🔁 الـ Fallback الذكي (مهم)

لما تدوس الرابط من **متصفح داخلي** لتطبيق تاني (واتساب/انستجرام/Gmail) أو من
**شريط عنوان Safari**، آبل **بتتجاهل الـ Universal Link** وبتحمّل `app.html` في
المتصفح — حتى لو التطبيق متسطّب. عشان كده `app.html` دلوقتي:

1. بيجرّب يفتح التطبيق المتسطّب الأول عبر custom scheme: `des://app/home`.
2. لو فتح (الصفحة راحت للخلفية) → **مفيش تحويل للستور**.
3. لو لسه في الصفحة بعد ~1.5 ثانية → التطبيق مش متسطّب → يحوّل للستور،
   ويظهر زرّين يدويين (افتح في التطبيق / نزّله من المتجر) كـ fallback نهائي.

> الـ custom scheme `des` لازم يكون مسجّل في:
> - iOS: `ios/Runner/Info.plist` → `CFBundleURLTypes` (مضاف ✅)
> - Android: `AndroidManifest.xml` → intent-filter لـ `des://app` (مضاف ✅)
> - Flutter: `DeepLinkConfig.scheme` + `_parse` بيدعمه (مضاف ✅)
>
> ⚠️ **بعد أي تعديل على `app.html` لازم ترفعه على السيرفر تاني** (في `public/app.html`).

> ملاحظة: حتى مع التحسين ده، بعض المتصفحات الداخلية بتمنع الـ custom scheme
> برضه — وقتها بيشتغل الزرّ اليدوي "افتح في التطبيق". الحل الأنظف للمستخدم إنه
> يفتح اللينك من **Notes/Messages** أو يعمل **⋯ → Open in Safari** من جوه واتساب.

---

## 1) املأ البيانات الناقصة

### أ) `assetlinks.json` (أندرويد)
استبدل `REPLACE_WITH_PLAY_APP_SIGNING_SHA256` ببصمة SHA-256.

- **الأهم:** بصمة **Play App Signing** من
  Play Console → اختر التطبيق → **Test and release → App integrity → App signing**
  → انسخ `SHA-256 certificate fingerprint`.
- (اختياري لكن مفضّل) ضيف كمان بصمة **Upload key** عشان التست بالـ APK اللي
  بتوقّعه بنفسك. لو مش محتاجها، امسح السطر التاني.

تطلع بصمة الـ keystore المحلي كده:
```bash
keytool -list -v -keystore your-release-key.jks -alias your-alias
```

### ب) `apple-app-site-association` (iOS)
استبدل `REPLACE_WITH_APPLE_TEAM_ID` بالـ **Team ID** (10 حروف/أرقام).
- موجود في: Apple Developer → Membership → Team ID
- أو في Xcode → Runner → Signing & Capabilities → تحت اسم الـ Team.

النتيجة لازم تبقى زي: `"appID": "ABCDE12345.com.DES.DESUserApp"`

---

## 2) الرفع على السيرفر (Laravel)

### الملفات الثابتة (الأسهل): حطّها في `public/`
```
public/.well-known/assetlinks.json
public/.well-known/apple-app-site-association
```
> ملف الـ AASA **من غير امتداد** `.json`.

⚠️ **شروط لازمة:**
- HTTPS صحيح (شهادة سليمة).
- **من غير أي redirect** (لا 301/302) على المسارين دول.
- `apple-app-site-association` لازم يترجّع بـ **`Content-Type: application/json`**.

لو السيرفر مبيخدمش ملفات `.well-known` كملفات ثابتة، استخدم Routes بدالها:

```php
// routes/web.php

// iOS Universal Links
Route::get('/.well-known/apple-app-site-association', function () {
    return response()
        ->file(public_path('.well-known/apple-app-site-association'),
               ['Content-Type' => 'application/json']);
});

// Android App Links
Route::get('/.well-known/assetlinks.json', function () {
    return response()
        ->file(public_path('.well-known/assetlinks.json'),
               ['Content-Type' => 'application/json']);
});

// صفحة التحويل للستور (بتشتغل بس لو التطبيق مش متسطّب)
// لو التطبيق متسطّب النظام بيمسك الرابط ويفتح التطبيق قبل ما توصل هنا.
Route::get('/app/{path?}', function () {
    return response()->file(public_path('app.html'));
})->where('path', '.*');
```

> تأكّد إن مفيش راوت تاني عام بيمسك `/app/...` قبل ده، ومفيش redirect على
> `/.well-known/*` (شائع إن بعض إعدادات الـ middleware بتعمل redirect لـ www
> أو https — لازم المسارين دول يرجّعوا 200 مباشرة).

---

## 3) التحقّق إن كل حاجة شغالة

```bash
# لازم يرجّعوا 200 + JSON من غير redirect
curl -I https://driveshield.net/.well-known/assetlinks.json
curl -I https://driveshield.net/.well-known/apple-app-site-association
```

- **أندرويد:** أداة جوجل الرسمية
  `https://developers.google.com/digital-asset-links/tools/generator`
  أو: `https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://driveshield.net&relation=delegate_permission/common.handle_all_urls`
- **iOS:** افتح في المتصفح:
  `https://app-site-association.cdn-apple.com/a/v1/driveshield.net`
  (كاش آبل — بياخد وقت يتحدّث).

### تست سريع على الأجهزة
- **أندرويد (التطبيق متسطّب):**
  ```bash
  adb shell am start -a android.intent.action.VIEW -d "https://driveshield.net/app/offers"
  ```
  للتأكد إن الـ verification نجح:
  ```bash
  adb shell pm get-app-links com.DES.DESUserApp
  ```
  لازم تلاقي `driveshield.net: verified`.
- **iOS:** ابعت الرابط في الملاحظات/واتساب ودوس عليه (مش من شريط Safari).

---

## ملاحظات مهمة
- **الـ store-fallback مش deferred:** اللي يدوس الرابط من غير تطبيق هيتحوّل
  للستور، بس بعد ما يسطّب التطبيق **مش** هيتفتح على نفس الصفحة أوتوماتيك
  (ده محتاج خدمة زي Branch/AppsFlyer). أول فتح هيبدأ عادي.
- لو الموقع بيشتغل على **www** بدل الـ apex (أو العكس)، اتأكد إن الـ
  verification files موجودة على الدومين اللي الروابط بتستخدمه. إحنا داعمين
  الاتنين في الـ manifest والـ entitlements.
- بعد أي تعديل على `assetlinks.json`، أندرويد بيعيد الـ verification عند
  إعادة تثبيت التطبيق أو عبر `adb shell pm verify-app-links --re-verify`.
