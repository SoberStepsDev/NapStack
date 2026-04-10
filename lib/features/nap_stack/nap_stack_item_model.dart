import '../timer/nap_preset.dart';

/// Pojedynczy element Nap Stack — zaplanowana drzemka z określoną godziną.
///
/// Kolumny Appwrite (tabela: nap_stack):
///   user_id        varchar(36)  — auth.uid()
///   scheduled_iso  varchar(30)  — ISO 8601 UTC pełna data + czas alarmu
///   nap_type       varchar(20)  — NapType.name
///   done           bool         — czy alarm minął / zrealizowany
///
/// [id] to Appwrite $id rekordu — używany do stabilnego usuwania.
/// [scheduledAt] zastępuje v1-owe dwa pola (scheduledDate + scheduledTime)
/// jednym DateTime — obsługuje drzemki na różne dni bez dodatkowej logiki.
class NapStackItem {
  const NapStackItem({
    required this.id,
    required this.userId,
    required this.scheduledAt,
    required this.napType,
    this.done = false,
  });

  final String id;
  final String userId;
  final DateTime scheduledAt;
  final NapType napType;
  final bool done;

  /// ID alarmu FLN — unikalny per rekord, bez kolizji przy id: 0.
  int get alarmId => scheduledAt.millisecondsSinceEpoch.hashCode & 0x7FFFFFFF;

  Map<String, dynamic> toAppwrite() => {
        'user_id': userId,
        'scheduled_iso': scheduledAt.toUtc().toIso8601String(),
        'nap_type': napType.name,
        'done': done,
      };

  factory NapStackItem.fromAppwrite(Map<String, dynamic> data) => NapStackItem(
        id: data['\$id'] as String,
        userId: data['user_id'] as String,
        scheduledAt:
            DateTime.parse(data['scheduled_iso'] as String).toLocal(),
        napType: NapTypeName.fromName(data['nap_type'] as String),
        done: data['done'] as bool,
      );

  NapStackItem copyWith({bool? done}) => NapStackItem(
        id: id,
        userId: userId,
        scheduledAt: scheduledAt,
        napType: napType,
        done: done ?? this.done,
      );
}
