import 'package:app/helpers/cache_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Constants {
  static String accessToken = CacheHelper.getString(key: "access_token") ?? "";
  static String appleStore = "https://apps.apple.com/us/app/des-trading/id6497325292";
  static String googleStore = "https://play.google.com/store/apps/details?id=com.DES.DESUserApp";
}

class ApiConstants {
  // 🖥️ Local backend (/var/www/html/retail)
  // Web/desktop → localhost | Android emulator → 10.0.2.2
  static String get _localHost => kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  static String get baseURL => _localHost;
  static String get baseURL2 => '$_localHost/api/';
  static String get stoarge => '$_localHost/storage/';
  static String get warrantyBaseURL => _localHost;

  // 🌐 Production (switch manually when needed):
  // static const baseURL = 'https://driveshield.net';
  // static const baseURL2 = 'https://driveshield.net/api/';
  // static const stoarge = 'https://driveshield.net/storage/';
  // static const warrantyBaseURL = 'https://driveshield.net';
}

class EndPoints {
  static const login = '/api/user/login';
  static const loginOtpSend = '/api/user/login/otp/send';
  static const loginOtpVerify = '/api/user/login/otp/verify';
  static const register = '/api/user/register';
  static const registerDocuments = '/api/user/register/documents';
  static const registerSendOtp = '/api/user/register/otp/send';
  static const registerVerifyOtp = '/api/user/register/otp/verify';
  static const checkPhone = '/api/user/check-phone';
  static const me = '/api/user/me';
  static const forgetPassword = '/api/user/forget-password';
  static const profile = '/api/user/me';
  static const orders = '/api/user/orders';
  static const products = '/api/user/products';
  static const invoices = '/api/user/invoices';
  static const receipts = '/api/user/receipts';
  static const accountStatement = '/api/user/account-statement';
  static const statistic = '/api/user/statistic';
  static const notifications = '/api/user/notifications';
  static const loyalityPoints = '/api/user/loyaltyPoints';
  static const readNotification = '/api/user/notification';
  static const readAllNotifications = '/api/user/notifications/read-all';
  static const checkLoyalty = '/api/user/loyalty-discount';
  static changeLocale(String userId) => '/api/user/customers/$userId';
  static const sendOtp = 'password/otp/send';
  static const verifyOtp = 'password/otp/verify';

  // Warranty endpoints
  static const warrantyIssue = '/api/user/warranty/issue';
  static const warrantyGet = '/api/user/warranty';

  // offers endpoints
  static acceptOffer(String offerId) => '/api/user/offers/$offerId/accept';
  static declineOffer(String offerId) => '/api/user/offers/$offerId/decline';
  static const getOffers = '/api/user/offers';
  static const getAppVersion = '/api/user/app-versions?app=customer';
}
