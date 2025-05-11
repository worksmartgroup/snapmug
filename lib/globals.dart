library globals;

import 'dart:io';
import 'dart:math';

// import 'package:just_audio_web/.dart';

import 'package:dio/dio.dart';
// import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:flutter_cache_just_audio_webmanager/flutter_cache_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
// import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/profile_model.dart';
import 'package:uuid/uuid.dart';

Map<String, Map<String, dynamic>> songTitles = {};
Map<String, Map<String, dynamic>> favTitles = {};
Map<String, Map<String, dynamic>> filteredSongs = {};
Map<String, Map<String, dynamic>> hotSongs = {};
UserProfile? userProfileData;
int _currentSongIndex = 0;
bool isFavorite = false;
AudioPlayer player = AudioPlayer();

bool isPlaying = false;
bool isShuffled = false;
// bool isLooped = true;
Duration duration = Duration.zero;
Duration position = Duration.zero;
bool durationKnown = false;
bool isDataLoaded = false;
String playingSongTitle = "";
String playingSongIconURL = "";
String playingSongTrackArtistName = "";
String producerName = '';
String songID = '';
String local_path = '';
bool trackLoading = true;
SongModel? selectedSong;

String PlayingartistName = '';
String PlayingalbumArtUrl = '';
String PlayingaudioUrl = '';
bool PlayingdollorIconVisiblity = false;
String PlayingfacebookLink = '';
String PlayingfacebookUshes = '';
bool PlayingfireIconVisiblity = false;
String PlayinginstagramLink = '';
String PlayinginstagramUshes = '';
String PlayingproducerName = '';
String PlayingrecordLabel = '';
String PlayingsongId = '';
String PlayingsongName = '';
String PlayingtikTokLink = '';
String PlayingtikTokUshes = '';
String Playingwriter = '';
String PlayingyearOfProduction = '';
String PlayingyoutubeLink = '';
String PlayingyoutubeUshes = '';

ValueNotifier<bool> trackLoadingNotifier = ValueNotifier(true);

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseDatabase _database = FirebaseDatabase.instance;

void filterHotSongs() {
  hotSongs.clear();
  songTitles.forEach((key, value) {
    if (value['fireIconVisiblity'] == true) {
      hotSongs[key] = value;
    }
  });
}

Future<String> downloadAlbumArt(String imageUrl) async {
  final dir = await getTemporaryDirectory();
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  final filePath = '${dir.path}/$fileName';

  try {
    await Dio().download(imageUrl, filePath);
    return filePath;
  } catch (e) {
    print('Error downloading album art: $e');
    return '';
  }
}

Future<void> fetchDataFromFirebase() async {
  try {
    print("fetching from firebase");
    songTitles.clear();
    // Uncomment the following line if Firebase is not initialized yet
    // await Firebase.initializeApp();

    // Reference to the "AllMusic" node
    final database = FirebaseDatabase.instance.ref().child('AllMusic');
    print("fetching done");
    database.keepSynced(true);

    // Read song titles from the database
    database.once().then((DatabaseEvent event) async {
      final DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        final songMap = snapshot.value as Map<dynamic, dynamic>;
        songMap.forEach((key, value) {
          print('local storage path is ${value['local_path']}');
          Map<String, dynamic> songData = {
            'artistName': value['artistName'] ?? '',
            'albumArtUrl': value['albumArtUrl'] ?? '',
            'audioUrl': value['audioUrl'] ?? '',
            'dollorIconVisiblity': value['dollorIconVisiblity'] ?? false,
            'facebookLink': value['facebookLink'] ?? '',
            'facebookUshes': value['facebookUshes'] ?? '',
            'fireIconVisiblity': value['fireIconVisiblity'] ?? false,
            'instagramLink': value['instagramLink'] ?? '',
            'instagramUshes': value['instagramUshes'] ?? '',
            'producerName': value['producerName'] ?? '',
            'recordLabel': value['recordLabel'] ?? '',
            'songId': value['songId'] ?? "",
            'songName': value['songName'] ?? '',
            'tikTokLink': value['tikTokLink'] ?? '',
            'tikTokUshes': value['tikTokUshes'] ?? '',
            'writer': value['writer'] ?? '',
            'yearOfProduction': value['yearOfProduction'] ?? '',
            'youtubeLink': value['youtubeLink'] ?? '',
            'youtubeUshes': value['youtubeUshes'] ?? '',
            'local_path': value['local_path'] ?? '',
          };
          songTitles[key] = songData;
        });
        // if (songTitles.isNotEmpty) {
        final firstSongKey = songTitles.keys.first;
        final firstSongData = songTitles[firstSongKey]!;
        final audioUrl = firstSongData['audioUrl'];
        playingSongTitle = firstSongData['songName'];
        print("feeding done");

        // Uncomment the following line if you are using an audio player package
        // duration = (await player.setUrl(audioUrl))!;
        // print('duration: $duration');

        print('=============x playing audio');
        // try {
        //   playAudio(audioUrl);
        // } on PlayerException catch (e) {
        //   print("Error code: ${e.code}");
        // } catch (e) {
        //   // Fallback for all other errors
        //   print('An error occured: $e');
        // }

        print('=============x playing audio done');

        // player.play();
        // duration = duration!;
        // isPlaying = true; // Update _isPlaying state to true
      } else {
        // Handle the case where no data is found (optional)
        print("No data found in the 'AllMusic' node");
      }
      // Update the UI with fetched data
    }).catchError((error) {
      // Catch and print any error that occurs during the database operation
      print("Error fetching data from Firebase: $error");
    });
  } catch (e) {
    // Catch and print any error that occurs during the whole function execution
    print("An error occurred: $e");
  }
}

