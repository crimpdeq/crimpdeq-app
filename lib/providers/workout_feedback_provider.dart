import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Workout cues, the OpenGrips beeps.
enum WorkoutCue {
  /// 5 s of rest left.
  restWarning('sounds/rest_warning.wav'),

  /// 2 and 1 s of rest left.
  countdown('sounds/countdown.wav'),

  /// The hang starts, or reaches its target.
  go('sounds/go.wav');

  const WorkoutCue(this.asset);

  final String asset;
}

/// The cues and the screen while a workout runs, so it can be followed
/// without touching the phone.
class WorkoutFeedback {
  // Created on the first cue, so building the workout does not need audio.
  AudioPlayer? _player;

  Future<void> play(WorkoutCue cue) async {
    final player = _player ??= AudioPlayer()
      // Lowers other audio, such as music, instead of pausing it.
      ..setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.duckOthers).build(),
      );
    await player.play(AssetSource(cue.asset));
  }

  /// Keeps the screen on, so it does not lock during a hang.
  Future<void> keepScreenOn(bool on) => WakelockPlus.toggle(enable: on);

  void dispose() => _player?.dispose();
}

final workoutFeedbackProvider = Provider<WorkoutFeedback>((ref) {
  final feedback = WorkoutFeedback();
  ref.onDispose(feedback.dispose);
  return feedback;
});

/// Whether the workout cues are muted, stored on this device.
final soundsMutedProvider = AsyncNotifierProvider<SoundsMutedNotifier, bool>(
  SoundsMutedNotifier.new,
);

class SoundsMutedNotifier extends AsyncNotifier<bool> {
  static const _key = 'training.muted';

  @override
  Future<bool> build() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  Future<void> toggle() async {
    final muted = !await future;
    await (await SharedPreferences.getInstance()).setBool(_key, muted);
    state = AsyncData(muted);
  }
}
