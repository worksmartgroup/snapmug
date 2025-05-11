import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:snapmug/core/class/colors.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/globals.dart';
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/play_conytoller_widget.dart';
import 'package:snapmug/widget/home/poster_view_widget.dart';
import 'package:snapmug/widget/home/trend_second/trend_second.dart';

import '../../profile_model.dart';
import '../add_widget.dart';
import 'Hot.dart';

Color yellowColor = const Color(0xffFBD700);
Map<String, Map<String, dynamic>> allSongsList = {};

class HomeBottomNav extends StatefulWidget {
  const HomeBottomNav({super.key});

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  // late Future<void> _initFuture;
  bool isLoggedin = false;
  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser == null) {
      isLoggedin = false;
    } else {
      isLoggedin = true;
    }
    fetchDataFromFirebase();
    getUserProfile();
    super.initState();
  }

  AudioPlayer get _audioPlayer => globals.player;

  Stream<PositionData> get _positionDataStream =>
      rxdart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  bool isLoading = false;
  Future<void> getUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      final DatabaseReference databaseRef = FirebaseDatabase.instance
          .ref()
          .child('AllUsers')
          .child(user?.uid ?? '');
      // Retrieve the data

      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final userProfile = UserProfile.fromMap(data);
        setState(() {
          userProfileData = userProfile;
        });
      } else {
        debugPrint('No data available for this UID.');
      }
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(
        msg: e.message ?? '',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: yellowColor,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> fetchDataFromFirebase() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      // التحقق من الاتصال مرة واحدة فقط
      final connectivityResult = await Connectivity().checkConnectivity();
      print('Connection result: $connectivityResult');

      if (connectivityResult.contains(ConnectivityResult.none)) {
        _loadCachedData();
        return;
      }

      await _fetchFromFirebase();
    } catch (e) {
      debugPrint('Error in fetchDataFromFirebase: $e');
      _loadCachedData(); // حاول تحميل البيانات المخزنة عند الخطأ
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _fetchFromFirebase() async {
    try {
      print("Fetching from Firebase");
      songTitles.clear();

      final database = FirebaseDatabase.instance.ref().child('AllMusic');
      database.keepSynced(true);

      final event = await database.once();
      final snapshot = event.snapshot;

      if (snapshot.value == null) {
        print("No data found in 'AllMusic' node");
        return;
      }

      final songMap = snapshot.value as Map<dynamic, dynamic>;
      _processSongData(songMap);

      // حفظ البيانات مؤقتًا
      await GetStorage().write('songTitles', songTitles);
    } catch (e) {
      debugPrint('Firebase fetch error: $e');
      rethrow;
    }
  }

  void _processSongData(Map<dynamic, dynamic> songMap) {
    // 1. تحويل الخريطة إلى قائمة للفرز
    final sortedEntries = songMap.entries.toList();

    // 2. فرز القائمة تنازلياً حسب عدد التحديات
    sortedEntries.sort((a, b) {
      final challengesA = a.value['challenges'] ?? 0;
      final challengesB = b.value['challenges'] ?? 0;
      return challengesB.compareTo(challengesA);
    });

    // 3. مسح القوائم القديمة قبل الإضافة
    songTitles.clear();
    allSongsList.clear();

    // 4. إضافة جميع الأغاني المرتبة
    for (final entry in sortedEntries) {
      final songData = _createSongData(entry.value);
      songTitles[entry.key] = songData;
      allSongsList[entry.key] = songData;
    }

    // 5. تحديث الأغنية المحددة إذا كانت القائمة غير فارغة
    if (songTitles.isNotEmpty) {
      final firstSongKey = songTitles.keys.first;
      globals.selectedSong = SongModel.fromMap(songTitles[firstSongKey]!);
      playingSongTitle = globals.selectedSong?.songName ?? '';

      // 6. [جديد] تحديث واجهة المستخدم أو أي إجراء آخر مطلوب
      Get.appUpdate(); // إذا كنت تستخدم GetX أو Provider
      // أو
      setState(() {}); // إذا كنت تستخدم StatefulWidget
    }
  }

  Map<String, dynamic> _createSongData(dynamic value) {
    return {
      'fbPrice': value['fbPrice'] ?? "0.0",
      'igPrice': value['igPrice'] ?? '0.0',
      'ttPrice': value['ttPrice'] ?? '0.0',
      'youtubePrice': value['youtubePrice'] ?? '0.0',
      'challenges': value['challenges'] ?? 0,
      'artistName': value['artistName'],
      'albumArtUrl': value['albumArtUrl'],
      "artistImage": value['artistImage'] ?? '',
      "userId": value['userId'] ?? '',
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
      'profilePicture': value['profilePicture'] ?? '',
    };
  }

  void _loadCachedData() {
    try {
      final cachedData = GetStorage().read('songTitles') ?? {};
      print('Loading cached data: ${cachedData.length} items');

      cachedData.forEach((key, value) {
        final songData = _createSongData(value);
        songTitles[key] = songData;
        allSongsList[key] = songData;
      });

      if (songTitles.isNotEmpty) {
        final firstSongKey = songTitles.keys.first;
        globals.selectedSong = SongModel.fromMap(songTitles[firstSongKey]!);
        playingSongTitle = globals.selectedSong?.songName ?? '';
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  int i = 0;

  @override
  Widget build(BuildContext context) {
    if (songTitles.isEmpty) {
      return Text("empty");
    }

    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(backgroundColor: yellowColor),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PosterViewWidget(
                  allSongsList: allSongsList,
                ),
                //////// ad
                BannerAdWidget(
                  addId: 'ca-app-pub-4005202226815050/2958457365',
                ),

                /////////////////////////trend2/
                SizedBox(
                  height: 20,
                ),
                TrendSecond(
                  allSongsList: allSongsList,
                ),
                SizedBox(
                  height: 10,
                ),
                /////////////////// music
                Expanded(
                  flex: 85,
                  child: Container(
                    color: AppColors.primaryColor,
                    child: ListView.separated(
                      itemCount: allSongsList.isEmpty ? 0 : allSongsList.length,
                      // separatorBuilder: (context, index) =>
                      //     Divider(color: Color(0xFF141118)),
                      separatorBuilder: (context, index) => const Divider(
                        height: 0, // or a very small value like 1
                        color: Color(0xFF141118),
                      ),

                      itemBuilder: (context, index) {
                        if (allSongsList.isEmpty) {
                          return const Center(
                            child: Text(
                              'No songs found',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          // final adjustedIndex = index + 8;
                          // if (adjustedIndex >= allSongsList.length) {
                          //   return const SizedBox.shrink();
                          // }
                          // final songKey =
                          //     allSongsList.keys.elementAt(adjustedIndex);
                          // final songData = SongModel.fromMap(
                          //   allSongsList[songKey]!,
                          // );
                          final songKey = allSongsList.keys.elementAt(index);
                          final songData = SongModel.fromMap(
                            allSongsList[songKey]!,
                          );

                          return Column(
                            children: [
                              SongTileWidget(
                                songData: songData,
                                audioPlayer: _audioPlayer,
                                playSong: () async {
                                  try {
                                    debugPrint(
                                        'Attempting to play song: ${songData.songName}');

                                    // 2. التحقق من وجود رابط الصوت
                                    if (songData.audioUrl.isEmpty) {
                                      debugPrint(
                                          'No audio URL for song: ${songData.songId}');
                                      Fluttertoast.showToast(
                                        msg: "Song URL is missing",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        backgroundColor: yellowColor,
                                        textColor: Colors.black,
                                      );
                                      return;
                                    }

                                    // 3. تحديث الحالة قبل التشغيل
                                    if (mounted) {
                                      setState(() {
                                        globals.PlayingalbumArtUrl =
                                            songData.albumArtUrl;
                                        globals.PlayingsongName =
                                            songData.songName;
                                        globals.playingSongTitle =
                                            songData.songName;
                                        globals.selectedSong = songData;
                                        globals.playingSongIconURL =
                                            songData.albumArtUrl;
                                        globals.trackLoading = true;
                                      });
                                    }

                                    // 4. تشغيل الصوت مع معالجة الأخطاء
                                    final success = await globals.playAudio<
                                        Map<String, Map<String, dynamic>>>(
                                      songData.audioUrl,
                                      songData.songId,
                                      globals.songTitles,
                                      (val) {
                                        if (mounted && val) setState(() {});
                                      },
                                    );

                                    // 5. تحديث الحالة بعد التشغيل
                                    if (mounted && success) {
                                      setState(() {
                                        globals.isPlaying = true;
                                        // No need to assign, directly use globals.player
                                        globals.player;
                                        debugPrint('Song started successfully');
                                      });
                                    } else if (!success) {
                                      Fluttertoast.showToast(
                                        msg: "Failed to play song",
                                        toastLength: Toast.LENGTH_SHORT,
                                        backgroundColor: Colors.red,
                                      );
                                    }
                                  } catch (e) {
                                    debugPrint('Error in playSong: $e');
                                    if (mounted) {
                                      setState(() {
                                        globals.isPlaying = false;
                                        globals.trackLoading = false;
                                      });
                                    }
                                    Fluttertoast.showToast(
                                      msg: "Playback error occurred",
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
                PlayerControlsWidget<Map<String, Map<String, dynamic>>>(
                  songsList: globals.songTitles,
                  positionDataStream: _positionDataStream,
                  audioPlayer: globals.player,
                  isPlaying: _audioPlayer.playing,
                  audioPlayerChange: (val) {
                    print('value changed $val');
                    // Update logic here if needed, as _audioPlayer is a getter and cannot be assigned
                    debugPrint(
                        'AudioPlayer instance cannot be directly updated.');
                    print('PLAYER STATE CHENAGES $val');
                    setState(() {});
                  },
                ),
              ],
            ),
    );
  }
}

void showLoading() {
  Get.defaultDialog(
    backgroundColor: Colors.transparent,
    title: '',
    content: const Column(
      children: [
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 25),
      ],
    ),
  );
}
