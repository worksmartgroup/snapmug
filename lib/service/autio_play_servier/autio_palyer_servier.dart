// audio_service.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  static final AudioPlayer _player = AudioPlayer();
  static AudioPlayer get player => _player;

  static Future<void> play(String url) async {
    try {
      await _player.stop();
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Playback error: $e');
      rethrow;
    }
  }

  static Stream<PlayerState> get playerState => _player.playerStateStream;
}
