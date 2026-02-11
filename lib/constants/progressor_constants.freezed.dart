// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progressor_constants.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProgressorConstants {
  String get serviceUuid;
  String get notifyCharUuid;
  String get writeCharUuid;
  int get commandResponse;
  int get weightMeasure;
  int get peakRfdMeas;
  int get peakRfdMeasSeries;
  int get lowBatteryWarning;

  /// Create a copy of ProgressorConstants
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProgressorConstantsCopyWith<ProgressorConstants> get copyWith =>
      _$ProgressorConstantsCopyWithImpl<ProgressorConstants>(
          this as ProgressorConstants, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProgressorConstants &&
            (identical(other.serviceUuid, serviceUuid) ||
                other.serviceUuid == serviceUuid) &&
            (identical(other.notifyCharUuid, notifyCharUuid) ||
                other.notifyCharUuid == notifyCharUuid) &&
            (identical(other.writeCharUuid, writeCharUuid) ||
                other.writeCharUuid == writeCharUuid) &&
            (identical(other.commandResponse, commandResponse) ||
                other.commandResponse == commandResponse) &&
            (identical(other.weightMeasure, weightMeasure) ||
                other.weightMeasure == weightMeasure) &&
            (identical(other.peakRfdMeas, peakRfdMeas) ||
                other.peakRfdMeas == peakRfdMeas) &&
            (identical(other.peakRfdMeasSeries, peakRfdMeasSeries) ||
                other.peakRfdMeasSeries == peakRfdMeasSeries) &&
            (identical(other.lowBatteryWarning, lowBatteryWarning) ||
                other.lowBatteryWarning == lowBatteryWarning));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      serviceUuid,
      notifyCharUuid,
      writeCharUuid,
      commandResponse,
      weightMeasure,
      peakRfdMeas,
      peakRfdMeasSeries,
      lowBatteryWarning);

  @override
  String toString() {
    return 'ProgressorConstants(serviceUuid: $serviceUuid, notifyCharUuid: $notifyCharUuid, writeCharUuid: $writeCharUuid, commandResponse: $commandResponse, weightMeasure: $weightMeasure, peakRfdMeas: $peakRfdMeas, peakRfdMeasSeries: $peakRfdMeasSeries, lowBatteryWarning: $lowBatteryWarning)';
  }
}

/// @nodoc
abstract mixin class $ProgressorConstantsCopyWith<$Res> {
  factory $ProgressorConstantsCopyWith(
          ProgressorConstants value, $Res Function(ProgressorConstants) _then) =
      _$ProgressorConstantsCopyWithImpl;
  @useResult
  $Res call(
      {String serviceUuid,
      String notifyCharUuid,
      String writeCharUuid,
      int commandResponse,
      int weightMeasure,
      int peakRfdMeas,
      int peakRfdMeasSeries,
      int lowBatteryWarning});
}

