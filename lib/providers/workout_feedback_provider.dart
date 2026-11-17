import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
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
  go('sounds/go.wav'),

  /// A warm-up hold pulls well over its target: two low beeps.
  easeOff('sounds/ease_off.wav');

  const WorkoutCue(this.asset);

  final String asset;
}

/// The cues and the screen while a workout runs, so it can be followed
/// without touching the phone.
class WorkoutFeedback {
  /// Plays [cue] on a player of its own, released once it ends or fails: the
  /// platform can hold a sound back, such as Android while the app is in the
  /// background, and a shared player would hold every later cue back with it.
  Future<void> play(WorkoutCue cue) async {
    final player = AudioPlayer();
    try {
      // Lowers other audio, such as music, instead of pausing it.
      await player.setAudioContext(
        AudioContextConfig(focus: AudioContextConfigFocus.duckOthers).build(),
      );
      await player.play(AssetSource(cue.asset));
      await player.onPlayerComplete.first.timeout(_cueTimeout);
    } on Exception catch (error) {
      // A lost cue leaves the workout running: only the sound is missing.
      debugPrint('The ${cue.name} cue did not play: $error');
    } finally {
      await player.dispose();
    }
  }

  /// Longer than any cue, so a cue that does not end still frees its player.
  static const _cueTimeout = Duration(seconds: 5);

  /// Keeps the screen on, so it does not lock during a hang.
  Future<void> keepScreenOn(bool on) => WakelockPlus.toggle(enable: on);
}

final workoutFeedbackProvider = Provider<WorkoutFeedback>(
  (ref) => WorkoutFeedback(),
);

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
