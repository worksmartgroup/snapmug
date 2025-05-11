import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:snapmug/model/model_song.dart';

class PlayerProvider with ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  SongModel? currentSong;
  bool isPlaying = false;

  void playSong(SongModel song) async {
    currentSong = song;
    await player.setUrl(song.audioUrl);
    await player.play();
    isPlaying = true;
    notifyListeners();
  }

  void pause() async {
    await player.pause();
    isPlaying = false;
    notifyListeners();
  }
}
