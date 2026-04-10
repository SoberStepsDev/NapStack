import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/timer/timer_state.dart';

/// CustomPainter łuku timera.
///
/// Renderuje:
/// 1. Track — pełny okrąg (tło łuku), kolor kBgElevated
/// 2. Glow pass — rozmyty łuk dla efektu neonowego blasku
/// 3. Crisp pass — ostry łuk na wierzchu, właściwy kolor zależny od fazy
/// 4. Endpoint dot — mały kółko na końcu łuku
///
/// [shouldRepaint] sprawdza TYLKO progress i phase — nie odmalowuje przy
/// innych zmianach widgetu, co eliminuje zbędne rysowania co sekundę.
class RingTimerPainter extends CustomPainter {
  const RingTimerPainter({
    required this.progress,
    required this.phase,
  });

  final double progress; // 0.0 → 1.0
  final TimerPhase phase;

  static const _trackWidth    = 10.0;
  static const _progressWidth = 14.0;
  static const _dotRadius     = 5.0;
  static const _startAngle    = -math.pi / 2; // od góry (12 o'clock)

  Color get _progressColor => switch (phase) {
    TimerPhase.fallingAsleep => AppColors.kAccentDim,
    TimerPhase.napping       => AppColors.kAccent,
    _                        => AppColors.kAccentDim,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - _progressWidth;
    final rect   = Rect.fromCircle(center: center, radius: radius);
    final sweep  = 2 * math.pi * progress.clamp(0.0, 1.0);

    // 1 ── Track ────────────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.kBgElevated
        ..style = PaintingStyle.stroke
        ..strokeWidth = _trackWidth,
    );

    if (progress <= 0.001) return;

    // 2 ── Glow pass ────────────────────────────────────────────────────────
    canvas.drawArc(
      rect,
      _startAngle,
      sweep,
      false,
      Paint()
        ..color = _progressColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _progressWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // 3 ── Crisp arc ────────────────────────────────────────────────────────
    canvas.drawArc(
      rect,
      _startAngle,
      sweep,
      false,
      Paint()
        ..color = _progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _progressWidth
        ..strokeCap = StrokeCap.round,
    );

    // 4 ── Endpoint dot ─────────────────────────────────────────────────────
    final endAngle = _startAngle + sweep;
    final dotCenter = Offset(
      center.dx + radius * math.cos(endAngle),
      center.dy + radius * math.sin(endAngle),
    );

    // Outer glow dot
    canvas.drawCircle(
      dotCenter,
      _dotRadius + 4,
      Paint()
        ..color = _progressColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Core dot
    canvas.drawCircle(
      dotCenter,
      _dotRadius,
      Paint()..color = AppColors.kTextPrimary,
    );
  }

  @override
  bool shouldRepaint(RingTimerPainter old) =>
      old.progress != progress || old.phase != phase;
}