// class PositionData {
//   final Duration position;
//   final Duration bufferedPosition;
//   final Duration duration;

//   PositionData(this.position, this.bufferedPosition, this.duration);
// }

// class PlayerControlsWidget extends StatefulWidget {
//   final Stream<PositionData> positionDataStream;
//   final AudioPlayer audioPlayer;
//   final bool isPlaying;
//   final Function(AudioPlayer)? audioPlayerChange;

//   const PlayerControlsWidget({
//     Key? key,
//     required this.positionDataStream,
//     required this.audioPlayer,
//     required this.isPlaying,
//     this.audioPlayerChange,
//   }) : super(key: key);

//   @override
//   _PlayerControlsWidgetState createState() => _PlayerControlsWidgetState();
// }

// class _PlayerControlsWidgetState extends State<PlayerControlsWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         StreamBuilder<PositionData>(
//           stream: widget.positionDataStream,
//           builder: (context, snapshot) {
//             final positionData = snapshot.data;
//             return Column(
//               children: [
//                 Text('Position: ${positionData?.position}'),
//                 Text('Buffered: ${positionData?.bufferedPosition}'),
//                 Text('Duration: ${positionData?.duration}'),
//               ],
//             );
//           },
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             // زر التشغيل / الإيقاف
//             GestureDetector(
//               onTap: () {
//                 if (widget.isPlaying) {
//                   widget.audioPlayer.pause();
//                 } else {
//                   widget.audioPlayer.play();
//                 }
//                 widget.audioPlayerChange?.call(widget.audioPlayer);
//               },
//               child: Icon(
//                 widget.isPlaying ? Icons.pause : Icons.play_arrow,
//                 size: 40,
//                 color: Colors.yellow,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

Future<void> fetchFavouriteFromFirebase() async {
  favTitles.clear();
  print("hi");
  print("fetching from firebase");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? user = _auth.currentUser;
  final String uid = user!.uid;
  final database =
      FirebaseDatabase.instance.ref().child('AllFavourites').child(uid);
  print("fetching done");

  // Wait for the database fetching to complete
  final event = await database.once();
  final DataSnapshot snapshot = event.snapshot;
  if (snapshot.value != null) {
    final songMap = snapshot.value as Map<dynamic, dynamic>;
    songMap.forEach((key, value) {
      Map<String, dynamic> songData = {
        'artistName': value['artistName'],
        'albumArtUrl': value['albumArtUrl'],
        'audioUrl': value['audioUrl'],
        'dollorIconVisiblity': value['dollorIconVisiblity'],
        'facebookLink': value['facebookLink'],
        'facebookUshes': value['facebookUshes'],
        'fireIconVisiblity': value['fireIconVisiblity'],
        'instagramLink': value['instagramLink'],
        'instagramUshes': value['instagramUshes'],
        'producerName': value['producerName'],
        'recordLabel': value['recordLabel'],
        'songId': value['songId'],
        'songName': value['songName'],
        'tikTokLink': value['tikTokLink'],
        'tikTokUshes': value['tikTokUshes'],
        'writer': value['writer'],
        'yearOfProduction': value['yearOfProduction'],
        'youtubeLink': value['youtubeLink'],
        'youtubeUshes': value['youtubeUshes'],
        'local_path': value['local_path'] ?? '',
      };
      favTitles[key] = songData;
    });

    print("feeding done");
  } else {
    print("No data found in the 'AllMusic' node");
  }
}

void ShuffleStateVersa() {
  isShuffled = !isShuffled;
  // notifyListeners();
}

String songIconURL = "";
String localAlbumArtPath = '';

void showLoading() {
  Get.dialog(
    const Center(
      child: CircularProgressIndicator(
        color: Colors.yellow, // لون دائرة التحميل
      ),
    ),
    barrierDismissible: false, // منع إغلاق النافذة بالضغط خارجها
  );
}

