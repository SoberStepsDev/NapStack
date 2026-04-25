import 'package:flutter/material.dart';

/// Typy drzemek dostępne w NapStack.
enum NapType { powerNap, coffeeNap, fullCycle }

extension NapTypeName on NapType {
  String get name => switch (this) {
        NapType.powerNap => 'powerNap',
        NapType.coffeeNap => 'coffeeNap',
        NapType.fullCycle => 'fullCycle',
      };

  static NapType? tryFromName(String name) => switch (name) {
        'powerNap' => NapType.powerNap,
        'coffeeNap' => NapType.coffeeNap,
        'fullCycle' => NapType.fullCycle,
        _ => null,
      };

  static NapType fromName(String name) {
    final t = tryFromName(name);
    if (t == null) {
      throw ArgumentError('Unknown NapType: $name');
    }
    return t;
  }
}

/// Definicja presetu drzemki.
///
/// [fallAsleepSeconds] — czas fazy zasypiania (nie wlicza się do planowanego snu).
/// [durationSeconds]   — właściwy czas drzemki (wyświetlany w UI, zapisywany w sesji).
/// [totalSeconds]      — suma obu faz → opóźnienie alarmu od momentu startu.
/// [isPro]             — czy preset wymaga wersji Pro.
@immutable
class NapPreset {
  const NapPreset({
    required this.type,
    required this.label,
    required this.description,
    required this.durationSeconds,
    required this.fallAsleepSeconds,
    this.isPro = false,
  });

  final NapType type;
  final String label;
  final String description;
  final int durationSeconds;
  final int fallAsleepSeconds;
  final bool isPro;

  int get totalSeconds => durationSeconds + fallAsleepSeconds;
  int get plannedMinutes => durationSeconds ~/ 60;
}

/// Wszystkie dostępne presety — źródło prawdy dla całej apki.
const kPresets = [
  NapPreset(
    type: NapType.powerNap,
    label: 'Power Nap',
    description: 'Szybkie doładowanie bez inercji sennej',
    durationSeconds: 20 * 60, // 20 min
    fallAsleepSeconds: 7 * 60, // 7 min zasypiania
  ),
  NapPreset(
    type: NapType.coffeeNap,
    label: 'Coffee Nap',
    description: 'Kofeina + drzemka — potęgowany efekt',
    durationSeconds: 15 * 60, // 15 min
    fallAsleepSeconds: 5 * 60,
  ),
  NapPreset(
    type: NapType.fullCycle,
    label: 'Full Cycle',
    description: 'Pełny cykl REM — głęboka regeneracja',
    durationSeconds: 90 * 60, // 90 min
    fallAsleepSeconds: 10 * 60,
    isPro: true,
  ),
];

NapPreset presetByType(NapType type) =>
    kPresets.firstWhere((p) => p.type == type);

/// Dostępne dzwonki alarmowe.
enum RingtoneType {
  minimalPing,
  morningBirds,
  peacefulChime;

  static RingtoneType get defaultRingtone => RingtoneType.minimalPing;

  String get resourceId => switch (this) {
        RingtoneType.minimalPing => 'napstack_minimal_ping',
        RingtoneType.morningBirds => 'napstack_morning_birds',
        RingtoneType.peacefulChime => 'napstack_peaceful_chime',
      };

  String get label => switch (this) {
        RingtoneType.minimalPing => 'Minimal Ping',
        RingtoneType.morningBirds => 'Morning Birds',
        RingtoneType.peacefulChime => 'Peaceful Chime',
      };

  String get description => switch (this) {
        RingtoneType.minimalPing => 'Delikatny, minimalistyczny dźwięk',
        RingtoneType.morningBirds => 'Ptaki o poranku — spokojne przebudzenie',
        RingtoneType.peacefulChime => 'Spokojny dzwonek — łagodne wyjście ze snu',
      };

  static RingtoneType fromResourceId(String id) =>
      RingtoneType.values.firstWhere(
        (r) => r.resourceId == id,
        orElse: () => defaultRingtone,
      );
}
