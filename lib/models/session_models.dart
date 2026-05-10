import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_models.freezed.dart';
part 'session_models.g.dart';

enum ProtocolType { maxHang, repeater, freeform }

enum HandMode { both, alternatePerSet, alternatePerRep, left, right }

enum SessionPhase {
  idle,
  countdown,
  hanging,
  resting,
  restBetweenSets,
  complete,
}

@freezed
sealed class SetConfig with _$SetConfig {
  const factory SetConfig({
    @Default(7) int hangDurationSec,
    @Default(3) int restDurationSec,
    @Default(1) int repsPerSet,
  }) = _SetConfig;

  factory SetConfig.fromJson(Map<String, dynamic> json) =>
      _$SetConfigFromJson(json);
}

@freezed
sealed class ProtocolConfig with _$ProtocolConfig {
  const ProtocolConfig._();

  const factory ProtocolConfig({
    required ProtocolType type,
    @Default(7) int hangDurationSec,
    @Default(3) int restDurationSec,
    @Default(3) int sets,
    @Default(1) int repsPerSet,
    @Default(180) int restBetweenSetsSec,
    @Default(0.0) double targetWeightKg,
    @Default(2.0) double hangThresholdKg,
    String? gripId,
    @Default(HandMode.alternatePerRep) HandMode handMode,
    @Default(null) List<SetConfig>? setConfigs,
  }) = _ProtocolConfig;

  int get effectiveSets => setConfigs?.length ?? sets;

  SetConfig getSetConfig(int index) =>
      setConfigs != null && index < setConfigs!.length
          ? setConfigs![index]
          : SetConfig(
              hangDurationSec: hangDurationSec,
              restDurationSec: restDurationSec,
              repsPerSet: repsPerSet,
            );

  factory ProtocolConfig.fromJson(Map<String, dynamic> json) =>
      _$ProtocolConfigFromJson(json);
}

@freezed
sealed class WeightSample with _$WeightSample {
  const factory WeightSample({
    required double weight,
    required int timestampMs,
  }) = _WeightSample;

  factory WeightSample.fromJson(Map<String, dynamic> json) =>
      _$WeightSampleFromJson(json);
}

@freezed
sealed class Rep with _$Rep {
  const factory Rep({
    required double peakForceKg,
    required double avgForceKg,
    required int durationMs,
    required int startTimestampMs,
    @Default([]) List<WeightSample> weightSamples,
  }) = _Rep;

  factory Rep.fromJson(Map<String, dynamic> json) => _$RepFromJson(json);
}

@freezed
sealed class TrainingSet with _$TrainingSet {
  const factory TrainingSet({
    @Default([]) List<Rep> reps,
    @Default(0) int restDurationMs,
  }) = _TrainingSet;

  factory TrainingSet.fromJson(Map<String, dynamic> json) =>
      _$TrainingSetFromJson(json);
}

@freezed
sealed class Session with _$Session {
  const factory Session({
    required String id,
    required ProtocolType protocolType,
    required ProtocolConfig protocolConfig,
    @Default([]) List<TrainingSet> sets,
    required DateTime startedAt,
    DateTime? endedAt,
    @Default(0.0) double peakForceKg,
    @Default(0.0) double avgPeakForceKg,
    @Default('') String notes,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}

@freezed
sealed class ActiveSessionState with _$ActiveSessionState {
  const factory ActiveSessionState({
    required ProtocolConfig protocol,
    @Default(0) int currentSetIndex,
    @Default(SessionPhase.idle) SessionPhase phase,
    @Default(0) int phaseRemainingMs,
    @Default(0) int phaseElapsedMs,
    @Default(0) int phaseDeadlineMs,
    @Default(0) int phaseStartMs,
    Rep? currentRep,
    @Default([]) List<TrainingSet> completedSets,
    @Default([]) List<Rep> currentSetReps,
    @Default(0.0) double liveWeightKg,
    @Default(0.0) double peakWeightKg,
    @Default([]) List<WeightSample> liveWeightHistory,
    @Default(false) bool isPaused,
    @Default(0) int currentHandIndex, // 0 = left, 1 = right
    // Timer is frozen until weight crosses hangThresholdKg
    @Default(false) bool waitingForThreshold,
  }) = _ActiveSessionState;
}
