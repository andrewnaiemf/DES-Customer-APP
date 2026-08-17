import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class RegisterSignaturePad extends StatefulWidget {
  const RegisterSignaturePad({
    super.key,
    required this.isDark,
    required this.onChanged,
  });

  final bool isDark;
  final VoidCallback onChanged;

  @override
  State<RegisterSignaturePad> createState() => RegisterSignaturePadState();
}

class RegisterSignaturePadState extends State<RegisterSignaturePad> {
  final List<Offset?> _points = [];

  bool get hasStroke => _points.whereType<Offset>().length > 8;

  void clear() {
    setState(_points.clear);
    widget.onChanged();
  }

  Future<List<int>?> exportPng() async {
    if (!hasStroke) return null;
    final box = context.findRenderObject() as RenderBox?;
    final size = box?.size ?? const Size(420, 180);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    Offset? last;
    for (final point in _points) {
      if (point == null) {
        last = null;
        continue;
      }
      if (last == null) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      last = point;
    }
    canvas.drawPath(path, paint);
    final image = await recorder.endRecording().toImage(
          size.width.toInt(),
          size.height.toInt(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return bytes?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E2139) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? Colors.white12 : const Color(0xFFE8EAF0),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onPanStart: (d) {
            setState(() => _points.add(d.localPosition));
            widget.onChanged();
          },
          onPanUpdate: (d) {
            setState(() => _points.add(d.localPosition));
          },
          onPanEnd: (_) => setState(() => _points.add(null)),
          child: CustomPaint(
            painter: _SignaturePainter(
              points: _points,
              color: widget.isDark ? Colors.white : Colors.black87,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({required this.points, required this.color});

  final List<Offset?> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    Offset? last;
    for (final point in points) {
      if (point == null) {
        last = null;
        continue;
      }
      if (last == null) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
      last = point;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
