import 'package:flutter/material.dart';
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Brand Colors
// ═══════════════════════════════════════════════════════════════════════════
class AppBrandColors {
  static const Color dark = Color(0xFF081428);
  static const Color purple = Color(0xFF6842E2);
  static const Color lightGreen = Color(0xFF28E6C5);
  static const Color darkGray = Color(0xFFC6CBE0);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color white = Colors.white;
  static const Color background = Color(0xFF15172A);
  static const Color cardDark = Color(0xFF1E2139);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, Color(0xFF8B5CF6)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightGreen, Color(0xFF10B981)],
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 📐 Custom Clippers Collection
// ═══════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────
// 1️⃣ Wave Clipper - موجة علوية
// ─────────────────────────────────────────────────────────────────────────
class WaveClipper extends CustomClipper<Path> {
  final double waveHeight;
  final int waveCount;
  final bool flipVertically;

  WaveClipper({
    this.waveHeight = 30,
    this.waveCount = 3,
    this.flipVertically = false,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    if (flipVertically) {
      path.moveTo(0, waveHeight);

      // Create waves at top
      final waveWidth = size.width / waveCount;
      for (int i = 0; i < waveCount; i++) {
        path.quadraticBezierTo(
          waveWidth * i + waveWidth / 4,
          0,
          waveWidth * i + waveWidth / 2,
          waveHeight,
        );
        path.quadraticBezierTo(
          waveWidth * i + 3 * waveWidth / 4,
          waveHeight * 2,
          waveWidth * (i + 1),
          waveHeight,
        );
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.lineTo(0, size.height - waveHeight);

      // Create waves at bottom
      final waveWidth = size.width / waveCount;
      for (int i = 0; i < waveCount; i++) {
        path.quadraticBezierTo(
          waveWidth * i + waveWidth / 4,
          size.height,
          waveWidth * i + waveWidth / 2,
          size.height - waveHeight,
        );
        path.quadraticBezierTo(
          waveWidth * i + 3 * waveWidth / 4,
          size.height - waveHeight * 2,
          waveWidth * (i + 1),
          size.height - waveHeight,
        );
      }

      path.lineTo(size.width, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    return waveHeight != oldClipper.waveHeight ||
        waveCount != oldClipper.waveCount ||
        flipVertically != oldClipper.flipVertically;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 2️⃣ Curved Clipper - منحنى ناعم
// ─────────────────────────────────────────────────────────────────────────
class CurvedClipper extends CustomClipper<Path> {
  final double curveHeight;
  final bool curveAtTop;

  CurvedClipper({
    this.curveHeight = 50,
    this.curveAtTop = false,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    if (curveAtTop) {
      path.moveTo(0, curveHeight);
      path.quadraticBezierTo(
        size.width / 2,
        0,
        size.width,
        curveHeight,
      );
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.lineTo(0, size.height - curveHeight);
      path.quadraticBezierTo(
        size.width / 2,
        size.height + curveHeight,
        size.width,
        size.height - curveHeight,
      );
      path.lineTo(size.width, 0);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CurvedClipper oldClipper) {
    return curveHeight != oldClipper.curveHeight ||
        curveAtTop != oldClipper.curveAtTop;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 3️⃣ Diagonal Clipper - قطع قطري
// ─────────────────────────────────────────────────────────────────────────
class DiagonalClipper extends CustomClipper<Path> {
  final double diagonalHeight;
  final DiagonalPosition position;

  DiagonalClipper({
    this.diagonalHeight = 60,
    this.position = DiagonalPosition.bottomRight,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    switch (position) {
      case DiagonalPosition.bottomRight:
        path.lineTo(0, size.height - diagonalHeight);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
        break;
      case DiagonalPosition.bottomLeft:
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height - diagonalHeight);
        path.lineTo(size.width, 0);
        break;
      case DiagonalPosition.topRight:
        path.moveTo(0, diagonalHeight);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
      case DiagonalPosition.topLeft:
        path.lineTo(size.width, diagonalHeight);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DiagonalClipper oldClipper) {
    return diagonalHeight != oldClipper.diagonalHeight ||
        position != oldClipper.position;
  }
}

enum DiagonalPosition { topLeft, topRight, bottomLeft, bottomRight }

// ─────────────────────────────────────────────────────────────────────────
// 4️⃣ Notched Clipper - قطع مع تجويف (النوع الأصلي المحسّن)
// ─────────────────────────────────────────────────────────────────────────
class NotchedClipper extends CustomClipper<Path> {
  final double radius;
  final NotchPosition notchPosition;

  NotchedClipper({
    this.radius = 20,
    this.notchPosition = NotchPosition.topBoth,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    switch (notchPosition) {
      case NotchPosition.topBoth:
        path.lineTo(0, 2 * radius);
        path.arcTo(
          Rect.fromCircle(center: Offset(radius, 2 * radius), radius: radius),
          math.pi,
          math.pi / 2,
          false,
        );
        path.lineTo(radius, radius);
        path.lineTo(size.width - radius, radius);
        path.arcTo(
          Rect.fromCircle(center: Offset(size.width - radius, 0), radius: radius),
          math.pi / 2,
          -math.pi / 2,
          false,
        );
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;

      case NotchPosition.topLeft:
        path.lineTo(0, 2 * radius);
        path.arcTo(
          Rect.fromCircle(center: Offset(radius, 2 * radius), radius: radius),
          math.pi,
          math.pi / 2,
          false,
        );
        path.lineTo(radius, radius);
        path.lineTo(size.width, radius);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;

      case NotchPosition.topRight:
        path.lineTo(0, radius);
        path.lineTo(size.width - radius, radius);
        path.arcTo(
          Rect.fromCircle(center: Offset(size.width - radius, 0), radius: radius),
          math.pi / 2,
          -math.pi / 2,
          false,
        );
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;

      case NotchPosition.bottomBoth:
        path.lineTo(0, size.height - 2 * radius);
        path.arcTo(
          Rect.fromCircle(
            center: Offset(radius, size.height - 2 * radius),
            radius: radius,
          ),
          math.pi,
          -math.pi / 2,
          false,
        );
        path.lineTo(radius, size.height - radius);
        path.lineTo(size.width - radius, size.height - radius);
        path.arcTo(
          Rect.fromCircle(
            center: Offset(size.width - radius, size.height),
            radius: radius,
          ),
          -math.pi / 2,
          -math.pi / 2,
          false,
        );
        path.lineTo(size.width, 0);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(NotchedClipper oldClipper) {
    return radius != oldClipper.radius || notchPosition != oldClipper.notchPosition;
  }
}

enum NotchPosition { topBoth, topLeft, topRight, bottomBoth }

// ─────────────────────────────────────────────────────────────────────────
// 5️⃣ Ticket Clipper - شكل التذكرة
// ─────────────────────────────────────────────────────────────────────────
class TicketClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double notchPosition; // 0.0 to 1.0

  TicketClipper({
    this.notchRadius = 20,
    this.notchPosition = 0.3,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchY = size.height * notchPosition;

    // Start from top left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, notchY - notchRadius);

    // Right notch
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, notchY + notchRadius);

    // Left notch
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) {
    return notchRadius != oldClipper.notchRadius ||
        notchPosition != oldClipper.notchPosition;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 6️⃣ Rounded Corner Clipper - زوايا مستديرة مخصصة
// ─────────────────────────────────────────────────────────────────────────
class CustomRoundedClipper extends CustomClipper<Path> {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  CustomRoundedClipper({
    this.topLeft = 0,
    this.topRight = 0,
    this.bottomLeft = 0,
    this.bottomRight = 0,
  });

  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(
        RRect.fromLTRBAndCorners(
          0,
          0,
          size.width,
          size.height,
          topLeft: Radius.circular(topLeft),
          topRight: Radius.circular(topRight),
          bottomLeft: Radius.circular(bottomLeft),
          bottomRight: Radius.circular(bottomRight),
        ),
      );
  }

  @override
  bool shouldReclip(CustomRoundedClipper oldClipper) {
    return topLeft != oldClipper.topLeft ||
        topRight != oldClipper.topRight ||
        bottomLeft != oldClipper.bottomLeft ||
        bottomRight != oldClipper.bottomRight;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 7️⃣ Hexagon Clipper - شكل سداسي
// ─────────────────────────────────────────────────────────────────────────
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = math.min(size.width, size.height) / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(HexagonClipper oldClipper) => false;
}

// ─────────────────────────────────────────────────────────────────────────
// 8️⃣ Star Clipper - شكل نجمة
// ─────────────────────────────────────────────────────────────────────────
class StarClipper extends CustomClipper<Path> {
  final int points;
  final double innerRadiusRatio;

  StarClipper({
    this.points = 5,
    this.innerRadiusRatio = 0.4,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * innerRadiusRatio;

    final angleStep = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = angleStep * i - math.pi / 2;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(StarClipper oldClipper) {
    return points != oldClipper.points ||
        innerRadiusRatio != oldClipper.innerRadiusRatio;
  }
}

// ─────────────────────────────────────────────────────────────────────────
// 9️⃣ Arrow Clipper - شكل سهم
// ─────────────────────────────────────────────────────────────────────────
class ArrowClipper extends CustomClipper<Path> {
  final ArrowDirection direction;
  final double arrowSize;

  ArrowClipper({
    this.direction = ArrowDirection.right,
    this.arrowSize = 20,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    switch (direction) {
      case ArrowDirection.right:
        path.moveTo(0, 0);
        path.lineTo(size.width - arrowSize, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(size.width - arrowSize, size.height);
        path.lineTo(0, size.height);
        break;
      case ArrowDirection.left:
        path.moveTo(arrowSize, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(arrowSize, size.height);
        path.lineTo(0, size.height / 2);
        break;
      case ArrowDirection.up:
        path.moveTo(0, arrowSize);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, arrowSize);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
      case ArrowDirection.down:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height - arrowSize);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(0, size.height - arrowSize);
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(ArrowClipper oldClipper) {
    return direction != oldClipper.direction || arrowSize != oldClipper.arrowSize;
  }
}

enum ArrowDirection { left, right, up, down }

// ─────────────────────────────────────────────────────────────────────────
// 🔟 Bubble Clipper - فقاعة محادثة
// ─────────────────────────────────────────────────────────────────────────
class BubbleClipper extends CustomClipper<Path> {
  final double radius;
  final double tailWidth;
  final double tailHeight;
  final BubbleTailPosition tailPosition;

  BubbleClipper({
    this.radius = 16,
    this.tailWidth = 20,
    this.tailHeight = 15,
    this.tailPosition = BubbleTailPosition.bottomLeft,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final bubbleHeight = size.height - tailHeight;

    // Draw rounded rectangle
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, bubbleHeight),
        Radius.circular(radius),
      ),
    );

    // Add tail
    final tailPath = Path();
    switch (tailPosition) {
      case BubbleTailPosition.bottomLeft:
        tailPath.moveTo(radius + 10, bubbleHeight);
        tailPath.lineTo(radius + 10 + tailWidth / 2, size.height);
        tailPath.lineTo(radius + 10 + tailWidth, bubbleHeight);
        break;
      case BubbleTailPosition.bottomRight:
        tailPath.moveTo(size.width - radius - 10 - tailWidth, bubbleHeight);
        tailPath.lineTo(size.width - radius - 10 - tailWidth / 2, size.height);
        tailPath.lineTo(size.width - radius - 10, bubbleHeight);
        break;
      case BubbleTailPosition.bottomCenter:
        tailPath.moveTo(size.width / 2 - tailWidth / 2, bubbleHeight);
        tailPath.lineTo(size.width / 2, size.height);
        tailPath.lineTo(size.width / 2 + tailWidth / 2, bubbleHeight);
        break;
    }

    path.addPath(tailPath, Offset.zero);
    return path;
  }

  @override
  bool shouldReclip(BubbleClipper oldClipper) {
    return radius != oldClipper.radius ||
        tailWidth != oldClipper.tailWidth ||
        tailHeight != oldClipper.tailHeight ||
        tailPosition != oldClipper.tailPosition;
  }
}

enum BubbleTailPosition { bottomLeft, bottomCenter, bottomRight }

// ═══════════════════════════════════════════════════════════════════════════
// 🎯 Clipped Container Widget (مع دعم Dark Mode)
// ═══════════════════════════════════════════════════════════════════════════
class ClippedContainer extends StatelessWidget {
  final Widget child;
  final CustomClipper<Path> clipper;
  final Gradient? gradient;
  final Color? color;
  final List<BoxShadow>? shadows;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ClippedContainer({
    super.key,
    required this.child,
    required this.clipper,
    this.gradient,
    this.color,
    this.shadows,
    this.width,
    this.height,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        boxShadow: shadows ??
            [
              BoxShadow(
                color: (isDark ? Colors.black : AppBrandColors.dark)
                    .withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipPath(
        clipper: clipper,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: color ?? (isDark ? AppBrandColors.cardDark : AppBrandColors.white),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 📱 Preview / Demo Screen
// ═══════════════════════════════════════════════════════════════════════════
class ClipperDemoScreen extends StatelessWidget {
  const ClipperDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppBrandColors.background : AppBrandColors.lightGray,
      appBar: AppBar(
        title: Text(
          'Custom Clippers Demo',
          style: TextStyle(
            color: isDark ? AppBrandColors.white : AppBrandColors.dark,
          ),
        ),
        backgroundColor: isDark ? AppBrandColors.cardDark : AppBrandColors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wave Clipper Demo
            _buildDemoCard(
              context: context,
              title: 'Wave Clipper',
              clipper: WaveClipper(waveHeight: 25, waveCount: 3),
              gradient: AppBrandColors.primaryGradient,
            ),

            const SizedBox(height: 16),

            // Curved Clipper Demo
            _buildDemoCard(
              context: context,
              title: 'Curved Clipper',
              clipper: CurvedClipper(curveHeight: 40),
              gradient: AppBrandColors.accentGradient,
            ),

            const SizedBox(height: 16),

            // Diagonal Clipper Demo
            _buildDemoCard(
              context: context,
              title: 'Diagonal Clipper',
              clipper: DiagonalClipper(diagonalHeight: 50),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
              ),
            ),

            const SizedBox(height: 16),

            // Notched Clipper Demo
            _buildDemoCard(
              context: context,
              title: 'Notched Clipper',
              clipper: NotchedClipper(radius: 20),
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF556270)],
              ),
            ),

            const SizedBox(height: 16),

            // Ticket Clipper Demo
            _buildDemoCard(
              context: context,
              title: 'Ticket Clipper',
              clipper: TicketClipper(notchRadius: 15, notchPosition: 0.35),
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
              ),
            ),

            const SizedBox(height: 16),

            // Arrow Clipper Demo
            _buildDemoCard(
              context: context,
              title: 'Arrow Clipper',
              clipper: ArrowClipper(direction: ArrowDirection.right, arrowSize: 25),
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
              ),
            ),

            const SizedBox(height: 16),

            // Bubble Clipper Demo
            _buildDemoCard(
              context: context,
              title: 'Bubble Clipper',
              clipper: BubbleClipper(tailHeight: 12, tailWidth: 20),
              gradient: const LinearGradient(
                colors: [Color(0xFF8E24AA), Color(0xFFE040FB)],
              ),
            ),

            const SizedBox(height: 16),

            // Hexagon & Star Demo Row
            Row(
              children: [
                Expanded(
                  child: ClippedContainer(
                    height: 100,
                    clipper: HexagonClipper(),
                    gradient: AppBrandColors.primaryGradient,
                    child: const Center(
                      child: Icon(Icons.hexagon_outlined, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ClippedContainer(
                    height: 100,
                    clipper: StarClipper(points: 5),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    child: const Center(
                      child: Icon(Icons.star, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required BuildContext context,
    required String title,
    required CustomClipper<Path> clipper,
    required Gradient gradient,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppBrandColors.darkGray : AppBrandColors.dark,
            ),
          ),
        ),
        ClippedContainer(
          height: 120,
          clipper: clipper,
          gradient: gradient,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}