Future<bool> playAudio<T>(String audioUrl, String songId, T songsList,
    Function(bool) onChange) async {
  try {
    print(
        "------------------------------------------------------  type : ${songsList.runtimeType}");
    Map<String, Map<String, dynamic>> map = {};
    List<SongModel> list = [];
    if (songsList is Map) {
      map = songsList as Map<String, Map<String, dynamic>>;
    } else {
      list = songsList as List<SongModel>;
    }
    print("====================== $audioUrl");
    // 1. عرض مؤشر التحميل
    showLoading();

    // 2. إيقاف التشغيل الحالي إذا كان يعمل
    if (isPlaying) {
      await player.stop();
    }

    // 3. البحث عن بيانات الأغنية
    String songName = PlayingsongName;
    bool found = false;
    print("--------------------------- nae : $songName");
    if (list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        final song = list[i];
        if (song.songId == songId) {
          // حفظ البيانات المطلوبة
          _currentSongIndex = i;
          isFavourite(song.songId);
          PlayingsongName = song.songName;
          playingSongTitle = song.songName;
          print("------------------- sonName : $PlayingsongName");
          playingSongTrackArtistName = song.artistName;
          songID = song.songId;
          local_path = song.localPath;
          PlayingproducerName = song.producerName;
          PlayingartistName = song.artistName;
          PlayingalbumArtUrl = song.albumArtUrl;
          PlayingaudioUrl = song.audioUrl;
          PlayingdollorIconVisiblity = song.dollarIconVisibility;
          PlayingfacebookLink = song.facebookLink;
          PlayingfacebookUshes = song.facebookUshes;
          PlayingfireIconVisiblity = song.fireIconVisibility;
          PlayinginstagramLink = song.instagramLink;
          PlayinginstagramUshes = song.instagramUshes;
          PlayingproducerName = song.producerName;
          PlayingrecordLabel = song.recordLabel;
          PlayingsongId = song.songId;
          PlayingtikTokLink = song.tikTokLink;
          PlayingtikTokUshes = song.tikTokUshes;
          Playingwriter = song.writer;
          PlayingyearOfProduction = song.yearOfProduction;
          PlayingyoutubeLink = song.youtubeLink;
          PlayingyoutubeUshes = song.youtubeUshes;
          found = true;
          break;
        }
      }
    } else {
      print("---------------------------------- map");
      for (int i = 0; i < map.entries.length; i++) {
        final entry = map.entries.elementAt(i);
        if (entry.value['songId'] == songId) {
          _currentSongIndex = i;
          isFavourite(entry.value['songId']);
          PlayingsongName = entry.value['songName'] ?? '';
          PlayingalbumArtUrl = entry.value['albumArtUrl'] ?? '';
          playingSongTrackArtistName = entry.value['artistName'] ?? '';
          songID = entry.value['songId'];
          local_path = entry.value['local_path'] ?? '';
          PlayingartistName = entry.value['artistName'] ?? "";
          PlayingalbumArtUrl = entry.value['albumArtUrl'] ?? "";
          PlayingaudioUrl = entry.value['audioUrl'] ?? "";

          PlayinginstagramLink = entry.value['instagramLink'] ?? "";
          PlayingfacebookLink = entry.value['facebookLink'] ?? '';

          PlayingfireIconVisiblity = entry.value['fireIconVisiblity'] ?? false;
          PlayingproducerName = entry.value['producerName'] ?? '';
          PlayingtikTokLink = entry.value['tikTokLink'] ?? '';
          PlayingyearOfProduction = entry.value['yearOfProduction'] ?? '';
          PlayingyoutubeLink = entry.value['youtubeLink'] ?? '';
          PlayingdollorIconVisiblity =
              entry.value['dollorIconVisiblity'] ?? false;
          PlayingrecordLabel = entry.value['recordLabel'] ?? '';
          PlayingfacebookUshes = entry.value['facebookUshes'] ?? '';
          Playingwriter = entry.value['writer'] ?? '';
          PlayingsongId = entry.value['songId'] ?? '';
          PlayingtikTokUshes = entry.value['tikTokUshes'] ?? '';
          PlayinginstagramUshes = entry.value['instagramUshes'] ?? '';
          PlayingyoutubeUshes = entry.value['youtubeUshes'] ?? '';

          found = true;
          break;
        }
      }
    }
    if (!found) {
      trackLoading = false;
      onChange(false);
      return false;
    }

    // 5. تنزيل صورة الألبوم إذا لزم الأمر
    if (!kIsWeb) {
      if (local_path.isEmpty) {
        localAlbumArtPath = await downloadAlbumArt(songIconURL);
      }
    } else {
      playingSongIconURL = songIconURL;
    }

    // 6. تشغيل الأغنية
    final success = await _playSong(audioUrl, songId, songName, producerName);

    // 7. تحديث الحالة
    isPlaying = success;
    onChange(success);
    trackLoading = false;

    return success;
  } catch (e) {
    debugPrint('Error in playAudio: $e');
    trackLoading = false;
    onChange(false);
    return false;
  }
}

Future<bool> _playSong(String audioUrl, String songId, String songName,
    String producerName) async {
  if (local_path.isNotEmpty) {
    File file = File(local_path);
    if (await file.exists()) {
      return await _playLocal(local_path, songId, songName, producerName);
    } else {
      // تحميل الملف من جديد
      local_path = await downloadAudioFile(audioUrl, '$songId.mp3') ?? '';
      if (local_path.isNotEmpty) {
        return await _playLocal(local_path, songId, songName, producerName);
      }
    }
  } else {
    // تحميل وتشغيل الملف مباشرة
    local_path = await downloadAudioFile(audioUrl, '$songId.mp3') ?? '';
    if (local_path.isNotEmpty) {
      return await _playLocal(local_path, songId, songName, producerName);
    }
  }

  // إذا فشل تحميل الملف أو تشغيله محليًا، قم بالتشغيل عبر الإنترنت
  return await _playOnline(audioUrl, songId, songName, producerName);
}

Future<bool> _playLocal(String filePath, String songId, String songName,
    String producerName) async {
  try {
    await playLocalAudio(
        filePath, songId, songName, producerName, (bool val) {});
    return true;
  } catch (e) {
    print('خطأ في تشغيل الملف المحلي: $e');
    return false;
  }
}

Future<bool> _playOnline(String audioUrl, String songId, String songName,
    String producerName) async {
  try {
    await playTheUrl(audioUrl, songId, songName, producerName, (bool val) {});
    return true;
  } catch (e) {
    print('خطأ في تشغيل الرابط: $e');
    return false;
  }
}

final FirebaseStorage _storage = FirebaseStorage.instance;

