import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// 2D FOC balance diagram with a light 3D-style shaft shading.
class FocVisual extends StatelessWidget {
  const FocVisual({
    super.key,
    required this.lengthInches,
    required this.balanceInches,
    required this.focPercent,
  });

  final double lengthInches;
  final double balanceInches;
  final double focPercent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balance diagram',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          width: double.infinity,
          child: CustomPaint(
            painter: _FocPainter(
              lengthInches: lengthInches,
              balanceInches: balanceInches,
              color: Theme.of(context).colorScheme.primary,
              accent: Theme.of(context).colorScheme.tertiary,
              labelColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'FOC ${focPercent.toStringAsFixed(2)}% · midshaft at ${(lengthInches / 2).toStringAsFixed(2)} in · balance at ${balanceInches.toStringAsFixed(2)} in',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _FocPainter extends CustomPainter {
  _FocPainter({
    required this.lengthInches,
    required this.balanceInches,
    required this.color,
    required this.accent,
    required this.labelColor,
  });

  final double lengthInches;
  final double balanceInches;
  final Color color;
  final Color accent;
  final Color labelColor;

  @override
  void paint(Canvas canvas, Size size) {
    final pad = 24.0;
    final y = size.height * 0.45;
    final shaftW = size.width - pad * 2;
    final midX = pad + shaftW / 2;
    final balX = pad + (balanceInches / math.max(lengthInches, 0.01)) * shaftW;

    // Soft ground shadow for depth.
    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(midX, y + 10), width: shaftW, height: 10),
        const Radius.circular(5),
      ),
      shadow,
    );

    // Shaft body with vertical gradient for a cylindrical look.
    final shaftRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, y - 7, shaftW, 14),
      const Radius.circular(7),
    );
    final shaftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.35),
          color,
          color.withValues(alpha: 0.55),
        ],
      ).createShader(shaftRect.outerRect);
    canvas.drawRRect(shaftRect, shaftPaint);

    // Midpoint tick.
    final midPaint = Paint()
      ..color = labelColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(midX, y - 18), Offset(midX, y + 18), midPaint);

    // Balance fulcrum triangle.
    final path = Path()
      ..moveTo(balX, y + 8)
      ..lineTo(balX - 10, y + 28)
      ..lineTo(balX + 10, y + 28)
      ..close();
    canvas.drawPath(path, Paint()..color = accent);

    // Balance vertical.
    canvas.drawLine(
      Offset(balX, y - 22),
      Offset(balX, y + 8),
      Paint()
        ..color = accent
        ..strokeWidth = 2,
    );

    // Tip accent (front).
    canvas.drawCircle(Offset(pad + shaftW, y), 5, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _FocPainter oldDelegate) =>
      oldDelegate.lengthInches != lengthInches ||
      oldDelegate.balanceInches != balanceInches ||
      oldDelegate.color != color;
}
