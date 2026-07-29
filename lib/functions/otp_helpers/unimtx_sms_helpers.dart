/// Deprecated: do NOT send SMS from the Flutter client.
/// Registration / password OTP must go through the Laravel backend (Taqnyat).
class UnimatrixSmsHelper {
  static Future<Never> sendOtp({
    required String toNumber,
    required String code,
  }) async {
    throw UnsupportedError(
      'Unimatrix client SMS is disabled. '
      'Use backend endpoints: /api/user/register/otp/send or /api/password/otp/send (Taqnyat).',
    );
  }
}