// Function to download and store audio in device memory
Future<String?> downloadAudioFile(String audioUrl, String fileName) async {
  try {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$fileName';
    Dio dio = Dio();

    // تحقق من وجود الملف قبل التنزيل
    File file = File(filePath);
    if (await file.exists()) {
      print('File already exists at: $filePath');
      return filePath;
    }

    // قم بتنزيل الملف إذا لم يكن موجودًا
    await dio.download(audioUrl, filePath);
    print('File downloaded to: $filePath');
    return filePath;
  } catch (e) {
    print('Error downloading audio file: $e');
    return null;
  }
}

final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

Future<void> updateSongData(
    String childId, String newField, dynamic data) async {
  try {
    var songMap = GetStorage().read('songTitles') ?? {};
    songTitles.forEach((key, value) {
      print('these are ittle $key :::::: $value');
      if (childId == value['songId']) {
        Map<String, dynamic> songData = {
          'artistName': value['artistName'],
          'albumArtUrl': value['albumArtUrl'],
          'audioUrl': value['audioUrl'],
          'dollorIconVisiblity': value['dollorIconVisiblity'],
          'facebookLink': value['facebookLink'],
          'facebookUshes': value['facebookUshes'],
          'fireIconVisiblity': value['fireIconVisiblity'],
          'instagramLink': value['instagramLink'],
          'instagramUshes': value['instagramUshes'],
          'producerName': value['producerName'],
          'recordLabel': value['recordLabel'],
          'songId': value['songId'],
          'songName': value['songName'],
          'tikTokLink': value['tikTokLink'],
          'tikTokUshes': value['tikTokUshes'],
          'writer': value['writer'],
          'yearOfProduction': value['yearOfProduction'],
          'youtubeLink': value['youtubeLink'],
          'youtubeUshes': value['youtubeUshes'],
          'local_path': data ?? '',
        };
        songMap.update(key, (existingSongData) {
          // This function defines how to update the song data for the key
          return songData; // Replace the existing data with updated songData
        }, ifAbsent: () => songData);
        songTitles.update(key, (existingSongData) {
          // This function defines how to update the song data for the key
          return songData; // Replace the existing data with updated songData
        }, ifAbsent: () => songData);
      }
    });
    GetStorage().write('songTitles', songMap);
    // var saveData=GetStorage().read('songTitles');

    print('Field added successfully');
  } catch (e) {
    print('Error adding new field: $e');
  }
}

////////////////////////////////////////////////////////////
Future<void> playSelectedSong(String songId) async {
  final songData = songTitles[songId];
  if (songData != null) {
    await manageAudioPlayback(
      audioUrl: songData['audioUrl'],
      songId: songData['songId'],
      songName: songData['songName'],
      producerName: songData['producerName'],
      // loop: isLooped, // يمكنك تمرير قيمة من الإعدادات
      shuffle: isShuffled, // يمكنك تمرير قيمة من الإعدادات
    );
  } else {
    print('Song data not found for ID: $songId');
  }
}

///////////////////////////////////////////////
Future<void> manageAudioPlayback({
  required String audioUrl,
  required String songId,
  required String songName,
  required String producerName,
  bool loop = false,
  bool shuffle = false,
}) async {
  try {
    // إيقاف التشغيل إذا كان هناك أغنية تعمل
    if (isPlaying) {
      await player.stop();
    }

    // تعيين حالة التشغيل
    isPlaying = true;

    // تعيين التكرار (Loop)
    player.setLoopMode(loop ? LoopMode.one : LoopMode.off);

    // تعيين العشوائي (Shuffle)
    if (shuffle) {
      _currentSongIndex = generateRandomNumber(0, songTitles.length - 1);
    }

    // تشغيل الأغنية
    await _playSong(audioUrl, songId, songName, producerName);

    // تحديث حالة التحميل
    trackLoadingNotifier.value = false;
  } catch (e) {
    print('Error managing audio playback: $e');
    trackLoadingNotifier.value = true;
  }
}

/////////////////////////////////////////////////////////////////

////////////////////////////////////////////

////////////////////////////////////////////////

Future<void> playTheUrl(
  String audioUrl,
  String songId,
  String songName,
  String producerName,
  Function(bool) onChange,
) async {
  try {
    await player.setAudioSource(
      AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: songId,
          album: producerName,
          title: songName,
        ),
      ),
    );
    await player.load();
    player.play();
    onChange(true);
    isPlaying = true;
    Get.back();
  } catch (e) {
    Get.back();
    Fluttertoast.showToast(
      msg: "Something went wrong with the audio URL",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    debugPrint('Error in playing audio from URL: $e');
  }
}
////////////////////////////////////////

