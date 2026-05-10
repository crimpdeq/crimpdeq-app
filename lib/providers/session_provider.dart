import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/session_models.dart';
import '../services/audio_service.dart';
import '../services/mock_data_service.dart';
import '../services/rep_detector.dart';
import 'database_provider.dart';
import 'progressor_provider.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

final sessionProvider =
    NotifierProvider<SessionNotifier, ActiveSessionState?>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<ActiveSessionState?> {
  Timer? _phaseTimer;
  Timer? _countdownTimer;
  Timer? _audioCueTimer;
  final RepDetector _repDetector = RepDetector();
  StreamSubscription<dynamic>? _weightSubscription;
  final List<Rep> _currentSetReps = [];
  final List<WeightSample> _weightSamples = [];
  int _sessionStartMs = 0;
  final List<Timer> _scheduledCueTimers = [];

  @override
  ActiveSessionState? build() => null;

  AudioService get _audio => ref.read(audioServiceProvider);

  void startSession(ProtocolConfig config) {
    WakelockPlus.enable();
    _repDetector.updateConfig(
      RepDetectorConfig(
        hangThresholdKg: config.hangThresholdKg,
      ),
    );
    _repDetector.reset();
    _currentSetReps.clear();
    _weightSamples.clear();
    _sessionStartMs = DateTime.now().millisecondsSinceEpoch;
    final now = DateTime.now().millisecondsSinceEpoch;

    state = ActiveSessionState(
      protocol: config,
      phase: SessionPhase.countdown,
      phaseRemainingMs: 3000,
      phaseDeadlineMs: now + 3000,
    );

    _startCountdown(3000, () {
      _startHangPhase();
    });

    // Configure simulator with session params so mock data aligns
    ref.read(progressorProvider.notifier).configureSimulator(config);

    _subscribeToWeight();
  }

  void _subscribeToWeight() {
    // Always (re)start measurement to ensure simulator timer is running
    ref.read(progressorProvider.notifier).startMeasurement();

    // Poll weight from progressor state
    _weightSubscription?.cancel();
    _weightSubscription = Stream.periodic(const Duration(milliseconds: 200))
        .listen((_) {
      final currentState = ref.read(progressorProvider);
      final weight = currentState.measurement.currentWeight;
      final now = DateTime.now().millisecondsSinceEpoch;

      _onWeightUpdate(weight, now);
    });
  }

  void _onWeightUpdate(double weight, int timestampMs) {
    final current = state;
    if (current == null) return;

    // Maintain rolling weight buffer outside reactive state to avoid
    // copying a 600-element list into a new Freezed object every tick.
    _weightSamples.add(WeightSample(
      weight: weight,
      timestampMs: timestampMs - _sessionStartMs,
    ));
    if (_weightSamples.length > 600) {
      _weightSamples.removeRange(0, _weightSamples.length - 600);
    }

    // Only update state when a new session peak is reached — live weight
    // is read directly from progressorProvider by the gauge UI.
    if (weight > current.peakWeightKg) {
      state = current.copyWith(peakWeightKg: weight);
    }

    // Start the hang timer the moment weight crosses the threshold
    if (current.phase == SessionPhase.hanging &&
        current.waitingForThreshold &&
        weight > current.protocol.hangThresholdKg) {
      _onThresholdMet();
    }

    // Only run rep detection in freeform or during hang/rest phases
    if (current.phase == SessionPhase.hanging ||
        current.phase == SessionPhase.resting ||
        current.protocol.type == ProtocolType.freeform) {
      final result = _repDetector.process(weight, timestampMs);
      if (result.completedRep != null) {
        _onRepCompleted(result.completedRep!);
      }
    }
  }

  void _onRepCompleted(Rep rep) {
    _currentSetReps.add(rep);
    HapticFeedback.lightImpact();
    _audio.playRepComplete();

    final current = state;
    if (current == null) return;

    // Expose in-progress reps to UI
    state = current.copyWith(
      currentSetReps: List.unmodifiable(_currentSetReps),
    );

    // Check if set is complete (for structured protocols)
    final setConfig = current.protocol.getSetConfig(current.currentSetIndex);
    if (current.protocol.type == ProtocolType.maxHang) {
      // Max hang: each rep completes the set (hang until failure)
      _completeCurrentSet();
    } else if (current.protocol.type == ProtocolType.repeater &&
        _currentSetReps.length >= setConfig.repsPerSet) {
      _completeCurrentSet();
    }
  }

  void _toggleHandIfNeeded(SessionPhase trigger) {
    final current = state;
    if (current == null) return;
    final mode = current.protocol.handMode;
    if (mode == HandMode.both ||
        mode == HandMode.left ||
        mode == HandMode.right) {
      return;
    }
    if ((mode == HandMode.alternatePerRep &&
            trigger == SessionPhase.hanging) ||
        (mode == HandMode.alternatePerSet &&
            trigger == SessionPhase.restBetweenSets)) {
      state = current.copyWith(
        currentHandIndex: (current.currentHandIndex + 1) % 2,
      );
    }
  }

  void _startHangPhase() {
    _audio.playHangStart();
    HapticFeedback.mediumImpact();
    final current = state;
    if (current == null) return;

    _toggleHandIfNeeded(SessionPhase.hanging);

    final setConfig = current.protocol.getSetConfig(current.currentSetIndex);
    final threshold = current.protocol.hangThresholdKg;
    final gate = threshold > 0;

    if (current.protocol.type == ProtocolType.maxHang) {
      state = current.copyWith(
        phase: SessionPhase.hanging,
        phaseRemainingMs: 0,
        phaseElapsedMs: 0,
        phaseDeadlineMs: 0,
        phaseStartMs: gate ? 0 : DateTime.now().millisecondsSinceEpoch,
        waitingForThreshold: gate,
      );
    } else if (current.protocol.type == ProtocolType.repeater) {
      final hangMs = setConfig.hangDurationSec * 1000;
      if (gate) {
        // Freeze timer at full hang duration until threshold is crossed
        state = current.copyWith(
          phase: SessionPhase.hanging,
          phaseRemainingMs: hangMs,
          phaseDeadlineMs: 0,
          waitingForThreshold: true,
        );
      } else {
        final now = DateTime.now().millisecondsSinceEpoch;
        state = current.copyWith(
          phase: SessionPhase.hanging,
          phaseRemainingMs: hangMs,
          phaseDeadlineMs: now + hangMs,
          waitingForThreshold: false,
        );
        _startPhaseCountdown(hangMs, () => _startRestPhase());
      }
    } else {
      // Freeform: no timer, no auto-transition
      state = current.copyWith(
        phase: SessionPhase.hanging,
        phaseRemainingMs: 0,
        phaseDeadlineMs: 0,
        phaseStartMs: DateTime.now().millisecondsSinceEpoch,
        waitingForThreshold: false,
      );
    }
  }

  void _onThresholdMet() {
    final current = state;
    if (current == null || !current.waitingForThreshold) return;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (current.protocol.type == ProtocolType.maxHang) {
      state = current.copyWith(
        waitingForThreshold: false,
        phaseStartMs: now,
      );
    } else if (current.protocol.type == ProtocolType.repeater) {
      final setConfig = current.protocol.getSetConfig(current.currentSetIndex);
      final hangMs = setConfig.hangDurationSec * 1000;
      state = current.copyWith(
        waitingForThreshold: false,
        phaseDeadlineMs: now + hangMs,
      );
      _startPhaseCountdown(hangMs, () => _startRestPhase());
    }
  }

  void _startRestPhase() {
    _audio.playRestOver();
    HapticFeedback.lightImpact();
    final current = state;
    if (current == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;

    final setConfig = current.protocol.getSetConfig(current.currentSetIndex);
    final restMs = setConfig.restDurationSec * 1000;
    state = current.copyWith(
      phase: SessionPhase.resting,
      phaseRemainingMs: restMs,
      phaseDeadlineMs: now + restMs,
    );

    _startPhaseCountdown(restMs, () {
      // Check if we've completed enough reps for this set
      if (_currentSetReps.length >= setConfig.repsPerSet) {
        _completeCurrentSet();
      } else {
        _startHangPhase();
      }
    });
  }

  void _completeCurrentSet() {
    HapticFeedback.mediumImpact();
    final current = state;
    if (current == null) return;

    _toggleHandIfNeeded(SessionPhase.restBetweenSets);

    final completedSet = TrainingSet(
      reps: List.unmodifiable(_currentSetReps),
    );
    _currentSetReps.clear();
    _repDetector.reset();

    final sets = [...current.completedSets, completedSet];
    final nextSetIndex = current.currentSetIndex + 1;

    if (nextSetIndex >= current.protocol.effectiveSets) {
      // All sets done
      state = current.copyWith(
        completedSets: sets,
        currentSetReps: const [],
        phase: SessionPhase.complete,
        phaseRemainingMs: 0,
      );
      _audio.playSessionComplete();
      HapticFeedback.heavyImpact();
      _cleanup();
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final restBetweenMs = current.protocol.restBetweenSetsSec * 1000;
    state = current.copyWith(
      completedSets: sets,
      currentSetReps: const [],
      currentSetIndex: nextSetIndex,
      phase: SessionPhase.restBetweenSets,
      phaseRemainingMs: restBetweenMs,
      phaseDeadlineMs: now + restBetweenMs,
    );

    _startPhaseCountdown(restBetweenMs, () {
      final cdNow = DateTime.now().millisecondsSinceEpoch;
      _startCountdown(3000, () {
        _startHangPhase();
      });
      final s = state;
      if (s != null) {
        state = s.copyWith(
          phase: SessionPhase.countdown,
          phaseRemainingMs: 3000,
          phaseDeadlineMs: cdNow + 3000,
        );
      }
    });
  }

  void _startCountdown(int durationMs, VoidCallback onComplete) {
    _cancelTimers();
    // One-shot timer for phase completion — no periodic state mutations
    _countdownTimer = Timer(Duration(milliseconds: durationMs), () {
      final current = state;
      if (current != null) onComplete();
    });
    // Schedule audio/haptic cues at each second boundary
    _scheduleCountdownCues(durationMs);
  }

  void _startPhaseCountdown(int durationMs, VoidCallback onComplete) {
    _phaseTimer?.cancel();
    // One-shot timer for phase completion — no periodic state mutations
    _phaseTimer = Timer(Duration(milliseconds: durationMs), () {
      final current = state;
      if (current != null) onComplete();
    });
    // Schedule haptic cues for rest phases (last 3 seconds)
    final current = state;
    if (current != null &&
        (current.phase == SessionPhase.resting ||
            current.phase == SessionPhase.restBetweenSets)) {
      _scheduleRestHapticCues(durationMs);
    }
  }

  /// Schedule countdown beeps at each second boundary
  void _scheduleCountdownCues(int durationMs) {
    final totalSeconds = durationMs ~/ 1000;
    for (var s = 1; s <= totalSeconds; s++) {
      final delayMs = durationMs - (s * 1000);
      if (delayMs > 0) {
        final timer = Timer(Duration(milliseconds: delayMs), () {
          _audio.playCountdown();
          HapticFeedback.selectionClick();
        });
        _scheduledCueTimers.add(timer);
      }
    }
  }

  /// Schedule haptic feedback for last 3 seconds of rest phases
  void _scheduleRestHapticCues(int durationMs) {
    for (var s = 1; s <= 3; s++) {
      final delayMs = durationMs - (s * 1000);
      if (delayMs > 0) {
        final timer = Timer(Duration(milliseconds: delayMs), () {
          HapticFeedback.lightImpact();
        });
        _scheduledCueTimers.add(timer);
      }
    }
  }

  void pauseSession() {
    final current = state;
    if (current == null || current.isPaused || current.phase == SessionPhase.complete) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    _cancelTimers();
    _weightSubscription?.cancel();
    _weightSubscription = null;

    // When waiting for threshold no timer has started yet — preserve full remaining duration
    final remaining = current.waitingForThreshold
        ? current.phaseRemainingMs
        : current.phaseDeadlineMs > 0
            ? (current.phaseDeadlineMs - now).clamp(0, double.maxFinite).toInt()
            : 0;
    final elapsed = current.phaseStartMs > 0
        ? now - current.phaseStartMs
        : current.phaseElapsedMs;

    state = current.copyWith(
      isPaused: true,
      phaseRemainingMs: remaining,
      phaseElapsedMs: elapsed,
      phaseDeadlineMs: 0,
      phaseStartMs: 0,
    );
  }

  void resumeSession() {
    final current = state;
    if (current == null || !current.isPaused) return;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (current.waitingForThreshold) {
      // No timer to restart — just re-subscribe and wait for threshold crossing
      state = current.copyWith(
        isPaused: false,
        phaseDeadlineMs: 0,
        phaseStartMs: 0,
      );
      _subscribeToWeight();
      return;
    }

    final remainingMs = current.phaseRemainingMs;
    state = current.copyWith(
      isPaused: false,
      phaseDeadlineMs: remainingMs > 0 ? now + remainingMs : 0,
      phaseStartMs: current.phaseElapsedMs > 0 ? now - current.phaseElapsedMs : 0,
    );

    _subscribeToWeight();
    _resumePhase(current.phase, remainingMs);
  }

  void _resumePhase(SessionPhase phase, int remainingMs) {
    switch (phase) {
      case SessionPhase.countdown:
        _startCountdown(remainingMs, () => _startHangPhase());
      case SessionPhase.hanging:
        final current = state;
        if (current != null && current.protocol.type == ProtocolType.repeater) {
          _startPhaseCountdown(remainingMs, () => _startRestPhase());
        }
        // maxHang: no timer needed — UI reads phaseStartMs via Ticker
      case SessionPhase.resting:
        _startPhaseCountdown(remainingMs, () {
          final current = state;
          if (current != null) {
            final setConfig =
                current.protocol.getSetConfig(current.currentSetIndex);
            if (_currentSetReps.length >= setConfig.repsPerSet) {
              _completeCurrentSet();
            } else {
              _startHangPhase();
            }
          }
        });
      case SessionPhase.restBetweenSets:
        _startPhaseCountdown(remainingMs, () {
          final cdNow = DateTime.now().millisecondsSinceEpoch;
          final s = state;
          if (s != null) {
            state = s.copyWith(
              phase: SessionPhase.countdown,
              phaseRemainingMs: 3000,
              phaseDeadlineMs: cdNow + 3000,
            );
          }
          _startCountdown(3000, () => _startHangPhase());
        });
      case SessionPhase.idle:
      case SessionPhase.complete:
        break;
    }
  }

  Session? endSession() {
    final current = state;
    if (current == null) return null;

    final isSimulator =
        ref.read(progressorProvider).connection.isSimulator;

    _cleanup();
    _currentSetReps.clear();
    state = null;

    // In simulator mode, generate realistic mock data instead of using
    // the sparse samples from the throttled web timer
    if (isSimulator) {
      final session = generateSimulatorSession(
        config: current.protocol,
        startedAt: DateTime.fromMillisecondsSinceEpoch(_sessionStartMs),
      );
      _persistSession(session);
      return session;
    }

    // Real device: use actual collected data
    final sets = [...current.completedSets];
    if (_currentSetReps.isNotEmpty) {
      sets.add(TrainingSet(reps: List.unmodifiable(_currentSetReps)));
    }

    final allReps = sets.expand((s) => s.reps).toList();
    final peakForce = allReps.isEmpty
        ? current.peakWeightKg
        : allReps.map((r) => r.peakForceKg).reduce((a, b) => a > b ? a : b);
    final avgPeak = allReps.isEmpty
        ? 0.0
        : allReps.map((r) => r.peakForceKg).reduce((a, b) => a + b) /
            allReps.length;

    final session = Session(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      protocolType: current.protocol.type,
      protocolConfig: current.protocol,
      sets: sets,
      startedAt: DateTime.fromMillisecondsSinceEpoch(_sessionStartMs),
      endedAt: DateTime.now(),
      peakForceKg: peakForce,
      avgPeakForceKg: avgPeak,
    );

    _persistSession(session);
    return session;
  }

  Future<void> _persistSession(Session session) async {
    try {
      final dao = await ref.read(sessionDaoProvider.future);
      await dao.insertSession(session);
      await dao.checkAndUpdatePR(session);
      // Invalidate providers so UI refreshes
      ref.invalidate(sessionHistoryProvider);
      ref.invalidate(personalRecordsProvider);
    } catch (e) {
      debugPrint('Failed to persist session: $e');
    }
  }

  void _cancelTimers() {
    _phaseTimer?.cancel();
    _countdownTimer?.cancel();
    _audioCueTimer?.cancel();
    for (final t in _scheduledCueTimers) {
      t.cancel();
    }
    _scheduledCueTimers.clear();
  }

  void _cleanup() {
    _cancelTimers();
    _weightSubscription?.cancel();
    _weightSubscription = null;
    WakelockPlus.disable();
  }
}
