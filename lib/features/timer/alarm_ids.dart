/// Stabilne ID powiadomienia FLN dla drzemki w Nap Stack.
///
/// Musi być spójne z planowaniem w [AlarmService.scheduleWakeUp] (ten sam [alarmId]).
int alarmIdForStackScheduledTime(DateTime scheduledAt) {
  return scheduledAt.millisecondsSinceEpoch.hashCode & 0x7FFFFFFF;
}
