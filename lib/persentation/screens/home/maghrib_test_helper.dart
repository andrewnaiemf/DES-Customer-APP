import 'package:flutter/material.dart';
import 'package:app/persentation/screens/home/maghrib_countdown_test.dart';

/// 🧪 دالة سريعة لفتح صفحة اختبار عداد المغرب
/// 
/// استخدمها في أي مكان في التطبيق:
/// ```dart
/// openMaghribTest(context);
/// ```
void openMaghribTest(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const MaghribCountdownTest(),
    ),
  );
}

/// 🎯 Widget زر سريع لفتح صفحة الاختبار (للتطوير فقط)
/// 
/// أضفه في أي مكان تريده:
/// ```dart
/// MaghribTestButton()
/// ```
class MaghribTestButton extends StatelessWidget {
  const MaghribTestButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => openMaghribTest(context),
      backgroundColor: const Color(0xFF28E6C5),
      child: const Icon(
        Icons.science,
        color: Colors.black87,
      ),
      tooltip: 'Test Maghrib Countdown',
    );
  }
}

/// 🎯 Widget زر صغير في AppBar (للتطوير فقط)
class MaghribTestIconButton extends StatelessWidget {
  const MaghribTestIconButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => openMaghribTest(context),
      icon: const Icon(Icons.science),
      tooltip: 'Test Maghrib Countdown',
    );
  }
}
