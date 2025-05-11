import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Globals {
  static final Globals _instance = Globals._internal();
  factory Globals() => _instance;
  Globals._internal();

  // ألوان
  final Color yellowColor = const Color(0xFFFFD700);

  // حالة المشغل
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  bool isLooped = false;
  bool isShuffled = false;
  bool isFavorite = false;

  // قائمة التشغيل والأغنية الحالية
  List<Song> playlist = [];
  Song? selectedSong;
  String playingSongTitle = 'No song selected';

  // تهيئة المشغل
  Future<void> initPlayer() async {
    await player.setReleaseMode(ReleaseMode.stop);
    player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
    });
  }

  // تغيير حالة المفضلة
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  // تغيير حالة التشغيل العشوائي
  void toggleShuffle() {
    isShuffled = !isShuffled;
  }

  // تغيير حالة التكرار
  Future<void> toggleLoop() async {
    if (!isLooped) {
      await player.setReleaseMode(ReleaseMode.loop);
      isLooped = true;
    } else {
      await player.setReleaseMode(ReleaseMode.stop);
      isLooped = false;
    }
  }

  // تشغيل أغنية محددة
  Future<bool> playSong(Song song) async {
    try {
      selectedSong = song;
      playingSongTitle = song.title;

      await player.stop();
      await player.setSource(UrlSource(song.audioUrl));
      await player.resume();

      return true;
    } catch (e) {
      debugPrint('Error playing song: $e');
      return false;
    }
  }

  // تشغيل الأغنية التالية
  Future<bool> playNextSong() async {
    if (playlist.isEmpty || selectedSong == null) return false;

    try {
      int currentIndex = playlist.indexWhere((s) => s.id == selectedSong!.id);
      int nextIndex = (currentIndex + 1) % playlist.length;
      return await playSong(playlist[nextIndex]);
    } catch (e) {
      debugPrint('Error playing next song: $e');
      return false;
    }
  }

  // تشغيل الأغنية السابقة
  Future<bool> playPreviousSong() async {
    if (playlist.isEmpty || selectedSong == null) return false;

    try {
      int currentIndex = playlist.indexWhere((s) => s.id == selectedSong!.id);
      int prevIndex =
          (currentIndex - 1) >= 0 ? currentIndex - 1 : playlist.length - 1;
      return await playSong(playlist[prevIndex]);
    } catch (e) {
      debugPrint('Error playing previous song: $e');
      return false;
    }
  }

  // تشغيل أغنية عشوائية
  Future<bool> playRandomSong() async {
    if (playlist.isEmpty) return false;

    try {
      int randomIndex = Random().nextInt(playlist.length);
      return await playSong(playlist[randomIndex]);
    } catch (e) {
      debugPrint('Error playing random song: $e');
      return false;
    }
  }

  // تبديل التشغيل/الإيقاف
  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await player.pause();
    } else {
      if (selectedSong != null) {
        await player.resume();
      } else if (playlist.isNotEmpty) {
        await playSong(playlist.first);
      }
    }
  }

  // تنظيف الموارد
  Future<void> dispose() async {
    await player.dispose();
  }
}

final globals = Globals();

class Song {
  final String id;
  final String title;
  final String audioUrl;

  const Song({
    required this.id,
    required this.title,
    required this.audioUrl,
  });
}
