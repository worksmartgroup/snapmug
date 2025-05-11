import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:snapmug/model/model_song.dart';

class GetSongsFromPlaylistController extends GetxController {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final isLoading = true.obs;
  List<SongModel> songsList = [];

//////////////////////fetchPlaylistSongs///////////////////////////////////
  Future<void> fetchPlaylistSongs(String playlistId) async {
    try {
      isLoading(true);
      songsList.clear();

      final songIds = await fetchSongIdsFromPlaylist(playlistId);
      debugPrint("Fetched ${songIds.length} valid song IDs");

      if (songIds.isEmpty) {
        isLoading(false);

        return;
      }

      final songs = await fetchSongsDetails(songIds);
      List<SongModel> reverseSongs = songs.reversed.toList();
      songsList = reverseSongs;

      isLoading(false);
    } catch (e) {
      debugPrint("Error in fetchPlaylistSongs: ${e.toString()}");
      isLoading(false);

      Fluttertoast.showToast(msg: "Error loading playlist");
    }
  }

/////////////////////////fetchSongIdsFromPlaylist////////////////////////////////////////
  Future<List<String>> fetchSongIdsFromPlaylist(String playlistId) async {
    try {
      DatabaseEvent event =
          await _db.child("playlists/$playlistId/songs").once();
      print("11111111111111111111111111111111111111");
      print(event.snapshot.value);
      if (!event.snapshot.exists) {
        debugPrint("No songs found in playlist");
        return [];
      }

      final Map<dynamic, dynamic> songs = event.snapshot.value as Map;

      return songs.entries
          .map((entry) => _extractSongId(entry.key, entry.value))
          .where((id) => id != null && _isValidFirebaseId(id!))
          .map((id) => id!)
          .toList();
    } catch (e) {
      debugPrint("Error fetching song IDs: ${e.toString()}");
      return [];
    }
  }

/////////////////////////_extractSongId////////////////////////////
  String? _extractSongId(dynamic key, dynamic value) {
    if (value is Map) return value['id']?.toString() ?? key?.toString();
    if (value is String) return value;
    return key?.toString();
  }

//////////////////////////////fetchSongsDetails//////////////////////////////////////
  Future<List<SongModel>> fetchSongsDetails(List<String> songIds) async {
    List<SongModel> validSongs = [];

    try {
      for (String id in songIds) {
        try {
          // 1. التحقق من صحة ID قبل الجلب
          if (!_isValidFirebaseId(id)) {
            debugPrint("Skipping invalid song ID: $id");
            continue;
          }

          // 2. جلب بيانات الأغنية من المسار الصحيح (Allmusic بدلاً من songs)
          debugPrint("Fetching song from path: AllMusic/$id");
          DatabaseEvent event = await _db.child("AllMusic/$id").once();

          // 3. تسجيل بيانات الإيفنت للتحقق
          debugPrint("Event snapshot exists: ${event.snapshot.exists}");
          debugPrint("Event snapshot value: ${event.snapshot.value}");

          if (!event.snapshot.exists) {
            debugPrint("Song $id not found in Allmusic");

            // التحقق من هيكل Allmusic بالكامل
            DatabaseEvent allMusicEvent = await _db.child("AllMusic").once();
            debugPrint(
                "All AllMusic keys: ${(allMusicEvent.snapshot.value as Map?)?.keys?.join(', ')}");

            continue;
          }

          // 4. معالجة البيانات المسترجعة
          final songData = event.snapshot.value;
          if (songData == null) {
            debugPrint("Null data for song $id");
            continue;
          }

          final Map<String, dynamic> data =
              Map<String, dynamic>.from(songData as Map);

          // 5. تسجيل البيانات المسترجعة للتحقق
          debugPrint("Raw song data for $id: $data");

          final SongModel? song = _parseSongData(id, data);

          if (song != null) {
            validSongs.add(song);
            debugPrint("Successfully parsed song: ${song.songName}");
          } else {
            debugPrint("Failed to parse song with ID: $id");
          }
        } catch (e) {
          debugPrint("Error processing song $id: ${e.toString()}");
        }
      }
    } catch (e) {
      debugPrint("Error in fetchSongsDetails: ${e.toString()}");
      Fluttertoast.showToast(msg: "Error loading songs");
    }

    debugPrint("Successfully loaded ${validSongs.length} songs");
    return validSongs;
  }

  /////////////////////////////_isValidFirebaseId//////////////////////////////////////
  bool _isValidFirebaseId(String id) {
    return id.isNotEmpty &&
        !id.contains('.') &&
        !id.contains('/') &&
        !id.contains('?');
  }

  /////////////////////////////_parseSongData//////////////////////////////////////
  SongModel? _parseSongData(String id, Map<String, dynamic> data) {
    try {
      SongModel model = SongModel.fromMap(data);

      return model;
    } catch (e) {
      debugPrint("Error parsing song data: ${e.toString()}");
      return null;
    }
  }

  /////////////////////////////addSongToPlaylist//////////////////////////////////////
  Future<bool> deleteItem({
    required String playlistId,
    required String songId,
  }) async {
    try {
      // 1. الحصول على songKey أولاً
      String? songKey =
          await getSongKey(playlistId: playlistId, songId: songId);

      // 2. التحقق من وجود songKey
      if (songKey == null) {
        Fluttertoast.showToast(
          msg: "Song not found in playlist",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return false;
      }

      print("Deleting: $playlistId --- [$songKey] --- $songId");
      isLoading(true);

      // 3. حذف الأغنية من playlist
      await _db.child("playlists/$playlistId/songs/$songKey").remove();

      // 4. إعادة جديد قائمة الأغاني بعد الحذف
      await fetchPlaylistSongs(playlistId);

      // 5. إذا أصبحت playlist فارغة، احذفها
      if (songsList.isEmpty) {
        Fluttertoast.showToast(
          msg: "Playlist is now empty and will be removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
        );

        await _db.child("playlists/$playlistId").remove();
        Get.back(result: true); // العودة للشاشة السابقة إذا لزم الأمر
      }

      isLoading(false);
      return true;
    } catch (e) {
      debugPrint("Error deleting item: $e");
      isLoading(false);
      Fluttertoast.showToast(
        msg: "Failed to delete song",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return false;
    }
  }

  Future<String?> getSongKey({
    required String playlistId,
    required String songId,
  }) async {
    try {
      final event = await _db.child("playlists/$playlistId/songs").once();

      if (event.snapshot.value != null) {
        final songs = event.snapshot.value as Map<dynamic, dynamic>;

        // البحث باستخدام firstWhere بدلاً من forEach لأفضل أداء
        final matchingEntry = songs.entries.firstWhere(
          (entry) => entry.value['id'] == songId,
          orElse: () => MapEntry(null, null),
        );

        return matchingEntry.key;
      }
      return null;
    } catch (e) {
      debugPrint("Error getting song key: $e");
      return null;
    }
  }
}
