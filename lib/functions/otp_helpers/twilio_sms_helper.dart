//
// Twilio helper (disabled). Secrets removed for public/private repo safety.
// Use backend SMS (Taqnyat) instead of client-side Twilio credentials.
//
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// class TwilioSmsHelper
// {
//   static String accountSid = const String.fromEnvironment('TWILIO_ACCOUNT_SID');
//   static String contentSid = const String.fromEnvironment('TWILIO_CONTENT_SID');
//   static String authToken = const String.fromEnvironment('TWILIO_AUTH_TOKEN');
//   static String fromNumber = const String.fromEnvironment('TWILIO_FROM_NUMBER');
//
//   static Future<http.Response?> sendOtpWithTemplate({
//     required String toNumber,
//     required String code,
//   }) async {
//     throw UnimplementedError('Use backend OTP endpoints instead of Twilio client credentials.');
//   }
//
//   static Future<http.Response?> sendOtpTest({
//     required String toNumber,
//     String code = '000000',
//   }) async {
//     throw UnimplementedError('Use backend OTP endpoints instead of Twilio client credentials.');
//   }
// }
