import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🔄 Directional Arrow Icon - يتغير حسب اتجاه اللغة
// ═══════════════════════════════════════════════════════════════════════════
class DirectionalArrow extends StatelessWidget {
  final Color? color;
  final double? size;
  final ArrowDirection direction;

  const DirectionalArrow({
    super.key,
    this.color,
    this.size,
    this.direction = ArrowDirection.forward,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = context.locale.languageCode == 'ar';
    
    // تحديد الأيقونة الأساسية حسب الاتجاه
    IconData icon;
    
    if (isRTL) {
      // في RTL: الرجوع يكون لليمين، التقدم لليسار
      switch (direction) {
        case ArrowDirection.forward:
          icon = Icons.arrow_back_rounded; // سهم لليسار = للأمام في RTL
          break;
        case ArrowDirection.back:
          icon = Icons.arrow_forward_rounded; // سهم لليمين = للخلف في RTL
          break;
        case ArrowDirection.forwardIos:
          icon = Icons.keyboard_arrow_left; // سهم iOS لليسار
          break;
        case ArrowDirection.backIos:
          icon = Icons.keyboard_arrow_right; // سهم iOS لليمين = للخلف في RTL
          break;
      }
    } else {
      // في LTR نستخدم الأيقونات العادية
      switch (direction) {
        case ArrowDirection.forward:
          icon = Icons.arrow_forward_rounded;
          break;
        case ArrowDirection.back:
          icon = Icons.arrow_back_rounded;
          break;
        case ArrowDirection.forwardIos:
          icon = Icons.keyboard_arrow_right;
          break;
        case ArrowDirection.backIos:
          icon = Icons.keyboard_arrow_left;
          break;
      }
    }

    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}

enum ArrowDirection {
  forward,
  back,
  forwardIos,
  backIos,
}
