import '../timer/nap_preset.dart';

/// Model sesji drzemki — mapuje rekord z Appwrite na obiekt Dart.
///
/// Kolumny Appwrite (tabela: nap_sessions):
///   user_id        varchar(36)  — auth.uid() — do RLS
///   started_at     varchar(30)  — ISO 8601 UTC
///   ended_at       varchar(30)  — ISO 8601 UTC
///   nap_type       varchar(20)  — NapType.name
///   completed      bool
///   planned_min    int          — durationSeconds/60 (planowany sen, bez fazy zasypiania)
///   quality_rating int?         — null w v1; zarezerwowane na MirrorMind Q3-2026
class NapSession {
  const NapSession({
    required this.id,
    required this.userId,
    required this.startedAt,
    required this.endedAt,
    required this.napType,
    required this.completed,
    required this.plannedMinutes,
    this.qualityRating,
  });

  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime endedAt;
  final NapType napType;
  final bool completed;
  final int plannedMinutes;
  final int? qualityRating;

  Map<String, dynamic> toAppwrite() => {
        'user_id': userId,
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt.toUtc().toIso8601String(),
        'nap_type': napType.name,
        'completed': completed,
        'planned_min': plannedMinutes,
        if (qualityRating != null) 'quality_rating': qualityRating,
      };

  factory NapSession.fromAppwrite(Map<String, dynamic> data) => NapSession(
        id: data['\$id'] as String,
        userId: data['user_id'] as String,
        startedAt: DateTime.parse(data['started_at'] as String).toLocal(),
        endedAt: DateTime.parse(data['ended_at'] as String).toLocal(),
        napType: NapTypeName.fromName(data['nap_type'] as String),
        completed: data['completed'] as bool,
        plannedMinutes: data['planned_min'] as int,
        qualityRating: data['quality_rating'] as int?,
      );

  NapSession copyWith({int? qualityRating}) => NapSession(
        id: id,
        userId: userId,
        startedAt: startedAt,
        endedAt: endedAt,
        napType: napType,
        completed: completed,
        plannedMinutes: plannedMinutes,
        qualityRating: qualityRating ?? this.qualityRating,
      );
}