// late Future<void> _initFuture;
Future<void> playLocalAudio(String audioUrl, String songID, String song_name,
    String producerName, Function(bool) onChange) async {
  print('playing the song from local $audioUrl');
  try {
    File file = File(audioUrl);
    if (await file.exists()) {
      await player.setAudioSource(
        AudioSource.uri(
          Uri.file(audioUrl),
          tag: MediaItem(
            id: songID,
            album: producerName,
            title: song_name,
          ),
        ),
      );
      await player.load();
      player.play();
      onChange(true);
      isPlaying = true;
      Get.back();
    } else {
      print('File does not exist at: $audioUrl');
      Fluttertoast.showToast(msg: "File not found, downloading again...");
      // حاول تنزيل الملف مرة أخرى
      local_path =
          await downloadAudioFile(PlayingaudioUrl, '$songID.mp3') ?? '';
      if (local_path.isNotEmpty) {
        playLocalAudio(local_path, songID, song_name, producerName, onChange);
      } else {
        playTheUrl(PlayingaudioUrl, songID, song_name, producerName, onChange);
      }
    }
  } catch (e) {
    Get.back();
    Fluttertoast.showToast(
        msg: "Something went wrong with local file",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    debugPrint('Error in playing local file: $e');
  }
}

Future<void> playNextSong<T>(T songsList, Function(bool) onChange) async {
  debugPrint('Playing next song...');
  print("================== Input songsList type: ${songsList.runtimeType}");
  print("================== songsList value: $songsList");

  try {
    Map<String, Map<String, dynamic>> map = {};
    List<SongModel> list = [];

    print("================== Generic type T: $T");
    if (songsList is Map &&
        songsList.isNotEmpty &&
        songsList.values.first is Map) {
      print("================== Processing as Map");
      map = songsList as Map<String, Map<String, dynamic>>;
      print("================== Map length: ${map.length}");
    } else {
      print("================== Processing as List<SongModel>");
      list = songsList as List<SongModel>;
      print("================== List length: ${list.length}");
    }

    // أولاً: التخلص من المشغل الحالي بشكل صحيح
    print("================== Disposing current player");
    await player.dispose(); // استخدام dispose بدلاً من stop

    if (list.isNotEmpty) {
      print("================== Handling List<SongModel> case");

      // تحديد الأغنية التالية
      int nextIndex;
      if (isShuffled) {
        print("================== Getting shuffled index");
        nextIndex = _getRandomUniqueIndex();
      } else {
        print("================== Getting sequential index");
        nextIndex = _currentSongIndex < list.length - 1
            ? _currentSongIndex + 1
            : 0; // العودة إلى البداية إذا كانت هذه آخر أغنية
      }
      print("================== Next index: $nextIndex");

      final nextSongData = list[nextIndex]!;
      print("================== Next song data: $nextSongData");
      final url = nextSongData.audioUrl ?? '';
      print("================== Audio URL: $url");

      if (url.isEmpty) {
        print("================== Empty URL detected");
        _showErrorToast('رابط الأغنية غير متوفر');
        onChange(false);
        return;
      }

      // إنشاء مشغل جديد
      print("================== Creating new audio player");
      player = AudioPlayer(); // إعادة إنشاء المشغل بعد التخلص من القديم

      // تشغيل الأغنية الجديدة
      print("================== Attempting to play audio");
      final success =
          await playAudio(url, nextSongData.songId, list, (playSuccess) {});

      if (success) {
        print("================== Playback successful");
        _currentSongIndex = nextIndex;
        selectedSong = nextSongData;
        playingSongTitle = nextSongData.songName ?? '';
        onChange(true);
      } else {
        print("================== Playback failed");
        onChange(false);
      }
    } else {
      print("================== Handling Map case");
      // إذا لم يكن هناك أغاني متاحة
      if (map.isEmpty) {
        print("================== Map is empty");
        _showErrorToast('لا توجد أغاني متاحة');
        onChange(false);
        return;
      }

      // تحديد الأغنية التالية
      int nextIndex;
      if (isShuffled) {
        print("================== Getting shuffled index");
        nextIndex = _getRandomUniqueIndex();
      } else {
        print("================== Getting sequential index");
        nextIndex = _currentSongIndex < map.length - 1
            ? _currentSongIndex + 1
            : 0; // العودة إلى البداية إذا كانت هذه آخر أغنية
      }
      print("================== Next index: $nextIndex");

      final nextSongKey = map.keys.elementAt(nextIndex);
      print("================== Next song key: $nextSongKey");
      final nextSongData = map[nextSongKey]!;
      print("================== Next song data: $nextSongData");
      final url = nextSongData['audioUrl'] ?? '';
      print("================== Audio URL: $url");

      if (url.isEmpty) {
        print("================== Empty URL detected");
        _showErrorToast('رابط الأغنية غير متوفر');
        onChange(false);
        return;
      }

      // إنشاء مشغل جديد
      print("================== Creating new audio player");
      player = AudioPlayer(); // إعادة إنشاء المشغل بعد التخلص من القديم

      // تشغيل الأغنية الجديدة
      print("================== Attempting to play audio");
      final success =
          await playAudio(url, nextSongData['songId'], map, (playSuccess) {});

      if (success) {
        print("================== Playback successful");
        _currentSongIndex = nextIndex;
        selectedSong = SongModel.fromMap(nextSongData);
        playingSongTitle = nextSongData['songName'] ?? '';
        onChange(true);
      } else {
        print("================== Playback failed");
        onChange(false);
      }
    }
  } catch (error) {
    print("================== ERROR: $error");
    debugPrint('حدث خطأ في playNextSong: $error');
    _showErrorToast('فشل تشغيل الأغنية التالية');
    onChange(false);
  }

  print("================== Function completed");
}

// في ملف globals.dart أو حيثما تم تعريف playNextSong
// Future<void> playNextSong<T>(
//     T songsList, bool isPlaylist, Function(bool) onChange) async {
//   debugPrint('Playing next song...');

//   print("================== : $songsList");
//   try {
//     Map<String, Map<String, dynamic>> map = {};
//     List<SongModel> list = [];
//     if (T == Map<String, Map<String, dynamic>>) {
//       map = songsList as Map<String, Map<String, dynamic>>;
//     } else {
//       list = songsList as List<SongModel>;
//     }

//     // أولاً: التخلص من المشغل الحالي بشكل صحيح
//     await player.dispose(); // استخدام dispose بدلاً من stop

//     if (songsList is List<SongModel>) {
//       if (list.isEmpty) {
//         _showErrorToast('لا توجد أغاني متاحة');
//         onChange(false);
//         return;
//       }
//       // تحديد الأغنية التالية
//       int nextIndex;
//       if (isShuffled) {
//         nextIndex = _getRandomUniqueIndex();
//       } else {
//         nextIndex = _currentSongIndex < list.length - 1
//             ? _currentSongIndex + 1
//             : 0; // العودة إلى البداية إذا كانت هذه آخر أغنية
//       }

//       final nextSongData = list[nextIndex]!;
//       final url = nextSongData.audioUrl ?? '';

//       if (url.isEmpty) {
//         _showErrorToast('رابط الأغنية غير متوفر');
//         onChange(false);
//         return;
//       }
// // إنشاء مشغل جديد
//       player = AudioPlayer(); // إعادة إنشاء المشغل بعد التخلص من القديم

//       // تشغيل الأغنية الجديدة
//       final success = await playAudio(
//           url, isPlaylist, nextSongData.songId, list, (playSuccess) {});

//       if (success) {
//         _currentSongIndex = nextIndex;
//         selectedSong = nextSongData;
//         playingSongTitle = nextSongData.songName ?? '';
//         onChange(true);
//       } else {
//         onChange(false);
//       }
//     } else {
//       // إذا لم يكن هناك أغاني متاحة
//       if (map.isEmpty) {
//         _showErrorToast('لا توجد أغاني متاحة');
//         onChange(false);
//         return;
//       }

//       // تحديد الأغنية التالية
//       int nextIndex;
//       if (isShuffled) {
//         nextIndex = _getRandomUniqueIndex();
//       } else {
//         nextIndex = _currentSongIndex < map.length - 1
//             ? _currentSongIndex + 1
//             : 0; // العودة إلى البداية إذا كانت هذه آخر أغنية
//       }

//       final nextSongKey = map.keys.elementAt(nextIndex);
//       final nextSongData = map[nextSongKey]!;
//       final url = nextSongData['audioUrl'] ?? '';

//       if (url.isEmpty) {
//         _showErrorToast('رابط الأغنية غير متوفر');
//         onChange(false);
//         return;
//       }

//       // إنشاء مشغل جديد
//       player = AudioPlayer(); // إعادة إنشاء المشغل بعد التخلص من القديم

//       // تشغيل الأغنية الجديدة
//       final success = await playAudio(
//           url, isPlaylist, nextSongData['songId'], map, (playSuccess) {});

//       if (success) {
//         _currentSongIndex = nextIndex;
//         selectedSong = SongModel.fromMap(nextSongData);
//         playingSongTitle = nextSongData['songName'] ?? '';
//         onChange(true);
//       } else {
//         onChange(false);
//       }
//     }
//   } catch (error) {
//     debugPrint('حدث خطأ في playNextSong: $error');
//     _showErrorToast('فشل تشغيل الأغنية التالية');
//     onChange(false);
//   }
// }

// دالة مساعدة للحصول على فهرس عشوائي فريد (لتجنب تكرار الأغاني في وضع الخلط)
int _getRandomUniqueIndex() {
  if (songTitles.length <= 1) return 0;

  int newIndex;
  do {
    newIndex = Random().nextInt(songTitles.length);
  } while (newIndex == _currentSongIndex && songTitles.length > 1);

  return newIndex;
}

void _showErrorToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

int generateRandomNumber(int min, int max) {
  final random = Random();
  return min + random.nextInt(max - min + 1);
}

Future<void> playPreviousSong<T>(
    bool isPlaylist, T songsList, Function(bool) onChange) async {
  debugPrint('Playing previous song...');
  print("================== Input songsList type: ${songsList.runtimeType}");
  print("================== isPlaylist: $isPlaylist");

  try {
    // Stop current player
    print("================== Stopping current player");
    await player.stop();

    Map<String, Map<String, dynamic>> map = {};
    List<SongModel> list = [];

    // Improved type checking
    if (songsList is Map<String, Map<String, dynamic>>) {
      print(
          "================== Processing as Map<String, Map<String, dynamic>>");
      map = songsList;
      print("================== Map length: ${map.length}");
    } else if (songsList is List<SongModel>) {
      print("================== Processing as List<SongModel>");
      list = songsList;
      print("================== List length: ${list.length}");
    } else {
      throw ArgumentError("Invalid songsList type: ${songsList.runtimeType}");
    }

    // Check if we can go to previous song
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
      print("================== New song index: $_currentSongIndex");

      if (map.isNotEmpty) {
        // Handle Map case
        print("================== Handling Map case");
        final previousSongKey = map.keys.elementAt(_currentSongIndex);
        print("================== Previous song key: $previousSongKey");

        final previousSongData = map[previousSongKey]!;
        print("================== Previous song data: $previousSongData");

        final url = previousSongData['audioUrl'] ?? '';
        print("================== Audio URL: $url");

        if (url.isEmpty) {
          _showErrorToast('Error Link');
          onChange(false);
          return;
        }

        final success = await playAudio<Map<String, Map<String, dynamic>>>(
            url,
            previousSongData['songId'],
            songsList as Map<String, Map<String, dynamic>>, (val) {
          if (val) onChange(val);
        });

        if (success) {
          selectedSong = SongModel.fromMap(previousSongData);
          playingSongTitle = previousSongData['songName'] ?? '';
          // notifyListeners();
        }
      } else {
        // Handle List case
        print("================== Handling List case");
        final previousSongData = list[_currentSongIndex];
        print("================== Previous song data: $previousSongData");

        final url = previousSongData.audioUrl ?? '';
        print("================== Audio URL: $url");

        if (url.isEmpty) {
          _showErrorToast('Error link');
          onChange(false);
          return;
        }

        final success = await playAudio<List<SongModel>>(
            url, previousSongData.songId, songsList as List<SongModel>, (val) {
          if (val) onChange(val);
        });

        if (success) {
          selectedSong = previousSongData;
          playingSongTitle = previousSongData.songName ?? '';
          // notifyListeners();
        }
      }
    } else {
      print("================== Already at first song, can't go previous");
      _showErrorToast('it is already first song');
      onChange(false);
    }
  } catch (error) {
    print("================== ERROR in playPreviousSong: $error");
    debugPrint('حدث خطأ في playPreviousSong: $error');
    _showErrorToast('Error');
    onChange(false);
  }

  print("================== playPreviousSong completed");
}

