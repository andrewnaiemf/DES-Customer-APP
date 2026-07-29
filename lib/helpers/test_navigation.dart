import 'package:flutter/material.dart';
import 'package:app/persentation/screens/test/delivery_note_test_screen.dart';

/// للوصول السريع لصفحة اختبار سند التسليم
/// يمكنك استدعاء هذه الدالة من أي مكان في التطبيق
void navigateToDeliveryNoteTest(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DeliveryNoteTestScreen(),
    ),
  );
}
