import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PlaylistService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  bool _isValidFirebaseId(String id) {
    return id.isNotEmpty &&
        !id.contains('.') &&
        !id.contains('/') &&
        !id.contains('[') &&
        !id.contains(']') &&
        !id.contains('#') &&
        !id.contains('\$');
    String _generatePushKey() {
      return _db.push().key!;
    }
  }

  Future<String?> createPlaylist(String userId, String playlistName,
      List<String> songIds, String imageCover) async {
    try {
      // التحقق من صحة المدخلات
      if (userId.isEmpty || playlistName.isEmpty) {
        throw ArgumentError("معرف المستخدم واسم القائمة مطلوبان");
      }

      // إنشاء معرف فريد للقائمة
      final playlistRef = _db.child("playlists").push();
      final playlistId = playlistRef.key;

      // إنشاء هيكل البيانات الأساسي للقائمة
      final playlistData = {
        "id": playlistId,
        "name": playlistName.trim(),
        "userId": userId,
        "createdAt": ServerValue.timestamp,
        "songs": <String, dynamic>{},
        "imageCover": imageCover,
      };

      // إضافة الأغاني إذا كانت متوفرة
      if (songIds.isNotEmpty) {
        for (final songId in songIds) {
          if (_isValidFirebaseId(songId)) {
            final songKey =
                _db.child("playlists/$playlistId/songs").push().key!;
            ((playlistData["songs"] ??= <String, dynamic>{})
                as Map<String, dynamic>)[songKey] = {
              'id': songId,
              'addedAt': ServerValue.timestamp,
            };
          }
        }
      }

      // حفظ البيانات في Firebase
      await playlistRef.set(playlistData);

      debugPrint("تم إنشاء قائمة التشغيل بنجاح: $playlistId");
      return playlistId;
    } catch (e) {
      debugPrint("فشل في إنشاء قائمة التشغيل: ${e.toString()}");
      Fluttertoast.showToast(msg: "Error to create playList");
      return null;
    }
  }

  /////////////////////addSongToPlaylist////////////////////
  Future<bool> addSongToPlaylist({
    required String userId,
    required String playlistId,
    required String songId,
    required String imageCover,
  }) async {
    try {
      // 1. التحقق من صحة المدخلات
      if (userId.isEmpty || playlistId.isEmpty || songId.isEmpty) {
        throw ArgumentError("يجب تقديم جميع المعرفات المطلوبة");
      }

      // 2. التحقق من وجود القائمة وملكيتها
      final playlistSnapshot = await _db.child("playlists/$playlistId").get();

      if (!playlistSnapshot.exists) {
        throw Exception("قائمة التشغيل غير موجودة");
      }

      final playlistData = _safeCastMap(playlistSnapshot.value);
      if (playlistData['userId'] != userId) {
        throw Exception("ليس لديك صلاحية لتعديل هذه القائمة");
      }

      // 3. التحقق من وجود الأغنية
      final songSnapshot = await _db.child("songs/$songId").get();
      if (songSnapshot.exists) {
        debugPrint("بيانات الأغنية غير موجودة: ${songSnapshot.value}");
        throw Exception("الأغنية غير موجودة في قاعدة البيانات");
      }

      // 4. التحقق من عدم تكرار الأغنية
      final songsSnapshot =
          await _db.child("playlists/$playlistId/songs").get();
      if (songsSnapshot.exists) {
        final songs = _safeCastMap(songsSnapshot.value);
        if (songs.values.any((song) => _safeCastMap(song)['id'] == songId)) {
          throw Exception("الأغنية موجودة بالفعل في هذه القائمة");
        }
      }

      // 5. إضافة الأغنية
      final newSongKey = _db.child("playlists/$playlistId/songs").push().key;
      await _db.child("playlists/$playlistId/songs/$newSongKey").set({
        'id': songId,
        'addedAt': ServerValue.timestamp,
      });

      // 6. update playlist image cover
      await _db
          .child("playlists/$playlistId")
          .update({"imageCover": imageCover});

      return true;
    } catch (e) {
      debugPrint("حدث خطأ: ${e.toString()}\n${e}");
      _showErrorToast(_getErrorMessage(e));
      return false;
    }
  }

// دالة مساعدة للتحويل الآمن للخرائط
  Map<String, dynamic> _safeCastMap(dynamic data) {
    try {
      if (data == null) return {};
      return Map<String, dynamic>.from(data as Map);
    } catch (e) {
      debugPrint("خطأ في تحويل الخريطة: ${e.toString()}");
      return {};
    }
  }

// دالة لعرض رسائل الخطأ
  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red[700],
      textColor: Colors.white,
    );
  }

// دالة لتحسين رسائل الخطأ
  String _getErrorMessage(dynamic error) {
    if (error is ArgumentError) return error.message.toString();
    if (error is FirebaseException) return "خطأ في الاتصال بقاعدة البيانات";
    return error.toString();
  }

  String _getUserFriendlyError(dynamic error) {
    if (error is ArgumentError) {
      return error.message.toString();
    } else if (error is FirebaseException) {
      return "حدث خطأ في الاتصال بقاعدة البيانات";
    }
    return error.toString();
  }