// void playPreviousSong<T>(
//     bool isPlaylist, T songsList, Function(bool) onChange) {
//   player.stop();

//   Map<String, Map<String, dynamic>> map = {};
//   List<SongModel> list = [];
//   if (songsList is Map &&
//       songsList.isNotEmpty &&
//       songsList.values.first is Map) {
//     map = songsList as Map<String, Map<String, dynamic>>;
//   } else {
//     list = songsList as List<SongModel>;
//   }

//   if (_currentSongIndex > 0) {
//     _currentSongIndex--;
//     if (songsList is Map &&
//         songsList.isNotEmpty &&
//         songsList.values.first is Map) {
//       final previousSongKey = songTitles.keys.elementAt(_currentSongIndex);
//       final previousSongData = songTitles[previousSongKey]!;
//       playAudio(previousSongData['audioUrl'], isPlaylist,
//           previousSongData['songId'], songsList, (val) {
//         if (val) {
//           onChange(val);
//         }
//       });
//       selectedSong = SongModel.fromMap(previousSongData);
//       playingSongTitle = previousSongData['songName'];
//       // notifyListeners();
//     } else {
//       //   final previousSongKey = list.elementAt(_currentSongIndex);
//       final previousSongData = list[_currentSongIndex]!;
//       playAudio(previousSongData.audioUrl, isPlaylist, previousSongData.songId,
//           songsList, (val) {
//         if (val) {
//           onChange(val);
//         }
//       });
//       selectedSong = previousSongData;
//       playingSongTitle = previousSongData.songName;
//       // notifyListeners();
//     }
//   }
// }

