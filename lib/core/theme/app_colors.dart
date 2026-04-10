import 'package:flutter/material.dart';

/// Paleta NapStack — estetyka "nocnej ciszy".
/// Głęboka granat-czerń + lodowy błękit + subtelne akcenty.
abstract final class AppColors {
  // ── Tła ────────────────────────────────────────────────────────────────────
  static const kBgDeep     = Color(0xFF070B16); // najciemniejsze tło
  static const kBgBase     = Color(0xFF0D1120); // główne tło ekranów
  static const kBgCard     = Color(0xFF111827); // karty / komponenty
  static const kBgElevated = Color(0xFF1A2744); // podwyższone elementy

  // ── Akcenty ────────────────────────────────────────────────────────────────
  /// Lodowy błękit — faza właściwej drzemki, CTA, podkreślenia.
  static const kAccent      = Color(0xFF60C5FF);
  static const kAccentLight = Color(0xFF89D8FF);
  static const kAccentDark  = Color(0xFF3A9ED4);

  /// Przygaszony błękit — faza zasypiania (ring, etykieta).
  static const kAccentDim   = Color(0xFF2A5080);
  static const kAccentGlow  = Color(0x3360C5FF); // overlay / cień

  // ── Preset colors ──────────────────────────────────────────────────────────
  static const kPowerNapColor  = Color(0xFF34D399); // mint — szybka energia
  static const kCoffeeNapColor = Color(0xFFA78BFA); // soft purple — marzenie
  static const kFullCycleColor = Color(0xFF60C5FF); // ice blue — głęboki sen

  // ── Tekst ──────────────────────────────────────────────────────────────────
  static const kTextPrimary   = Color(0xFFFFFFFF);
  static const kTextSecondary = Color(0xFF8899BB);
  static const kTextMuted     = Color(0xFF445570);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const kSuccess = Color(0xFF4ADE80);
  static const kWarning = Color(0xFFFBBF24);
  static const kError   = Color(0xFFF87171);

  // ── Obramowania ────────────────────────────────────────────────────────────
  static const kBorder      = Color(0xFF1E2F47);
  static const kBorderLight = Color(0xFF2A3F5F);

  // ── Gradienty ──────────────────────────────────────────────────────────────
  static const kBgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [kBgDeep, kBgBase],
    stops: [0.0, 1.0],
  );

  static const kAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kAccentLight, kAccent, kAccentDark],
  );

  static LinearGradient cardGradient(Color accentColor) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      accentColor.withValues(alpha: 0.08),
      accentColor.withValues(alpha: 0.02),
    ],
  );
}
