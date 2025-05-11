import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/pages/BottomNav/Home.dart';
import 'package:snapmug/play_conytoller_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'BottomNav/Home.dart' as home;
import 'TrackDetail.dart';
import 'add_widget.dart';

class MusicPlayerScreen<T> extends StatefulWidget {
  SongModel songData;
  T allSongs;

  MusicPlayerScreen(
      {super.key, required this.songData, required this.allSongs});

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  bool isLoaded = false;
  String loadedURL = '';
  late Timer timer;

  @override
  void initState() {
    Future(() {
      // GoogleAdds.createInterstitialAd(GoogleAdds.mainPlayerAdId);
      debugPrint('playing the song ');
      globals.trackLoading = true;
      if ((globals.selectedSong?.audioUrl ?? '').isEmpty) {
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
        globals.playingSongTitle = globals.selectedSong?.songName ?? '';
        globals.playingSongIconURL = globals.selectedSong?.albumArtUrl ?? '';
      });
    });
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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> launchUrl(String urlx, String platform) async {
    if (urlx.isEmpty) {
      appToast("$platform url not found");
      return;
    }
    final Uri url = Uri.parse(urlx);
    final User? user = _auth.currentUser;
    final String? uid = user?.uid;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    debugPrint(timestamp.toString()); // Output: 1639592424394
    String prifileLink = '';

    final uuid = Uuid();
    final randomChildKey = uuid.v4(); // This generates a version 4 UUID
    String randomID = randomChildKey;

    if (platform == 'tiktok') {
      prifileLink = globals.selectedSong?.albumArtUrl ?? '';
      //  '${userProfileData?.tikTok ?? ''}/sharer/sharer.php?u=${globals.selectedSong?.albumArtUrl ?? ''}';
    } else if (platform == 'instagram') {
      prifileLink = globals.selectedSong?.instagramLink ?? '';
      //    '${userProfileData?.instagram ?? ''}/sharer/sharer.php?u=${globals.selectedSong?.albumArtUrl ?? ''}';
    } else if (platform == 'facebook') {
      prifileLink = globals.selectedSong?.albumArtUrl ?? '';
      //   '${userProfileData?.facebook ?? ''}/sharer/sharer.php?u=${globals.selectedSong?.albumArtUrl ?? ''}';
    } else if (platform == 'youtube') {
      prifileLink = globals.selectedSong?.albumArtUrl ?? '';
      // '${userProfileData?.youTube ?? ''}/sharer/sharer.php?u=${globals.selectedSong?.albumArtUrl ?? ''}';
    }
    print('this url to launch :::::::::: $prifileLink');
    if (prifileLink.isEmpty || prifileLink == '') {
      Fluttertoast.showToast(
          msg: "$platform URL not Found",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    final ref = _database
        .ref('AllUsers')
        .child(uid!)
        .child('Challanges')
        .child(randomID);

    final ref2 = _database.ref('AllChallanges').child(randomID);
    ref.set({
      'id': randomID,
      'userId': uid,
      'song_id': widget.songData.songId,
      'song_image': widget.songData.albumArtUrl,
      'song_url': urlx,
      'song_name': widget.songData.songName,
      'artist_name': widget.songData.artistName,
      'exec_time': timestamp,
      'platform': platform,
      'status': 'pending',
      'user_profile_username': prifileLink
    });

    ref2.set({
      'id': randomID,
      'userId': uid,
      'song_id': widget.songData.songId,
      'song_image': widget.songData.albumArtUrl,
      'song_url': urlx,
      'song_name': widget.songData.songName,
      'artist_name': widget.songData.artistName,
      'exec_time': timestamp,
      'platform': platform,
      'status': 'pending',
      'user_profile_username': prifileLink
    });
    if (!await canLaunchUrl(url)) {
      throw Exception('Could not launch $url');
    } else {
      await launch(prifileLink);
    }
  }

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF141118),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Padding(
            padding:
                const EdgeInsets.only(left: 00.0), // Add 10 pixels of space
            child: SizedBox(
              width: 80,
              child: Image.asset('assets/app_logo_snap_mug_no_bg_cropped.png'),
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: home.yellowColor),
            onPressed: () {
              Navigator.of(context).pop();
              // handle back button press
            },
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: globals.selectedSong?.albumArtUrl ?? '',
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.width / 1.2,
                        width: MediaQuery.of(context).size.width,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
                      ),
                      isLoaded
                          ? const SizedBox.shrink()
                          : SizedBox(
                              height: MediaQuery.of(context).size.width / 1.2,
                              width: MediaQuery.of(context).size.width,
                              child: NativedAdWidget(
                                  addId: GoogleAdds.trackDetailsNativeAdId))
                    ],
                  )),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    launchUrl(
                        globals.selectedSong?.instagramLink ?? '', 'instagram');

                    //    launchUrl(userProfileData?.instagram ?? '', 'instagram');
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: home.yellowColor)),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(
                        'assets/instagram.png',
                        width: 35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                    onTap: () {
                      launchUrl(
                          globals.selectedSong?.youtubeLink ?? '', 'youtube');
                    },
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: home.yellowColor)),
                        child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Image.asset(
                              'assets/social-3434840_1280.png',
                              width: 35,
                            )))),
                const SizedBox(width: 10),
                GestureDetector(
                    onTap: () {
                      launchUrl(
                          globals.selectedSong?.tikTokLink ?? '', 'tiktok');
                    },
                    child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: home.yellowColor)),
                        child: Padding(
                            padding: const EdgeInsets.all(7),
                            child: Image.asset(
                              'assets/tiktok.png',
                              width: 35,
                            )))),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    launchUrl(
                        globals.selectedSong?.facebookLink ?? '', 'facebook');
                  },
                  child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: yellowColor)),
                      child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Image.asset(
                            'assets/facebook.png',
                            width: 35,
                          ))),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            PlayerControlsWidget(
              songsList: widget.allSongs,
              positionDataStream: _positionDataStream,
              audioPlayer: _audioPlayer,
              isFullAudioScreen: true,
              isPlaying: _audioPlayer.playing,
              audioPlayerChange: (val) {
                globals.player = val;
                setState(() {
                  isLoaded = true;
                });
                Future.delayed(const Duration(seconds: 3), () {
                  setState(() {
                    isLoaded = false;
                  });
                });

                print('state is changed');
              },
            ),
          ],
        ));
  }
}
