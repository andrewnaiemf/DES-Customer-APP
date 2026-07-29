import 'package:flutter/material.dart';

/// Widget لتغليف العناصر المستهدفة في الجولة
class TourTarget extends StatelessWidget {
  final GlobalKey tourKey;
  final Widget child;

  const TourTarget({
    super.key,
    required this.tourKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: tourKey,
      child: child,
    );
  }
}

/// Extension لتسهيل الاستخدام
extension TourTargetExtension on Widget {
  Widget withTourKey(GlobalKey key) {
    return TourTarget(
      tourKey: key,
      child: this,
    );
  }
}
