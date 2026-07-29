/// ═══════════════════════════════════════════════════════════════════════════
/// 🔗 Deep Link Configuration
/// ───────────────────────────────────────────────────────────────────────────
/// روابط الـ App Links / Universal Links المستضافة على دومين driveshield.net.
///
/// السلوك المطلوب:
///   • لو التطبيق متسطّب  → النظام يفتح التطبيق مباشرة على الصفحة المطلوبة.
///   • لو مش متسطّب       → الرابط يفتح في المتصفح وصفحة /app/* على السيرفر
///                          بتحوّله للستور المناسب (App Store / Google Play).
///
/// لازم تتطابق الـ paths هنا مع:
///   • intent-filter في AndroidManifest.xml      (pathPrefix = /app)
///   • Runner.entitlements (applinks:driveshield.net) + ملف AASA (paths: /app/*)
/// ═══════════════════════════════════════════════════════════════════════════
class DeepLinkConfig {
  DeepLinkConfig._();

  /// الدومين اللي بيستضيف ملفات التحقّق وصفحة التحويل.
  static const String host = 'driveshield.net';

  /// الـ base path لكل الروابط العميقة.
  static const String base = 'https://$host/app';

  /// 🔁 Custom URL scheme — آخر حل لفتح التطبيق من المتصفحات الداخلية
  /// (واتساب/انستجرام/Gmail...) اللي آبل بتتجاهل فيها الـ Universal Links.
  /// صفحة app.html بتجرّب تفتح `des://app/<target>` الأول قبل ما تحوّل للستور.
  /// لازم يتطابق مع CFBundleURLSchemes في Info.plist و intent-filter في
  /// AndroidManifest.xml.
  static const String scheme = 'des';

  /// 🔗 رابط الصفحة الرئيسية (Home).
  static const String homeLink = '$base/home';

  /// 🔗 رابط قائمة العروض (Offers).
  static const String offersLink = '$base/offers';
}