// Future<bool> playPreviousSong() async {
//   if (_currentSongIndex > 0) {
//     player.stop();
//     _currentSongIndex--;

//     final previousSongKey = songTitles.keys.elementAt(_currentSongIndex);
//     final previousSongData = songTitles[previousSongKey]!;

//     bool isPlayed = await playAudio(
//       previousSongData['audioUrl'],
//       previousSongData['songId'],
//       (val) {},
//     );

//     selectedSong = Song.fromMap(previousSongData);
//     playingSongTitle = previousSongData['songName'];

//     return isPlayed; // ✅ إرجاع `bool` لتحديد نجاح التشغيل
//   }

//   return false; // ✅ إرجاع `false` إذا لم يكن هناك أغنية سابقة
// }

Future<void> stopAndResetPlayerr<T>(
    T songsList, Function(bool) onChange) async {
  try {
    if (isPlaying) {
      await player.stop();
    }
    _resetPlayerState();
    await playAudio<T>(PlayingaudioUrl, songID, songsList, onChange);
  } catch (e) {
    print('----------------e $e');
  }
}

Future<void> stopAndResetPlayer<T>({
  required T songsList,
  bool shouldRestart = false,
  required Function(bool) onChange,
}) async {
  debugPrint('stopAndResetPlayer called | shouldRestart: $shouldRestart');

  try {
    Map<String, Map<String, dynamic>> map = {};
    List<SongModel> list = [];

    print("================== Generic type T: $T");
    if (songsList is Map &&
        songsList.isNotEmpty &&
        songsList.values.first is Map) {
      print("================== Processing as Map");
      map = songsList as Map<String, Map<String, dynamic>>;
      print("================== Map length: ${map.length}");
    } else {
      print("================== Processing as List<SongModel>");
      list = songsList as List<SongModel>;
      print("================== List length: ${list.length}");
    }

    // إيقاف التشغيل الحالي
    if (isPlaying) {
      await player.stop();
    }

    // إعادة تعيين الحالة
    _resetPlayerState();

    // إذا كان يجب إعادة التشغيل
    if (list.isNotEmpty) {
      debugPrint('إعادة تشغيل الأغنية الحالية: $songID');

      // استدعاء playAudio مع الأغنية الحالية
      final success = await playAudio<T>(
        PlayingaudioUrl,
        songID, // استخدام songID الحالية
        songsList,
        onChange,
      );

      if (!success) {
        throw Exception("فشل في إعادة تشغيل الأغنية");
      }
    } else {
      onChange(true); // فقط إعلام بالإيقاف الناجح
    }
  } catch (e) {
    debugPrint('Error in stopAndResetPlayer: $e');
    _showErrorToast('حدث خطأ أثناء إعادة تعيين المشغل');
    onChange(false);
  } finally {
    trackLoadingNotifier.value = false;
  }
}

