// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimerState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is TimerState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TimerState()';
  }
}

/// @nodoc
class $TimerStateCopyWith<$Res> {
  $TimerStateCopyWith(TimerState _, $Res Function(TimerState) __);
}

/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Running value)? running,
    TResult Function(_Done value)? done,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Idle() when idle != null:
        return idle(_that);
      case _Running() when running != null:
        return running(_that);
      case _Done() when done != null:
        return done(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Running value) running,
    required TResult Function(_Done value) done,
  }) {
    final _that = this;
    switch (_that) {
      case _Idle():
        return idle(_that);
      case _Running():
        return running(_that);
      case _Done():
        return done(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Running value)? running,
    TResult? Function(_Done value)? done,
  }) {
    final _that = this;
    switch (_that) {
      case _Idle() when idle != null:
        return idle(_that);
      case _Running() when running != null:
        return running(_that);
      case _Done() when done != null:
        return done(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(NapPreset preset, int remainingSeconds, DateTime startedAt,
            DateTime wakeTime)?
        running,
    TResult Function(NapPreset preset, DateTime startedAt, DateTime endedAt,
            bool completed)?
        done,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Idle() when idle != null:
        return idle();
      case _Running() when running != null:
        return running(_that.preset, _that.remainingSeconds, _that.startedAt,
            _that.wakeTime);
      case _Done() when done != null:
        return done(
            _that.preset, _that.startedAt, _that.endedAt, _that.completed);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(NapPreset preset, int remainingSeconds,
            DateTime startedAt, DateTime wakeTime)
        running,
    required TResult Function(NapPreset preset, DateTime startedAt,
            DateTime endedAt, bool completed)
        done,
  }) {
    final _that = this;
    switch (_that) {
      case _Idle():
        return idle();
      case _Running():
        return running(_that.preset, _that.remainingSeconds, _that.startedAt,
            _that.wakeTime);
      case _Done():
        return done(
            _that.preset, _that.startedAt, _that.endedAt, _that.completed);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(NapPreset preset, int remainingSeconds,
            DateTime startedAt, DateTime wakeTime)?
        running,
    TResult? Function(NapPreset preset, DateTime startedAt, DateTime endedAt,
            bool completed)?
        done,
  }) {
    final _that = this;
    switch (_that) {
      case _Idle() when idle != null:
        return idle();
      case _Running() when running != null:
        return running(_that.preset, _that.remainingSeconds, _that.startedAt,
            _that.wakeTime);
      case _Done() when done != null:
        return done(
            _that.preset, _that.startedAt, _that.endedAt, _that.completed);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Idle extends TimerState {
  const _Idle() : super._();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Idle);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'TimerState.idle()';
  }
}

/// @nodoc

class _Running extends TimerState {
  const _Running(
      {required this.preset,
      required this.remainingSeconds,
      required this.startedAt,
      required this.wakeTime})
      : super._();

  final NapPreset preset;
  final int remainingSeconds;
  final DateTime startedAt;
  final DateTime wakeTime;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RunningCopyWith<_Running> get copyWith =>
      __$RunningCopyWithImpl<_Running>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Running &&
            (identical(other.preset, preset) || other.preset == preset) &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.wakeTime, wakeTime) ||
                other.wakeTime == wakeTime));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, preset, remainingSeconds, startedAt, wakeTime);

  @override
  String toString() {
    return 'TimerState.running(preset: $preset, remainingSeconds: $remainingSeconds, startedAt: $startedAt, wakeTime: $wakeTime)';
  }
}

/// @nodoc
abstract mixin class _$RunningCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$RunningCopyWith(_Running value, $Res Function(_Running) _then) =
      __$RunningCopyWithImpl;
  @useResult
  $Res call(
      {NapPreset preset,
      int remainingSeconds,
      DateTime startedAt,
      DateTime wakeTime});
}

/// @nodoc
class __$RunningCopyWithImpl<$Res> implements _$RunningCopyWith<$Res> {
  __$RunningCopyWithImpl(this._self, this._then);

  final _Running _self;
  final $Res Function(_Running) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? preset = null,
    Object? remainingSeconds = null,
    Object? startedAt = null,
    Object? wakeTime = null,
  }) {
    return _then(_Running(
      preset: null == preset
          ? _self.preset
          : preset // ignore: cast_nullable_to_non_nullable
              as NapPreset,
      remainingSeconds: null == remainingSeconds
          ? _self.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      startedAt: null == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      wakeTime: null == wakeTime
          ? _self.wakeTime
          : wakeTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _Done extends TimerState {
  const _Done(
      {required this.preset,
      required this.startedAt,
      required this.endedAt,
      required this.completed})
      : super._();

  final NapPreset preset;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool completed;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DoneCopyWith<_Done> get copyWith =>
      __$DoneCopyWithImpl<_Done>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Done &&
            (identical(other.preset, preset) || other.preset == preset) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, preset, startedAt, endedAt, completed);

  @override
  String toString() {
    return 'TimerState.done(preset: $preset, startedAt: $startedAt, endedAt: $endedAt, completed: $completed)';
  }
}

/// @nodoc
abstract mixin class _$DoneCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory _$DoneCopyWith(_Done value, $Res Function(_Done) _then) =
      __$DoneCopyWithImpl;
  @useResult
  $Res call(
      {NapPreset preset, DateTime startedAt, DateTime endedAt, bool completed});
}

/// @nodoc
class __$DoneCopyWithImpl<$Res> implements _$DoneCopyWith<$Res> {
  __$DoneCopyWithImpl(this._self, this._then);

  final _Done _self;
  final $Res Function(_Done) _then;

  /// Create a copy of TimerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? preset = null,
    Object? startedAt = null,
    Object? endedAt = null,
    Object? completed = null,
  }) {
    return _then(_Done(
      preset: null == preset
          ? _self.preset
          : preset // ignore: cast_nullable_to_non_nullable
              as NapPreset,
      startedAt: null == startedAt
          ? _self.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endedAt: null == endedAt
          ? _self.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completed: null == completed
          ? _self.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
