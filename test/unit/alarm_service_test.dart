import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:napstack/features/timer/alarm_ids.dart';
import 'package:napstack/features/timer/alarm_service.dart';
import 'package:napstack/l10n/app_localizations.dart';

void main() {
  group('alarmIdForStackScheduledTime', () {
    test('31-bit dodatni (zgodny z FLN int id)', () {
      final t = DateTime.utc(2026, 4, 25, 12, 30);
      final id = alarmIdForStackScheduledTime(t);
      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThanOrEqualTo(0x7FFFFFFF));
    });

    test('ten sam czas → to samo id', () {
      final t = DateTime(2026, 5, 1, 8, 0);
      expect(
        alarmIdForStackScheduledTime(t),
        alarmIdForStackScheduledTime(t),
      );
    });
  });

  group('AlarmPermissionDeniedException', () {
    test('UserFacing — treść z l10n (PL)', () {
      final l10n = lookupAppLocalizations(const Locale('pl'));
      const e = AlarmPermissionDeniedException();
      expect(e.messageL10n(l10n), isNotEmpty);
    });

    test('UserFacing — treść z l10n (EN)', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      const e = AlarmPermissionDeniedException();
      expect(e.messageL10n(l10n), isNotEmpty);
    });
  });
}
