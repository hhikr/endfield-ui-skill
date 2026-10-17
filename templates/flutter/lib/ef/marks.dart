// Shapes and drawn marks: cut corners, hatch, three-colour strip, contours.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// A cut corner means "you can press this". Flutter's BeveledRectangleBorder
/// cuts at 45° with the radius as the cut length.
ShapeBorder efCut({
  double tl = 0,
  double tr = 0,
  double br = 0,
  double bl = 0,
  BorderSide side = BorderSide.none,
}) =>
    BeveledRectangleBorder(
      side: side,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(tl),
        topRight: Radius.circular(tr),
        bottomRight: Radius.circular(br),
        bottomLeft: Radius.circular(bl),
      ),
    );

/// Magenta / yellow / mint, 3px. Only at the very top of a screen and under a
/// document title. Never as a divider elsewhere.
class EfTriStrip extends StatelessWidget {
  const EfTriStrip({super.key, this.height = Ef.strip});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Row(children: [
          const Expanded(child: ColoredBox(color: Ef.triA, child: SizedBox.expand())),
          Expanded(child: ColoredBox(color: EfColors.of(context).signal, child: const SizedBox.expand())),
          const Expanded(child: ColoredBox(color: Ef.triC, child: SizedBox.expand())),
        ]),
      );
}

/// 45° hatch lines. For empty states, title bands, disabled or "nothing here" areas.
class EfHatch extends StatelessWidget {
  const EfHatch({super.key, this.child, this.spacing = Ef.hatchStep});
  final Widget? child;
  final double spacing;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _HatchPainter(EfColors.of(context).ink.withValues(alpha: Ef.hatchAlpha), spacing),
        child: child,
      );
}

class _HatchPainter extends CustomPainter {
  _HatchPainter(this.color, this.spacing);
  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = Ef.hatchLine;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.color != color || old.spacing != spacing;
}

/// Faint open contour lines in two opposite corners of a screen background.
/// Open, flowing, never closed rings; 9% ink; behind everything.
class EfContours extends StatelessWidget {
  const EfContours({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _ContourPainter(EfColors.of(context).ink.withValues(alpha: Ef.contourAlpha)),
        child: child,
      );
}

class _ContourPainter extends CustomPainter {
  _ContourPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    // top-right corner
    _field(canvas, p, Offset(size.width, 0), size.width * 0.8, 1, 3.1);
    // bottom-left corner
    _field(canvas, p, Offset(0, size.height), size.width * 0.9, -1, 7.7);
  }

  void _field(Canvas canvas, Paint p, Offset origin, double reach, double dir, double seed) {
    for (var i = 0; i < 11; i++) {
      final r = reach * (0.18 + i * 0.075);
      final path = Path();
      for (var a = 0; a <= 60; a++) {
        final t = a / 60 * math.pi / 2;
        final wobble = 1 + 0.07 * math.sin(t * 5 + seed + i * 0.6) + 0.04 * math.sin(t * 11 + seed * 2);
        final x = origin.dx - dir * math.cos(t) * r * wobble;
        final y = origin.dy + dir * math.sin(t) * r * wobble * 0.85;
        a == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_ContourPainter old) => old.color != color;
}
