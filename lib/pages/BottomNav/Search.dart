import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:just_audio_web/just_audio_web.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/globals.dart';
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/play_conytoller_widget.dart';
import 'package:snapmug/service/search/get_trend.dart';

import 'Home.dart';
import 'Hot.dart';

class SearchBottomNav extends StatefulWidget {
  const SearchBottomNav({super.key});

  @override
  State<SearchBottomNav> createState() => _SearchBottomNavState();
}

class _SearchBottomNavState extends State<SearchBottomNav> {
  final ArtistService _artistService = ArtistService();
  String name = '';
  @override
  void initState() {
    super.initState();

    _loadArtistData();
  }

  void _loadArtistData() {
    _artistService.fetchTopArtistName().then((arName) {
      if (mounted) {
        setState(() {
          name = arName ?? '';
        });
      }
    });
  }

  // Map<String, Map<String, dynamic>> filteredSongs = {};
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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            height: 35,
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: name == "" ? 'Weekend Vibes' : name,

                contentPadding: EdgeInsets.only(top: 10, left: 15),
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image(
                    image: AssetImage(
                      'assets/search-2-512.png',
                    ),
                    color: yellowColor,
                    width: 10,
                  ),
                ),
                fillColor: Colors.white,
                // labelText: 'Search',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Yellow border when not focused
                  borderRadius: BorderRadius.circular(15.0), // Border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // Purple border when focused
                  borderRadius: BorderRadius.circular(15.0), // Border radius
                ),
              ),
              onChanged: (searchQuery) {
                if (searchQuery.isNotEmpty) {
                  globals.filterSongs(searchQuery);
                } else {
                  globals.filteredSongs.clear();
                }
                setState(() {});
              },
            ),
          ),
        ),
        Expanded(
          flex: 65,
          child: Container(
            child: ListView.separated(
              itemCount: globals.filteredSongs.isEmpty ? 0 : 2,
              separatorBuilder: (context, index) => const Divider(
                height: 0,
                color: Color(0xFF141118),
              ),
              itemBuilder: (context, index) {
                if (globals.filteredSongs.isEmpty) {
                  return const Center(
                      child: Text(
                    'No songs found',
                    style: TextStyle(color: Colors.white),
                  ));
                } else {
                  final songKey = globals.filteredSongs.keys.elementAt(index);
                  final songData = SongModel.fromMap(filteredSongs[songKey]!);
                  return SongTileWidget(
                    songData: songData,
                    audioPlayer: _audioPlayer,
                    playSong: () {
                      debugPrint('playing the song ');
                      globals.trackLoading = true;
                      if (songData.audioUrl.isEmpty) {
                        debugPrint('This song has not audio url');
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
                        globals.PlayingalbumArtUrl = songData.albumArtUrl;
                        globals.PlayingsongName = songData.songName;
                        globals.playingSongTitle = songData.songName;
                        globals.playingSongIconURL = songData.albumArtUrl;
                        globals.selectedSong = songData;
                        globals.playAudio<Map<String, Map<String, dynamic>>>(
                            songData.audioUrl,
                            songData.songId,
                            globals.songTitles, (val) {
                          if (val) {
                            setState(() {});
                          }
                        });
                      });
                    },
                  );
                }
              },
            ),
          ),
        ),
        // BannerAdWidget(addId: 'ca-app-pub-4005202226815050/2958457365'),

        PlayerControlsWidget<Map<String, Map<String, dynamic>>>(
          songsList: globals.songTitles,
          positionDataStream: _positionDataStream,
          audioPlayer: _audioPlayer,
          isPlaying: _audioPlayer.playing,
          audioPlayerChange: (val) {
            print('value changed $val');
            // Update logic here if needed, as _audioPlayer is a getter and cannot be assigned
            debugPrint('AudioPlayer instance cannot be directly updated.');
            print('PLAYER STATE CHENAGES $val');
            setState(() {});
          },
        )
      ],
    ));
  }
}
