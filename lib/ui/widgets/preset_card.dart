import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../features/timer/nap_preset.dart';

/// Karta wyboru presetu drzemki.
/// Prezentuje: ikonę, nazwę, opis, czas trwania, badge Pro (jeśli dotyczy).
class PresetCard extends StatelessWidget {
  const PresetCard({
    required this.preset,
    required this.onTap,
    this.isLocked = false,
    super.key,
  });

  final NapPreset preset;
  final VoidCallback onTap;
  final bool isLocked;

  Color get _accentColor => switch (preset.type) {
    NapType.powerNap   => AppColors.kPowerNapColor,
    NapType.coffeeNap  => AppColors.kCoffeeNapColor,
    NapType.fullCycle  => AppColors.kFullCycleColor,
  };

  IconData get _icon => switch (preset.type) {
    NapType.powerNap   => Icons.bolt_rounded,
    NapType.coffeeNap  => Icons.coffee_rounded,
    NapType.fullCycle  => Icons.nightlight_round,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.kBgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.kBorder, width: 1),
          gradient: AppColors.cardGradient(_accentColor),
        ),
        child: Stack(
          children: [
            // Subtelne tło - glow w lewym górnym rogu
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accentColor.withValues(alpha: 0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Ikona presetu
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _accentColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(_icon, color: _accentColor, size: 24),
                  ),
                  const SizedBox(width: 16),

                  // Tekst
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              preset.label,
                              style: GoogleFonts.syne(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kTextPrimary,
                              ),
                            ),
                            if (preset.isPro) ...[
                              const SizedBox(width: 8),
                              _ProBadge(color: _accentColor),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.description,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.kTextSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Czas / Lock
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isLocked)
                        Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.kTextMuted,
                          size: 20,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${preset.plannedMinutes} min',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _accentColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.kTextMuted,
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        'PRO',
        style: GoogleFonts.syne(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