void _resetPlayerState() {
  isPlaying = false;
  isShuffled = false;
  trackLoadingNotifier.value = true;
}

Future<void> stopAndClearPlayer({bool shouldRestart = false}) async {
  try {
    // Stop the player if it's playing
    if (player.playing) {
      await player.stop();
    }

    // Clear current audio source
    await player.setAudioSource(ConcatenatingAudioSource(children: []));

    // Reset player state
    await player.seek(Duration.zero);

    // Reset global states
    isPlaying = false;
    playingSongTitle = "";
    playingSongIconURL = "";
    trackLoading = true;

    // Clear song data
    songTitles.clear();
    favTitles.clear();

    // Notify listeners
    trackLoadingNotifier.value = true;

    debugPrint("Player stopped and cleared successfully");

    // Optional restart logic
    if (shouldRestart) {
      await player.play();
      isPlaying = true;
    }
  } catch (e) {
    debugPrint("Error in stopAndClearPlayer: $e");
    // Consider adding error reporting here
  } finally {
    // Any cleanup that should happen regardless of success/failure
  }
}

void filterSongs(String searchTerm) {
  print('searchTerm: $searchTerm');
  filteredSongs.clear();
  if (searchTerm.isEmpty) {
    // If input is empty, show everything
    filteredSongs.addAll(songTitles);
  } else {
    // Filter songs based on the song name
    songTitles.forEach((key, value) {
      if (value['songName'].toLowerCase().contains(searchTerm.toLowerCase())) {
        print(value);
        filteredSongs[key] = value;
      }
      if (value['producerName']
          .toLowerCase()
          .contains(searchTerm.toLowerCase())) {
        print(value);
        filteredSongs[key] = value;
      }
      if (value['artistName']
          .toLowerCase()
          .contains(searchTerm.toLowerCase())) {
        print(value);
        filteredSongs[key] = value;
      }
    });
  }
}

Future<bool> isFavourite(String songId) async {
  // Get the current user
  final User? user = _auth.currentUser;
  if (user == null) {
    throw Exception('No user is signed in');
  }
  final String uid = user.uid;

  // Reference to the user's favourites
  final ref = _database.ref('AllFavourites').child(uid);

  try {
    // Get the user's favourites
    final DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      // Iterate through all favourites to check for the songId
      for (final child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        if (data['songId'] == songId) {
          print("song exist in favourite");
          isFavorite = true;
          return true; // Found the song in favourites
        }
      }
    }
    print("song does not exist in fav");
    // setState(() {
    isFavorite = false;
    // });
    return false; // Song not found in favourites
  } catch (e) {
    print('Error checking favourite: $e');
    return false;
  }
}

void favVersa() {
  if (isFavorite) {
    removeFavourite();
  } else {
    _storeSonginFavourite();
  }
}

void _storeSonginFavourite() {
  final uuid = Uuid();
  final randomChildKey = uuid.v4(); // This generates a version 4 UUID
  String titleUUID = randomChildKey;

  //check if user is new
  final User? user = _auth.currentUser;
  final String? uid = user?.uid;
  final ref = _database.ref('AllFavourites');
  ref.child(uid!).child(titleUUID).set({
    'artistName': PlayingartistName,
    'albumArtUrl': PlayingalbumArtUrl,
    'audioUrl': PlayingaudioUrl,
    'dollorIconVisiblity': PlayingdollorIconVisiblity,
    'facebookLink': PlayingfacebookLink,
    'facebookUshes': PlayingfacebookUshes,
    'fireIconVisiblity': PlayingfireIconVisiblity,
    'instagramLink': PlayinginstagramLink,
    'instagramUshes': PlayinginstagramUshes,
    'producerName': PlayingproducerName,
    'recordLabel': PlayingrecordLabel,
    'songId': PlayingsongId,
    "local_path": local_path,
    'songName': PlayingsongName,
    'tikTokLink': PlayingtikTokLink,
    'tikTokUshes': PlayingtikTokUshes,
    'writer': Playingwriter,
    'yearOfProduction': PlayingyearOfProduction,
    'youtubeLink': PlayingyoutubeLink,
    'youtubeUshes': PlayingyoutubeUshes,
  });
  isFavorite = true;
}

Future<void> removeFavourite() async {
  // Get the current user
  final User? user = _auth.currentUser;
  if (user == null) {
    throw Exception('No user is signed in');
  }
  final String uid = user.uid;

  // Reference to the user's favourites
  final ref = _database.ref('AllFavourites').child(uid);

  try {
    // Get the user's favourites
    final DataSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      // Iterate through all favourites to find the entry with the songId
      for (final child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        if (data['songId'] == PlayingsongId) {
          // Remove the entry from the database
          await ref.child(child.key!).remove();
          print('Favourite removed successfully');
          isFavorite = false;
          return;
        }
      }
    }
    print('Favourite not found');
  } catch (e) {
    print('Error removing favourite: $e');
  }
}
