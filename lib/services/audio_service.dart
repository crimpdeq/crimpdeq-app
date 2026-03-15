import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _muted = false;

  bool get isMuted => _muted;

  void setMuted(bool muted) {
    _muted = muted;
  }

  Future<void> playHangStart() => _play('assets/audio/hang_start.wav');
  Future<void> playCountdown() => _play('assets/audio/countdown.wav');
  Future<void> playRepComplete() => _play('assets/audio/rep_complete.wav');
  Future<void> playRestOver() => _play('assets/audio/rest_over.wav');
  Future<void> playSessionComplete() =>
      _play('assets/audio/session_complete.wav');

  Future<void> _play(String assetPath) async {
    if (_muted) return;
    try {
      await _player.setAsset(assetPath);
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      // Browser autoplay policies or missing asset — silently ignore
      debugPrint('AudioService: failed to play $assetPath: $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
