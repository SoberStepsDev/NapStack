import 'package:flutter_test/flutter_test.dart';

import 'package:napstack/features/timer/nap_preset.dart';

void main() {
  group('NapTypeName', () {
    test('tryFromName — znane nazwy', () {
      expect(NapTypeName.tryFromName('powerNap'), NapType.powerNap);
      expect(NapTypeName.tryFromName('coffeeNap'), NapType.coffeeNap);
      expect(NapTypeName.tryFromName('fullCycle'), NapType.fullCycle);
    });

    test('tryFromName — nieznana → null', () {
      expect(NapTypeName.tryFromName('unknown'), isNull);
      expect(NapTypeName.tryFromName(''), isNull);
    });

    test('fromName — nieznana → ArgumentError', () {
      expect(() => NapTypeName.fromName('bad'), throwsArgumentError);
    });

    test('name — round-trip', () {
      for (final t in NapType.values) {
        expect(NapTypeName.tryFromName(t.name), t);
      }
    });
  });

  group('presetByType', () {
    test('zwraca preset dla każdego typu', () {
      for (final t in NapType.values) {
        final p = presetByType(t);
        expect(p.type, t);
        expect(p.totalSeconds, p.durationSeconds + p.fallAsleepSeconds);
        expect(p.plannedMinutes, p.durationSeconds ~/ 60);
      }
    });
  });

  group('RingtoneType', () {
    test('fromResourceId — fallback dla nieznanego id', () {
      expect(
        RingtoneType.fromResourceId('__no_such__'),
        RingtoneType.defaultRingtone,
      );
    });

    test('fromResourceId — znany resource', () {
      expect(
        RingtoneType.fromResourceId('napstack_minimal_ping'),
        RingtoneType.minimalPing,
      );
    });
  });
}
