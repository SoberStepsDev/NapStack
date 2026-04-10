import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// Karta statystyki — wartość + etykieta + ikona.
/// Używana w siatce 2×2 na StatsScreen.
class StatCard extends StatelessWidget {
  const StatCard({
    required this.value,
    required this.label,
    required this.icon,
    this.accent = AppColors.kAccent,
    this.isWide = false,
    super.key,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accent;

  /// Jeśli true — karta rozciąga się na całą szerokość (np. streak).
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.kBorder, width: 1),
        gradient: AppColors.cardGradient(accent),
      ),
      child: isWide ? _WideLayout(this) : _CompactLayout(this),
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout(this.card);
  final StatCard card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(card.icon, color: card.accent, size: 22),
        const Spacer(),
        Text(
          card.value,
          style: GoogleFonts.syne(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.kTextPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          card.label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.kTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout(this.card);
  final StatCard card;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: card.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(card.icon, color: card.accent, size: 26),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.kTextSecondary,
              ),
            ),
            Text(
              card.value,
              style: GoogleFonts.syne(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.kTextPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
