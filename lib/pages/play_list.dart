import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:snapmug/core/class/colors.dart';
import 'package:snapmug/data/playlist/get_songs_playlist.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/pages/BottomNav/Hot.dart';
import 'package:snapmug/play_conytoller_widget.dart';

class PlayList extends StatefulWidget {
  @override
  _PlayListState createState() => _PlayListState();
}

class _PlayListState extends State<PlayList> {
  late String playlistId;
  late String playlistName;
  bool isSelected = false;
  late Map<String, dynamic> playListSelected;
  Map<Object?, Object?> songs = {};
  GetSongsFromPlaylistController getSongsFromPlaylist =
      Get.put(GetSongsFromPlaylistController());
  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    playListSelected = arguments ?? {};
    playlistId = playListSelected["id"];
    playlistName = playListSelected["name"];
    songs = playListSelected["songs"];
    print(playListSelected);
    getSongsFromPlaylist.fetchPlaylistSongs(playlistId);
  }

  // @override
  // void dispose() {
  //   _audioPlayer.dispose(); // تأكد من التخلص من المشغل عند الخروج من الشاشة
  //   super.dispose();
  // }

  AudioPlayer get _audioPlayer => globals.player;

  Stream<PositionData> get _positionDataStream =>
      rxdart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  int i = 0;
  bool isPlayed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Get.height * 0.34),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                                height: Get.height * 0.25,
                                width: Get.width * 0.5,
                                fit: BoxFit.cover,
                                imageUrl: playListSelected["imageCover"]),
                          ),
                          Text(
                            "${songs.length.toString()} SONGS",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 20),
                      child: Text(playlistName,
                          style: TextStyle(
                              color: AppColors.yellowColor, fontSize: 20)),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.yellowColor,
                          size: Get.height * 0.05,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (isPlayed) {
                            if (globals.player.playing) {
                              globals.player.pause();
                            } else {
                              globals.player.play();
                            }
                            setState(() {});
                          } else {
                            try {
                              globals.selectedSong =
                                  getSongsFromPlaylist.songsList[0];
                              globals.PlayingalbumArtUrl =
                                  getSongsFromPlaylist.songsList[0].albumArtUrl;
                              globals.PlayingsongName =
                                  getSongsFromPlaylist.songsList[0].songName;
                              // استخدم globals.player مباشرة بدلاً من _audioPlayer المحلي
                              final success =
                                  await globals.playAudio<List<SongModel>>(
                                getSongsFromPlaylist.songsList[0].audioUrl,
                                getSongsFromPlaylist.songsList[0].songId,
                                getSongsFromPlaylist.songsList,
                                (val) {
                                  if (val) setState(() {});
                                  Get.appUpdate();
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    setState(() {
                                      globals.isPlaying = true;
                                      isPlayed = true;
                                    });
                                  });
                                },
                              );

                              if (mounted && success) {
                                setState(() {
                                  globals.isPlaying = true;
                                });
                              }
                            } catch (e) {
                              debugPrint('Error in playSong: $e');
                            }
                          }
                        },
                        icon: Icon(
                          globals.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill,
                          color: AppColors.yellowColor,
                          size: Get.height * 0.08,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => getSongsFromPlaylist.isLoading.value
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : getSongsFromPlaylist.songsList.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "Your playlist is empty",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    : Expanded(
                        flex: 85,
                        child: SizedBox(
                          child: ListView.separated(
                            itemCount: getSongsFromPlaylist.songsList.isEmpty
                                ? 0
                                : getSongsFromPlaylist.songsList.length,
                            // separatorBuilder: (context, index) =>
                            //     Divider(color: Color(0xFF141118)),
                            separatorBuilder: (context, index) => const Divider(
                              height: 0, // or a very small value like 1
                              color: Color(0xFF141118),
                            ),

                            itemBuilder: (context, index) {
                              i = index;
                              if (!mounted) {
                                setState(() {});
                              }
                              if (getSongsFromPlaylist.songsList.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'No songs found',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              } else {
                                return SongTileWidget(
                                  songData:
                                      getSongsFromPlaylist.songsList[index],
                                  audioPlayer: _audioPlayer,
                                  playSong: () async {
                                    try {
                                      globals.selectedSong =
                                          getSongsFromPlaylist.songsList[index];
                                      globals.PlayingalbumArtUrl =
                                          getSongsFromPlaylist
                                              .songsList[index].albumArtUrl;
                                      globals.PlayingsongName =
                                          getSongsFromPlaylist
                                              .songsList[index].songName;
                                      // استخدم globals.player مباشرة بدلاً من _audioPlayer المحلي
                                      final success = await globals
                                          .playAudio<List<SongModel>>(
                                        getSongsFromPlaylist
                                            .songsList[index].audioUrl,
                                        getSongsFromPlaylist
                                            .songsList[index].songId,
                                        getSongsFromPlaylist.songsList,
                                        (val) {
                                          if (val) setState(() {});
                                          Get.appUpdate();
                                        },
                                      );

                                      if (mounted && success) {
                                        setState(() {
                                          globals.isPlaying = true;
                                        });
                                      }
                                    } catch (e) {
                                      debugPrint('Error in playSong: $e');
                                    }
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
          ),
          // !isSelected
          //     ? SizedBox()
          //     :
          PlayerControlsWidget<List<SongModel>>(
            songsList: getSongsFromPlaylist.songsList,
            positionDataStream: _positionDataStream,
            isPlaylistWidget: true,
            ontapRemoveSongFromPlaylist: () async {
              if (globals.selectedSong != null) {
                await getSongsFromPlaylist.deleteItem(
                  playlistId: playlistId,
                  songId: globals.selectedSong!.songId,
                );
                if (mounted) setState(() {});
              }
            },
            audioPlayer: globals.player,
            isPlaying: globals.player.playing, // استخدم globals.player مباشرة
            audioPlayerChange: (val) {
              print('value changed $val');
              // Update logic here if needed, as _audioPlayer is a getter and cannot be assigned
              debugPrint('AudioPlayer instance cannot be directly updated.');
              print('PLAYER STATE CHENAGES $val');
              setState(() {});
            },
            // audioPlayerChange: (AudioPlayer newPlayer) async {
            //   try {
            //     debugPrint(
            //         'Player instance changed from ${globals.player.hashCode} to ${newPlayer.hashCode}');

            //     // 1. إيقاف المشغل القديم إذا كان يعمل
            //     if (globals.player.playing) {
            //       await globals.player.stop();
            //     }

            //     // 2. تحديث المشغل في globals
            //     globals.player = newPlayer;

            //     // 3. تحديث الحالة المحلية إذا لزم الأمر
            //     if (mounted) {
            //       setState(() {
            //         globals.player = newPlayer;
            //       });
            //     }

            //     debugPrint('New player state: ${newPlayer.playerState}');
            //   } catch (e) {
            //     debugPrint('Error in audioPlayerChange: $e');
            //     if (mounted) {
            //       setState(() => globals.isPlaying = false);
            //     }
            //   }
            // },
          ),
        ],
      ),
    );
  }
}
