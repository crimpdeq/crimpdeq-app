import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
  final RepDetector _repDetector = RepDetector();
  StreamSubscription<dynamic>? _weightSubscription;
  final List<Rep> _currentSetReps = [];
  int _sessionStartMs = 0;
  int _phaseStartMs = 0;

  @override
  ActiveSessionState? build() => null;

  AudioService get _audio => ref.read(audioServiceProvider);

  void startSession(ProtocolConfig config) {
    _repDetector.updateConfig(
      RepDetectorConfig(
        hangThresholdKg: config.hangThresholdKg,
      ),
    );
    _repDetector.reset();
    _currentSetReps.clear();
    _sessionStartMs = DateTime.now().millisecondsSinceEpoch;

    state = ActiveSessionState(
      protocol: config,
      phase: SessionPhase.countdown,
      phaseRemainingMs: 3000,
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
    _weightSubscription = Stream.periodic(const Duration(milliseconds: 100))
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

    // Update live weight
    final samples = List<WeightSample>.from(current.liveWeightHistory);
    samples.add(WeightSample(
      weight: weight,
      timestampMs: timestampMs - _sessionStartMs,
    ));
    // Keep last 600 samples (~30 seconds at 50ms polling)
    if (samples.length > 600) {
      samples.removeRange(0, samples.length - 600);
    }

    final peakWeight =
        weight > current.peakWeightKg ? weight : current.peakWeightKg;

    final elapsed = current.protocol.type == ProtocolType.maxHang &&
            current.phase == SessionPhase.hanging &&
            _phaseStartMs > 0
        ? timestampMs - _phaseStartMs
        : current.phaseElapsedMs;

    state = current.copyWith(
      liveWeightKg: weight,
      peakWeightKg: peakWeight,
      liveWeightHistory: samples,
      phaseElapsedMs: elapsed,
    );

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
    _audio.playRepComplete();

    final current = state;
    if (current == null) return;

    // Expose in-progress reps to UI
    state = current.copyWith(
      currentSetReps: List.unmodifiable(_currentSetReps),
    );

    // Check if set is complete (for structured protocols)
    if (current.protocol.type == ProtocolType.maxHang) {
      // Max hang: each rep completes the set (hang until failure)
      _completeCurrentSet();
    } else if (current.protocol.type == ProtocolType.repeater &&
        _currentSetReps.length >= current.protocol.repsPerSet) {
      _completeCurrentSet();
    }
  }

  void _startHangPhase() {
    _audio.playHangStart();
    final current = state;
    if (current == null) return;

    if (current.protocol.type == ProtocolType.maxHang) {
      // Max hang: no timer — hang until failure (rep detector triggers end)
      _phaseStartMs = DateTime.now().millisecondsSinceEpoch;
      state = current.copyWith(
        phase: SessionPhase.hanging,
        phaseRemainingMs: 0,
        phaseElapsedMs: 0,
      );
    } else if (current.protocol.type == ProtocolType.repeater) {
      final hangMs = current.protocol.hangDurationSec * 1000;
      state = current.copyWith(
        phase: SessionPhase.hanging,
        phaseRemainingMs: hangMs,
      );
      _startPhaseCountdown(hangMs, () {
        _startRestPhase();
      });
    } else {
      // Freeform: no timer, no auto-transition
      state = current.copyWith(
        phase: SessionPhase.hanging,
        phaseRemainingMs: 0,
      );
    }
  }

  void _startRestPhase() {
    _audio.playRestOver();
    final current = state;
    if (current == null) return;

    final restMs = current.protocol.restDurationSec * 1000;
    state = current.copyWith(
      phase: SessionPhase.resting,
      phaseRemainingMs: restMs,
    );

    _startPhaseCountdown(restMs, () {
      // Check if we've completed enough reps for this set
      if (_currentSetReps.length >= current.protocol.repsPerSet) {
        _completeCurrentSet();
      } else {
        _startHangPhase();
      }
    });
  }

  void _completeCurrentSet() {
    final current = state;
    if (current == null) return;

    final completedSet = TrainingSet(
      reps: List.unmodifiable(_currentSetReps),
    );
    _currentSetReps.clear();
    _repDetector.reset();

    final sets = [...current.completedSets, completedSet];
    final nextSetIndex = current.currentSetIndex + 1;

    if (nextSetIndex >= current.protocol.sets) {
      // All sets done
      state = current.copyWith(
        completedSets: sets,
        currentSetReps: const [],
        phase: SessionPhase.complete,
        phaseRemainingMs: 0,
      );
      _audio.playSessionComplete();
      _cleanup();
      return;
    }

    final restBetweenMs = current.protocol.restBetweenSetsSec * 1000;
    state = current.copyWith(
      completedSets: sets,
      currentSetReps: const [],
      currentSetIndex: nextSetIndex,
      phase: SessionPhase.restBetweenSets,
      phaseRemainingMs: restBetweenMs,
    );

    _startPhaseCountdown(restBetweenMs, () {
      _startCountdown(3000, () {
        _startHangPhase();
      });
      final s = state;
      if (s != null) {
        state = s.copyWith(
          phase: SessionPhase.countdown,
          phaseRemainingMs: 3000,
        );
      }
    });
  }

  void _startCountdown(int durationMs, VoidCallback onComplete) {
    _cancelTimers();
    var remaining = durationMs;
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      remaining -= 100;
      final current = state;
      if (current == null) {
        timer.cancel();
        return;
      }
      if (remaining <= 0) {
        timer.cancel();
        onComplete();
      } else {
        state = current.copyWith(phaseRemainingMs: remaining);
        // Play countdown beep at each second
        if (remaining % 1000 < 100) {
          _audio.playCountdown();
        }
      }
    });
  }

  void _startPhaseCountdown(int durationMs, VoidCallback onComplete) {
    _phaseTimer?.cancel();
    var remaining = durationMs;
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      remaining -= 100;
      final current = state;
      if (current == null) {
        timer.cancel();
        return;
      }
      if (remaining <= 0) {
        timer.cancel();
        onComplete();
      } else {
        state = current.copyWith(phaseRemainingMs: remaining);
      }
    });
  }

  void pauseSession() {
    final current = state;
    if (current == null || current.isPaused || current.phase == SessionPhase.complete) return;
    _cancelTimers();
    _weightSubscription?.cancel();
    _weightSubscription = null;
    state = current.copyWith(isPaused: true);
  }

  void resumeSession() {
    final current = state;
    if (current == null || !current.isPaused) return;

    state = current.copyWith(isPaused: false);
    _subscribeToWeight();
    _resumePhase(current.phase, current.phaseRemainingMs);
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
        // Max hang & freeform: no timer, wait for rep detector
      case SessionPhase.resting:
        _startPhaseCountdown(remainingMs, () {
          final current = state;
          if (current != null && _currentSetReps.length >= current.protocol.repsPerSet) {
            _completeCurrentSet();
          } else {
            _startHangPhase();
          }
        });
      case SessionPhase.restBetweenSets:
        _startPhaseCountdown(remainingMs, () {
          final s = state;
          if (s != null) {
            state = s.copyWith(
              phase: SessionPhase.countdown,
              phaseRemainingMs: 3000,
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
  }

  void _cleanup() {
    _cancelTimers();
    _weightSubscription?.cancel();
    _weightSubscription = null;
  }
}
