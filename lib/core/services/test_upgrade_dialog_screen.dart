import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app/theme/colors.dart';
import 'package:easy_localization/easy_localization.dart';

/// 🧪 صفحة اختبار لمعاينة شكل الـ Update Dialog
/// 
/// لفتح الصفحة دي، ضيفي في الـ FloatingActionButton:
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => TestUpgradeDialogScreen(),
/// ));
/// ```

class TestUpgradeDialogScreen extends StatelessWidget {
  const TestUpgradeDialogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // عرض الـ Dialog فوراً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUpgradeDialog(context);
    });

    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: const Text('🧪 معاينة Update Dialog'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 20),
            const Text(
              'اضغط الزر لعرض الـ Dialog',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _showUpgradeDialog(context),
              icon: const Icon(Icons.system_update),
              label: const Text('عرض Update Dialog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض الـ Dialog بتصميم Cupertino (iOS Style)
  void _showUpgradeDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false, // منع الإغلاق بالضغط خارج الـ Dialog
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text(
            'تحديث متاح',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'نسخة جديدة من التطبيق متاحة الآن! يرجى التحديث للحصول على أحدث الميزات والتحسينات.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
              // معلومات النسخة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildVersionRow('النسخة الحالية:', '1.0.0'),
                    const SizedBox(height: 6),
                    _buildVersionRow('النسخة الجديدة:', '1.1.0'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ملاحظات الإصدار
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '📝 ملاحظات الإصدار:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• إصلاحات للأخطاء وتحسينات في الأداء\n'
                      '• تحسينات في واجهة المستخدم\n'
                      '• إضافة ميزات جديدة\n'
                      '• تحديثات أمنية مهمة',
                      style: TextStyle(fontSize: 11, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                // في التطبيق الحقيقي، هنا يفتح رابط المتجر
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم فتح رابط المتجر (App Store / Google Play)'),
                    backgroundColor: Color(0xFF007AFF),
                  ),
                );
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: const Text(
                'تحديث',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVersionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: CupertinoColors.systemGrey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF007AFF),
          ),
        ),
      ],
    );
  }
}