/// @nodoc
class _$ProgressorConstantsCopyWithImpl<$Res>
    implements $ProgressorConstantsCopyWith<$Res> {
  _$ProgressorConstantsCopyWithImpl(this._self, this._then);

  final ProgressorConstants _self;
  final $Res Function(ProgressorConstants) _then;

  /// Create a copy of ProgressorConstants
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceUuid = null,
    Object? notifyCharUuid = null,
    Object? writeCharUuid = null,
    Object? commandResponse = null,
    Object? weightMeasure = null,
    Object? peakRfdMeas = null,
    Object? peakRfdMeasSeries = null,
    Object? lowBatteryWarning = null,
  }) {
    return _then(_self.copyWith(
      serviceUuid: null == serviceUuid
          ? _self.serviceUuid
          : serviceUuid // ignore: cast_nullable_to_non_nullable
              as String,
      notifyCharUuid: null == notifyCharUuid
          ? _self.notifyCharUuid
          : notifyCharUuid // ignore: cast_nullable_to_non_nullable
              as String,
      writeCharUuid: null == writeCharUuid
          ? _self.writeCharUuid
          : writeCharUuid // ignore: cast_nullable_to_non_nullable
              as String,
      commandResponse: null == commandResponse
          ? _self.commandResponse
          : commandResponse // ignore: cast_nullable_to_non_nullable
              as int,
      weightMeasure: null == weightMeasure
          ? _self.weightMeasure
          : weightMeasure // ignore: cast_nullable_to_non_nullable
              as int,
      peakRfdMeas: null == peakRfdMeas
          ? _self.peakRfdMeas
          : peakRfdMeas // ignore: cast_nullable_to_non_nullable
              as int,
      peakRfdMeasSeries: null == peakRfdMeasSeries
          ? _self.peakRfdMeasSeries
          : peakRfdMeasSeries // ignore: cast_nullable_to_non_nullable
              as int,
      lowBatteryWarning: null == lowBatteryWarning
          ? _self.lowBatteryWarning
          : lowBatteryWarning // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProgressorConstants].
extension ProgressorConstantsPatterns on ProgressorConstants {
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
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgressorConstants value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProgressorConstants() when $default != null:
        return $default(_that);
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
  TResult map<TResult extends Object?>(
    TResult Function(_ProgressorConstants value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressorConstants():
        return $default(_that);
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
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgressorConstants value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressorConstants() when $default != null:
        return $default(_that);
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
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String serviceUuid,
            String notifyCharUuid,
            String writeCharUuid,
            int commandResponse,
            int weightMeasure,
            int peakRfdMeas,
            int peakRfdMeasSeries,
            int lowBatteryWarning)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProgressorConstants() when $default != null:
        return $default(
            _that.serviceUuid,
            _that.notifyCharUuid,
            _that.writeCharUuid,
            _that.commandResponse,
            _that.weightMeasure,
            _that.peakRfdMeas,
            _that.peakRfdMeasSeries,
            _that.lowBatteryWarning);
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
  TResult when<TResult extends Object?>(
    TResult Function(
            String serviceUuid,
            String notifyCharUuid,
            String writeCharUuid,
            int commandResponse,
            int weightMeasure,
            int peakRfdMeas,
            int peakRfdMeasSeries,
            int lowBatteryWarning)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressorConstants():
        return $default(
            _that.serviceUuid,
            _that.notifyCharUuid,
            _that.writeCharUuid,
            _that.commandResponse,
            _that.weightMeasure,
            _that.peakRfdMeas,
            _that.peakRfdMeasSeries,
            _that.lowBatteryWarning);
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
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String serviceUuid,
            String notifyCharUuid,
            String writeCharUuid,
            int commandResponse,
            int weightMeasure,
            int peakRfdMeas,
            int peakRfdMeasSeries,
            int lowBatteryWarning)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressorConstants() when $default != null:
        return $default(
            _that.serviceUuid,
            _that.notifyCharUuid,
            _that.writeCharUuid,
            _that.commandResponse,
            _that.weightMeasure,
            _that.peakRfdMeas,
            _that.peakRfdMeasSeries,
            _that.lowBatteryWarning);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProgressorConstants implements ProgressorConstants {
  const _ProgressorConstants(
      {required this.serviceUuid,
      required this.notifyCharUuid,
      required this.writeCharUuid,
      required this.commandResponse,
      required this.weightMeasure,
      required this.peakRfdMeas,
      required this.peakRfdMeasSeries,
      required this.lowBatteryWarning});

  @override
  final String serviceUuid;
  @override
  final String notifyCharUuid;
  @override
  final String writeCharUuid;
  @override
  final int commandResponse;
  @override
  final int weightMeasure;
  @override
  final int peakRfdMeas;
  @override
  final int peakRfdMeasSeries;
  @override
  final int lowBatteryWarning;

  /// Create a copy of ProgressorConstants
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProgressorConstantsCopyWith<_ProgressorConstants> get copyWith =>
      __$ProgressorConstantsCopyWithImpl<_ProgressorConstants>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProgressorConstants &&
            (identical(other.serviceUuid, serviceUuid) ||
                other.serviceUuid == serviceUuid) &&
            (identical(other.notifyCharUuid, notifyCharUuid) ||
                other.notifyCharUuid == notifyCharUuid) &&
            (identical(other.writeCharUuid, writeCharUuid) ||
                other.writeCharUuid == writeCharUuid) &&
            (identical(other.commandResponse, commandResponse) ||
                other.commandResponse == commandResponse) &&
            (identical(other.weightMeasure, weightMeasure) ||
                other.weightMeasure == weightMeasure) &&
            (identical(other.peakRfdMeas, peakRfdMeas) ||
                other.peakRfdMeas == peakRfdMeas) &&
            (identical(other.peakRfdMeasSeries, peakRfdMeasSeries) ||
                other.peakRfdMeasSeries == peakRfdMeasSeries) &&
            (identical(other.lowBatteryWarning, lowBatteryWarning) ||
                other.lowBatteryWarning == lowBatteryWarning));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      serviceUuid,
      notifyCharUuid,
      writeCharUuid,
      commandResponse,
      weightMeasure,
      peakRfdMeas,
      peakRfdMeasSeries,
      lowBatteryWarning);

  @override
  String toString() {
    return 'ProgressorConstants(serviceUuid: $serviceUuid, notifyCharUuid: $notifyCharUuid, writeCharUuid: $writeCharUuid, commandResponse: $commandResponse, weightMeasure: $weightMeasure, peakRfdMeas: $peakRfdMeas, peakRfdMeasSeries: $peakRfdMeasSeries, lowBatteryWarning: $lowBatteryWarning)';
  }
}

/// @nodoc
abstract mixin class _$ProgressorConstantsCopyWith<$Res>
    implements $ProgressorConstantsCopyWith<$Res> {
  factory _$ProgressorConstantsCopyWith(_ProgressorConstants value,
          $Res Function(_ProgressorConstants) _then) =
      __$ProgressorConstantsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String serviceUuid,
      String notifyCharUuid,
      String writeCharUuid,
      int commandResponse,
      int weightMeasure,
      int peakRfdMeas,
      int peakRfdMeasSeries,
      int lowBatteryWarning});
}

/// @nodoc
class __$ProgressorConstantsCopyWithImpl<$Res>
    implements _$ProgressorConstantsCopyWith<$Res> {
  __$ProgressorConstantsCopyWithImpl(this._self, this._then);

  final _ProgressorConstants _self;
  final $Res Function(_ProgressorConstants) _then;

  /// Create a copy of ProgressorConstants
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? serviceUuid = null,
    Object? notifyCharUuid = null,
    Object? writeCharUuid = null,
    Object? commandResponse = null,
    Object? weightMeasure = null,
    Object? peakRfdMeas = null,
    Object? peakRfdMeasSeries = null,
    Object? lowBatteryWarning = null,
  }) {
    return _then(_ProgressorConstants(
      serviceUuid: null == serviceUuid
          ? _self.serviceUuid
          : serviceUuid // ignore: cast_nullable_to_non_nullable
              as String,
      notifyCharUuid: null == notifyCharUuid
          ? _self.notifyCharUuid
          : notifyCharUuid // ignore: cast_nullable_to_non_nullable
              as String,
      writeCharUuid: null == writeCharUuid
          ? _self.writeCharUuid
          : writeCharUuid // ignore: cast_nullable_to_non_nullable
              as String,
      commandResponse: null == commandResponse
          ? _self.commandResponse
          : commandResponse // ignore: cast_nullable_to_non_nullable
              as int,
      weightMeasure: null == weightMeasure
          ? _self.weightMeasure
          : weightMeasure // ignore: cast_nullable_to_non_nullable
              as int,
      peakRfdMeas: null == peakRfdMeas
          ? _self.peakRfdMeas
          : peakRfdMeas // ignore: cast_nullable_to_non_nullable
              as int,
      peakRfdMeasSeries: null == peakRfdMeasSeries
          ? _self.peakRfdMeasSeries
          : peakRfdMeasSeries // ignore: cast_nullable_to_non_nullable
              as int,
      lowBatteryWarning: null == lowBatteryWarning
          ? _self.lowBatteryWarning
          : lowBatteryWarning // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