// دالة مساعدة للتحويل الآمن
  Map<String, dynamic> _convertFirebaseMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return data.cast<String, dynamic>();
    }
    return {};
  }

  ////////////////////////////get playLests//////////////////////////

  Future<List<Map<String, dynamic>>> getUserPlaylists(String userId) async {
    try {
      DatabaseEvent event = await _db
          .child("playlists")
          .orderByChild("userId")
          .equalTo(userId)
          .once();
      DataSnapshot snapshot = event.snapshot;

      if (!snapshot.exists) {
        print("❌ لا توجد قوائم تشغيل لهذا المستخدم!");
        return [];
      }

      List<Map<String, dynamic>> playlists = [];
      Map<dynamic, dynamic> playlistsData =
          snapshot.value as Map<dynamic, dynamic>;

      playlistsData.forEach((key, value) {
        Map<String, dynamic> playlistInfo = Map<String, dynamic>.from(value);

        playlists.add({
          "id": key, // معرف قائمة التشغيل
          "name": playlistInfo["name"],
          "imageCover": playlistInfo['imageCover'] // اسم القائمة
        });
      });

      print("✅ تم استرجاع قوائم التشغيل: $playlists");
      return playlists;
    } catch (e) {
      print("❌ حدث خطأ أثناء استرجاع قوائم التشغيل: $e");
      return [];
    }
  }

///////////////////////////loading playLists///////////////////
  Future<void> loadUserPlaylists() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> playlists =
        await PlaylistService().getUserPlaylists(userId);

    if (playlists.isNotEmpty) {
      print("📂 لديك ${playlists.length} قوائم تشغيل:");
      for (var playlist in playlists) {
        print("- ${playlist['id']}: ${playlist['name']}");
      }
    } else {
      print("🚫 لا توجد قوائم تشغيل متاحة.");
    }
  }

/////////////////////////getSongsByIds////////////////////////
  Future<Map<String, Map<String, dynamic>>> getSongsByIds(
      List<String> songIds) async {
    try {
      DatabaseReference songsRef =
          FirebaseDatabase.instance.ref().child('songs');

      // إنشاء قائمة من الـ Futures
      List<Future<MapEntry<String, Map<String, dynamic>?>>> futures =
          songIds.map((songId) async {
        DatabaseEvent event = await songsRef.child(songId).once();
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          Map<String, dynamic> songData =
              Map<String, dynamic>.from(snapshot.value as Map);
          songData['id'] = songId;
          return MapEntry(songId, songData);
        }
        return MapEntry(songId, null);
      }).toList();

      // تنفيذ جميع الـ Futures بشكل متوازي
      List<MapEntry<String, Map<String, dynamic>?>> results =
          await Future.wait(futures);

      // تحويل النتائج إلى Map مع تصفية القيم الفارغة
      return Map.fromEntries(
          results.where((entry) => entry.value != null).cast());
    } catch (error) {
      print('حدث خطأ أثناء جلب بيانات الأغاني: $error');
      return {};
    }
  }

//////////////////////////////getLastSongsFromAllPlaylists////////////////////////////
  Future<Map<String, Map<String, dynamic>>> getLastSongsFromUserPlaylists(
      String userId) async {
    try {
      DatabaseReference playlistsRef =
          FirebaseDatabase.instance.ref().child('playlists');
      DatabaseEvent event = await playlistsRef.once();
      DataSnapshot playlistsSnapshot = event.snapshot;

      Map<String, Map<String, dynamic>> result = {};

      if (playlistsSnapshot.value != null) {
        Map<dynamic, dynamic> playlistsData =
            playlistsSnapshot.value as Map<dynamic, dynamic>;

        // جلب بيانات كل playlist
        for (var playlistEntry in playlistsData.entries) {
          String playlistId = playlistEntry.key;
          Map<dynamic, dynamic> playlistData =
              playlistEntry.value as Map<dynamic, dynamic>;

          // التحقق من أن الplaylist يخص المستخدم المحدد
          if (playlistData['userId'] == userId) {
            // التحقق من وجود أغاني في الplaylist
            if (playlistData['songs'] != null && playlistData['songs'] is Map) {
              Map<dynamic, dynamic> songs =
                  playlistData['songs'] as Map<dynamic, dynamic>;

              if (songs.isNotEmpty) {
                // الحصول على آخر أغنية (آخر مفتاح في الMap)
                var lastSongEntry = songs.entries.last;
                String lastSongId = lastSongEntry.key;
                Map<String, dynamic> lastSongData =
                    Map<String, dynamic>.from(lastSongEntry.value as Map);

                // إضافة بيانات الplaylist
                result[playlistId] = {
                  'playlistName': playlistData['name'],
                  'lastSong': {
                    'id': lastSongId,
                    ...lastSongData,
                  },
                  'userId': userId,
                };
              }
            }
          }
        }
      }

      return result;
    } catch (error) {
      print('حدث خطأ أثناء جلب بيانات آخر الأغاني: $error');
      return {};
    }
  }
}
