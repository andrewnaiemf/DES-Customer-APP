import 'dart:async';
import 'dart:developer';

import 'package:app/business_logic/layout/cubit/layout_cubit.dart';
import 'package:app/helpers/cache_helper.dart';
import 'package:app/persentation/screens/offers/offers_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

/// الصفحات اللي ممكن رابط عميق يوديله.
enum DeepLinkTarget { home, offers }

/// ═══════════════════════════════════════════════════════════════════════════
/// 🔗 DeepLinkService
/// ───────────────────────────────────────────────────────────────────────────
/// بيستقبل روابط الـ App Links / Universal Links (سواء التطبيق اتفتح منها وهو
/// مقفول "cold start" أو وهو شغال "warm") وبيوجّه المستخدم للصفحة الصح.
///
/// شرط العميل: التوجيه يحصل بس لو المستخدم عامل Login. لو مش مسجّل، بنخزّن
/// الهدف ونكمّله بعد نجاح الدخول (عن طريق [consumePending] من LayoutScreen).
/// ═══════════════════════════════════════════════════════════════════════════
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// هدف منتظر التنفيذ بعد تسجيل الدخول (أو بعد ما الـ Layout يجهز).
  DeepLinkTarget? _pending;

  /// بيتحط true أول ما LayoutScreen تتفتح (يعني المستخدم داخل التطبيق فعلاً
  /// والـ Navigator جاهز للتوجيه). ده بديل أأمن من الاعتماد على التوقيت/الـ splash.
  bool _layoutReady = false;

  bool get hasPending => _pending != null;

  /// تهيئة الخدمة. بتتنادى مرة واحدة من main() قبل runApp.
  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;

    // 1) الرابط اللي فتح التطبيق وهو مقفول (cold start).
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        log('🔗 DeepLink (cold start): $initialUri');
        _handleUri(initialUri, fromColdStart: true);
      }
    } catch (e) {
      log('⚠️ DeepLink getInitialLink error: $e');
    }

    // 2) الروابط اللي بتيجي والتطبيق شغال (warm).
    _sub ??= _appLinks.uriLinkStream.listen(
      (uri) {
        log('🔗 DeepLink (warm): $uri');
        _handleUri(uri, fromColdStart: false);
      },
      onError: (e) => log('⚠️ DeepLink stream error: $e'),
    );
  }

  /// تحويل الـ URI لهدف معروف. بترجّع null لو الرابط مش متعرّف.
  ///
  /// بيدعم شكلين:
  ///   • Universal/App Link: `https://driveshield.net/app/<target>`
  ///     → pathSegments = ['app', '<target>']
  ///   • Custom scheme:      `des://app/<target>`
  ///     → host = 'app'، pathSegments = ['<target>']
  /// بنوحّد الشكلين في ليستة واحدة شكلها ['app', '<target>'].
  DeepLinkTarget? _parse(Uri uri) {
    final List<String> segments = uri.scheme == 'des'
        ? <String>[uri.host, ...uri.pathSegments] // host = أول segment
        : uri.pathSegments; // مثال: ['app', 'home']

    if (segments.length >= 2 && segments[0] == 'app') {
      switch (segments[1]) {
        case 'home':
          return DeepLinkTarget.home;
        case 'offers':
          return DeepLinkTarget.offers;
      }
    }
    return null;
  }

  bool get _isLoggedIn {
    final token = CacheHelper.getString(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  void _handleUri(Uri uri, {required bool fromColdStart}) {
    final target = _parse(uri);
    if (target == null) {
      log('🔗 DeepLink: رابط مش متعرّف → $uri');
      return;
    }

    log('🔗 DeepLink: target=$target loggedIn=$_isLoggedIn '
        'layoutReady=$_layoutReady cold=$fromColdStart');

    // الهدف بيتخزّن دايماً، والتنفيذ بيحصل بس لما الـ Layout يجهز (_flush).
    _pending = target;

    // مش عامل Login → نسيب الهدف منتظر بس. المستخدم أصلاً هيتوجّه لشاشة الدخول
    // (من InitialScreen)، وأول ما يسجّل دخول وLayoutScreen تتفتح هيتنفّذ الهدف
    // عبر consumePending. مفيش داعي ندفع LoginScreen هنا عشان ميحصلش لوب.
    if (!_isLoggedIn) {
      log('🔗 DeepLink: مش مسجّل دخول → الهدف منتظر لحد بعد اللوجين: $target');
      return;
    }

    // مسجّل دخول: لو الـ Layout جاهز نفّذ علطول، غير كده استنى consumePending.
    _flush();
  }

  /// بتتنادى من LayoutScreen.initState. بتعلّم إن الشاشة جاهزة وبتنفّذ أي هدف منتظر.
  void consumePending(BuildContext context) {
    _layoutReady = true;
    _flush();
  }

  /// بتنفّذ الهدف المنتظر بس لو الـ Layout جاهز والمستخدم مسجّل دخول.
  /// لو لسه مش جاهز، بتسيب _pending زي ما هو لحد ما consumePending تتنادى.
  void _flush() {
    final target = _pending;
    if (target == null) return;
    if (!_layoutReady || !_isLoggedIn) {
      log('🔗 DeepLink: الهدف منتظر (layoutReady=$_layoutReady '
          'loggedIn=$_isLoggedIn) → $target');
      return;
    }

    _pending = null;
    log('🔗 DeepLink: تنفيذ التوجيه → $target');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = _navigatorKey?.currentState;
      switch (target) {
        case DeepLinkTarget.home:
          // إحنا أصلاً جوه Layout → نتأكد بس إن التاب على الهوم (index 0).
          try {
            LayoutCubit.get(nav!.context).changeScreen(0);
          } catch (e) {
            log('🔗 DeepLink: changeScreen(0) فشل: $e');
          }
          // ارجع لأول شاشة في الستاك لو المستخدم كان فاتح شاشة فوق الـ Layout.
          nav?.popUntil((route) => route.isFirst);
          break;
        case DeepLinkTarget.offers:
          nav?.push(
            MaterialPageRoute(builder: (_) => const OffersScreen()),
          );
          break;
      }
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}

/// مشاركة رابط عميق عبر شيت المشاركة الأصلي للنظام (Android/iOS).
Future<void> shareDeepLink(String url, {String? message}) async {
  final text = (message == null || message.isEmpty) ? url : '$message\n$url';
  await Share.share(text);
}
