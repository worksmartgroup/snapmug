import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
// import 'package:just_audio_web/just_audio_web.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:snapmug/data/playlist/playlist.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/pages/play_list.dart';
import 'package:snapmug/play_conytoller_widget.dart';

import 'Home.dart';
import 'Hot.dart';

class SongsBottomNav extends StatefulWidget {
  const SongsBottomNav({super.key});

  @override
  State<SongsBottomNav> createState() => _SongsBottomNavState();
}

class _SongsBottomNavState extends State<SongsBottomNav> {
  bool isLoggedin = false;
  List<String> favouriteSongIds = [];
  List<Map<String, dynamic>> playlists = [];
  late String userId;
  AudioPlayer get _audioPlayer => globals.player;

  Stream<PositionData> get _positionDataStream =>
      rxdart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      isLoggedin = false;
    } else {
      isLoggedin = true;
    }
    userId = FirebaseAuth.instance.currentUser!.uid;
    fetchFavouriteSongs();
    // fetchPlaylists();
  }

  Future<void> fetchFavouriteSongs() async {
    await globals.fetchFavouriteFromFirebase();
    if (!mounted) {
      setState(() {
        favouriteSongIds = globals.favTitles.keys.toList();
      });
    }
  }

  Future<void> fetchPlaylists() async {
    playlists.clear();

    playlists = await PlaylistService().getUserPlaylists(userId);

    setState(() {}); // تحديث الواجهة بعد جلب البيانات
  }

  List<SongModel> songsList = [];

  int selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final String uid = user!.uid;
    return Scaffold(
        body: Column(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 30,
            child: Row(
              children: [
                Expanded(
                  child: TabWidget(
                    title: 'My Favorites',
                    value: '',
                    isSelected: selectedTab == 0,
                    onTap: () {
                      setState(() {
                        selectedTab = 0;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: TabWidget(
                    title: 'My Playlist',
                    value: '',
                    isSelected: selectedTab == 1,
                    onTap: () {
                      setState(() {
                        selectedTab = 1;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: IndexedStack(
            index: selectedTab,
            alignment: Alignment.topCenter,
            children: [
              StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref('AllFavourites')
                    .child(uid.toString())
                    .onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      songsList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return const Center(
                        child: Text(
                      'No data available',
                      style: TextStyle(color: Colors.white),
                    ));
                  }
                  // Process data from snapshot
                  final data =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  songsList = data.values
                      .map((item) =>
                          SongModel.fromMap(item as Map<dynamic, dynamic>))
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: songsList.isEmpty ? 0 : songsList.length,
                    itemBuilder: (context, index) {
                      if (songsList.isEmpty) {
                        return const Center(
                            child: Text(
                          'No songs found',
                          style: TextStyle(color: Colors.white),
                        ));
                      } else {
                        // final songKey = hotSongs.keys.elementAt(index);
                        final songData = songsList[index];
                        return SongTileWidget(
                          songData: songData,
                          audioPlayer: _audioPlayer,
                          playSong: () {
                            debugPrint('playing the song ');

                            globals.PlayingalbumArtUrl = songData.albumArtUrl;
                            globals.PlayingsongName = songData.songName;
                            globals.trackLoading = true;
                            if (songData.audioUrl.isEmpty) {
                              print('This song has not audio url');
                              Fluttertoast.showToast(
                                  msg: "Song does not have an audio url",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: yellowColor,
                                  textColor: Colors.black,
                                  fontSize: 16.0);
                              return;
                            }
                            setState(() {
                              globals.playingSongTitle = songData.songName;
                              globals.playingSongIconURL = songData.albumArtUrl;
                              globals.selectedSong = songData;
                              globals
                                  .playAudio<Map<String, Map<String, dynamic>>>(
                                      songData.audioUrl,
                                      songData.songId,
                                      globals.favTitles, (val) {
                                if (val) {
                                  setState(() {});
                                }
                              });
                            });
                          },
                        );
                      }
                    },
                  );
                },
              ),
              ///////////////////////////
              IndexedStack(
                index: selectedTab,
                alignment: Alignment.topCenter,
                children: [
                  // ✅ قائمة الأغاني المفضلة كما هي
                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref('AllFavourites')
                        .child(uid.toString())
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          songsList.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.snapshot.value == null) {
                        return const Center(
                            child: Text(
                          'No data available',
                          style: TextStyle(color: Colors.white),
                        ));
                      }
                      final data = snapshot.data!.snapshot.value
                          as Map<dynamic, dynamic>;
                      songsList = data.values
                          .map((item) =>
                              SongModel.fromMap(item as Map<dynamic, dynamic>))
                          .toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: songsList.length,
                        itemBuilder: (context, index) {
                          final songData = songsList[index];
                          return SongTileWidget(
                            songData: songData,
                            audioPlayer: _audioPlayer,
                            playSong: () {
                              globals.PlayingalbumArtUrl = songData.albumArtUrl;
                              globals.PlayingsongName = songData.songName;
                              globals
                                  .playAudio<Map<String, Map<String, dynamic>>>(
                                      songData.audioUrl,
                                      songData.songId,
                                      globals.favTitles, (val) {
                                if (val) {
                                  setState(() {});
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  ),

                  // ✅ عرض قوائم التشغيل الخاصة بالمستخدم

                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance
                        .ref("playlists")
                        .orderByChild("userId")
                        .equalTo(userId)
                        .onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final rawData = snapshot.data?.snapshot.value;

                      if (rawData == null) {
                        return const Center(
                          child: Text(
                            'No data available',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      if (rawData is! Map) {
                        return const Center(
                          child: Text(
                            'Unexpected data format',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final data = rawData as Map<dynamic, dynamic>;

                      final localPlaylists = data.values
                          .map((item) {
                            try {
                              return Map<String, dynamic>.from(item as Map);
                            } catch (e) {
                              return <String,
                                  dynamic>{}; // تفادي الكراش لو البيانات غير متوقعة
                            }
                          })
                          .where((map) => map.isNotEmpty)
                          .toList();

                      if (localPlaylists.isEmpty) {
                        return const Center(
                          child: Text(
                            'No valid playlists found',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: localPlaylists.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: Colors.white),
                        itemBuilder: (context, index) {
                          final playlist = localPlaylists[index];
                          final imageUrl = playlist["imageCover"] ?? "";
                          final name = playlist["name"] ?? "No Name";

                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                                imageUrl: imageUrl,
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.music_note),
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(
                                        strokeWidth: 2),
                              ),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Get.to(() => PlayList(), arguments: playlist)
                                  ?.then((refresh) {
                                if (refresh == true) {
                                  fetchPlaylists();
                                }
                              });
                            },
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        // BannerAdWidget(addId: 'ca-app-pub-4005202226815050/2958457365'),

        PlayerControlsWidget<Map<String, Map<String, dynamic>>>(
          songsList: globals.favTitles,
          positionDataStream: _positionDataStream,
          audioPlayer: _audioPlayer,
          isPlaying: _audioPlayer.playing,
          audioPlayerChange: (val) {
            setState(() {});
          },
        )
      ],
    ));
  }
}

class TabWidget extends StatelessWidget {
  String title;
  String value;
  bool isSelected;
  VoidCallback onTap;
  TabWidget({
    super.key,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? yellowColor : Colors.transparent,
          border:
              Border.all(color: isSelected ? Colors.transparent : Colors.white),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: isSelected ? Colors.black : Colors.white),
          ),
        ),
      ),
    );
  }
}
