// import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:snapmug/core/class/colors.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/globals.dart';
import 'package:snapmug/pages/BottomNav/Home.dart' as home;
import 'package:snapmug/pages/BottomNav/Home.dart' hide PositionData;
import 'package:snapmug/play_conytoller_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'BottomNav/Home.dart' as home;
import 'add_widget.dart';

class TrackDetail extends StatefulWidget {
  final String artistName;
  final String albumArtUrl;
  final String audioUrl;
  final bool dollorIconVisiblity;
  final String fBPlatform;
  final String tikPlatform;
  final String youPlatform;
  final String iGPlatform;
  final String facebookLink;
  final String facebookUshes;
  final bool fireIconVisiblity;
  String instagramLink;
  final String instagramUshes;
  final String producerName;
  final String recordLabel;
  final String songId;
  final String songName;
  String tikTokLink;
  final String tikTokUshes;
  final String writer;
  final String yearOfProduction;
  String youtubeLink;
  final String youtubeUshes;

  TrackDetail({
    required this.artistName,
    required this.albumArtUrl,
    required this.audioUrl,
    required this.fBPlatform,
    required this.tikPlatform,
    required this.youPlatform,
    required this.iGPlatform,
    required this.dollorIconVisiblity,
    this.facebookLink = '',
    required this.facebookUshes,
    required this.fireIconVisiblity,
    this.instagramLink = '',
    required this.instagramUshes,
    required this.producerName,
    required this.recordLabel,
    required this.songId,
    required this.songName,
    this.tikTokLink = '',
    required this.tikTokUshes,
    required this.writer,
    required this.yearOfProduction,
    this.youtubeLink = '',
    required this.youtubeUshes,
    super.key,
  });

  @override
  State<TrackDetail> createState() => _TrackDetailsScreenState();
}

num amount = 0;

class _TrackDetailsScreenState extends State<TrackDetail> {
  String profileImageURL = '';

  @override
  void initState() {
    super.initState();
    Future(() async {
      isFavorite = await isFavourite(widget.songId);
      // setState(() {
      //   widget.facebookLink = userProfileData?.facebook ?? '';
      //   widget.instagramLink = userProfileData?.instagram ?? '';
      //   widget.tikTokLink = userProfileData?.tikTok ?? '';
      //   widget.youtubeLink = userProfileData?.youTube ?? '';
      // });
      debugPrint('facebook link is ${widget.facebookLink}');
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  bool isFavorite = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  AudioPlayer audioPlayer = AudioPlayer();
  Stream<PositionData> get _positionDataStream =>
      rxdart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF141118),
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Track Details',
          style: TextStyle(
            color: home.yellowColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: home.yellowColor,
          ),
          onPressed: () {
            // Navigate back
            Navigator.of(context).pop();
          },
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.favorite,
        //       color: isFavorite ? Colors.red : Colors.white,
        //     ),
        //     onPressed: () {
        //       if (isFavorite) {
        //         removeFavourite(widget.songId);
        //       } else {
        //         _storeSonginFavourite();
        //       }
        //       setState(() {
        //         isFavorite = !isFavorite;
        //       });
        //     },
        //   ),
        // ],
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Card(
              color: Colors.black,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Container(
                margin: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Album art and play/pause button
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: widget.albumArtUrl,
                              fit: BoxFit.cover,
                              height: 150,
                              width: 150,
                              placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => Image.network(
                                  'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
                            )),
                        const SizedBox(width: 50),
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: yellowColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              if (widget.audioUrl == '') {
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
                              if (audioPlayer.playing) {
                                audioPlayer.stop();
                                setState(() {});
                                return;
                              } else if (audioPlayer.position.inSeconds > 0) {
                                audioPlayer.play();
                                setState(() {});
                                return;
                              }
                              globals
                                  .playAudio<Map<String, Map<String, dynamic>>>(
                                      widget.audioUrl,
                                      widget.songId,
                                      globals.songTitles, (val) {
                                if (val) {
                                  setState(() {});
                                }
                              });
                              setState(() {
                                audioPlayer = globals.player;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(
                                //     audioPlayer.playing
                                //         ? Icons.pause_rounded
                                //         : Icons.play_arrow_rounded,
                                //     color: Colors.black),
                                Text(
                                  audioPlayer.playing ? 'PAUSE' : 'PLAY',
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.songName,
                            style: TextStyle(
                              fontSize: 10,
                              color: yellowColor,
                            ),
                          ),
                          Text(
                            widget.artistName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Media controls
                    StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return SeekBar(
                          activeColor: AppColors.yellowColor,
                          thumbColor: AppColors.yellowColor,
                          showTimes: false,
                          duration: positionData?.duration ?? Duration.zero,
                          position: positionData?.position ?? Duration.zero,
                          bufferedPosition:
                              positionData?.bufferedPosition ?? Duration.zero,
                          onChangeEnd: (duration) {
                            audioPlayer.seek(duration);
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
            ),

            // Music description

            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xff2E2E2E))),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Writer name
                      Row(
                        children: [
                          const Text(
                            'Writer Name:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 10),
                          ),
                          Expanded(
                            child: Text(
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                              widget.writer,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      // Producer name
                      Row(
                        children: [
                          const Text(
                            'Producer Name:',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ),
                          Expanded(
                            child: Text(
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                              widget.producerName,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Record label
                      Row(
                        children: [
                          const Text(
                            'Record Label:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 10),
                          ),
                          Expanded(
                            child: Text(
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10),
                              widget.recordLabel,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),

                      // Year of production
                      Row(
                        children: [
                          const Text(
                            'Year of Production:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 10),
                          ),
                          Expanded(
                            child: Text(
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 10),
                              widget.yearOfProduction,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Media links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              amount = num.parse(widget.iGPlatform);
                              _launchUrl(widget.instagramLink, "instagram");
                            },
                            child: Column(
                              children: [
                                // SizedBox(
                                //   height: 5,
                                // ),
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: yellowColor)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(7),
                                    child: Image.asset(
                                      'assets/instagram.png',
                                      width: 35,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "${widget.iGPlatform} USD",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                // Text(
                                //   'Instagram',
                                //   style: TextStyle(color: Colors.white,fontSize: 10),
                                // ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              amount = num.parse(widget.youPlatform);

                              _launchUrl(widget.youtubeLink, "youtube");
                            },
                            child: Column(
                              children: [
                                Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: yellowColor)),
                                    child: Padding(
                                        padding: const EdgeInsets.all(7),
                                        child: Image.asset(
                                          'assets/social-3434840_1280.png',
                                          width: 35,
                                        ))),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${widget.youPlatform} USD',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              amount = num.parse(widget.tikPlatform);

                              _launchUrl(widget.tikTokLink, "tiktok");
                            },
                            child: Column(
                              children: [
                                Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: yellowColor)),
                                    child: Padding(
                                        padding: const EdgeInsets.all(7),
                                        child: Image.asset(
                                          'assets/tiktok.png',
                                          width: 35,
                                        ))),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${widget.tikPlatform} USD',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              amount = num.parse(widget.fBPlatform);

                              _launchUrl(widget.facebookLink, "facebook");
                            },
                            child: Column(
                              children: [
                                Container(
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '${widget.fBPlatform} USD',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          //
                          // Instagram link
                          // Expanded(
                          //   child: ElevatedButton(
                          //     style: ElevatedButton.styleFrom(
                          //       foregroundColor: Colors.white,
                          //       backgroundColor: Colors.black,
                          //       elevation: 0,
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(20),
                          //       ),
                          //     ),
                          //     onPressed: () {
                          //       // Open Instagram link
                          //     },
                          //     child: Text('Instagram'),
                          //   ),
                          // ),
                          // Other links
                          // ...
                        ],
                      ),
                    ],
                  ),
                )),
            const Spacer(),
            BannerAdWidget(addId: 'ca-app-pub-4005202226815050/2958457365'),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
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
      'artistName': widget.artistName,
      'albumArtUrl': widget.albumArtUrl,
      'audioUrl': widget.audioUrl,
      'dollorIconVisiblity': widget.dollorIconVisiblity,
      'facebookLink': widget.facebookLink,
      'facebookUshes': widget.facebookUshes,
      'fireIconVisiblity': widget.fireIconVisiblity,
      'instagramLink': widget.instagramLink,
      'instagramUshes': widget.instagramUshes,
      'producerName': widget.producerName,
      'recordLabel': widget.recordLabel,
      'songId': widget.songId,
      'songName': widget.songName,
      'tikTokLink': widget.tikTokLink,
      'tikTokUshes': widget.tikTokUshes,
      'writer': widget.writer,
      'yearOfProduction': widget.yearOfProduction,
      'youtubeLink': widget.youtubeLink,
      'youtubeUshes': widget.youtubeUshes,
    });
  }

  Future<void> removeFavourite(String songId) async {
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
          if (data['songId'] == songId) {
            // Remove the entry from the database
            await ref.child(child.key!).remove();
            print('Favourite removed successfully');
            return;
          }
        }
      }
      print('Favourite not found');
    } catch (e) {
      print('Error removing favourite: $e');
    }
  }

  Future<void> _launchUrl(String urlx, String platform) async {
    final Uri url = Uri.parse(urlx);
    final User? user = _auth.currentUser;
    final String? uid = user?.uid;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    debugPrint(timestamp.toString()); // Output: 1639592424394
    String prifileLink = '';
    const uuid = Uuid();
    final randomChildKey = uuid.v4(); // This generates a version 4 UUID
    String randomID = randomChildKey;

    if (platform == 'tiktok') {
      if (widget.tikTokLink.isEmpty) {
        appToast('$platform URL not Found');
        return;
      }
      prifileLink =
          '${widget.tikTokLink}/sharer/sharer.php?u=${widget.albumArtUrl}';
    } else if (platform == 'instagram') {
      if (widget.instagramLink.isEmpty) {
        appToast('$platform URL not Found');
        return;
      }
      prifileLink =
          '${widget.instagramLink}/sharer/sharer.php?u=${widget.albumArtUrl}';
    } else if (platform == 'facebook') {
      if (widget.facebookLink.isEmpty) {
        appToast('$platform URL not Found');
        return;
      }
      prifileLink =
          '${widget.facebookLink}/sharer/sharer.php?u=${widget.albumArtUrl}';
    } else if (platform == 'youtube') {
      if (widget.youtubeLink.isEmpty) {
        appToast('$platform URL not Found');
        return;
      }
      prifileLink =
          '${widget.youtubeLink}/sharer/sharer.php?u=${widget.albumArtUrl}';
    }
    print('this url to launch ${widget.facebookLink} :::::::::: $prifileLink');
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
      'userId': uid,
      'song_id': widget.songId,
      'song_image': widget.albumArtUrl,
      'song_url': urlx,
      'song_name': widget.songName,
      'artist_name': widget.artistName,
      'exec_time': timestamp,
      'platform': platform,
      'status': 'pending',
      'user_profile_username': prifileLink,
      'amount': amount,
      'id': randomID,
    });

    ref2.set({
      'id': randomID,
      'userId': uid,
      'song_id': widget.songId,
      'song_image': widget.albumArtUrl,
      'song_url': urlx,
      'song_name': widget.songName,
      'artist_name': widget.artistName,
      'exec_time': timestamp,
      'platform': platform,
      'status': 'pending',
      'user_profile_username': prifileLink,
      'amount': amount,
    });
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    } else {
      var id = generateRandomNumber(0, 10000000).toString();
      final noti_ref = _database.ref('AllNotification').child(id);

      noti_ref.set({
        'userId': uid,
        'id': id,
        'userProfilePicture': userProfileData?.profilePicture ?? '',
        'app': 'User',
        'notification':
            '${userProfileData?.name ?? user?.displayName ?? ''} Ceated A new Challenge',
        'artistName': widget.artistName,
        'songName': widget.songName,
        'writer': widget.writer,
        'producerName': widget.producerName,
        'recordLabel': widget.recordLabel,
        'yearOfProduction': widget.yearOfProduction,
        'youtubeLink': widget.youtubeLink,
        'instagramLink': widget.instagramLink,
        'facebookLink': widget.facebookLink,
        'tikTokLink': widget.tikTokLink,
        'albumArtUrl': widget.albumArtUrl,
        'audioUrl': widget.audioUrl,
        'platform': platform,
        'amount': amount,
      });
    }
  }
}

appToast(String platform) {
  Fluttertoast.showToast(
      msg: platform,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
// AllFavourites/SongID/
// AllFavourites/UserID/random/SongID

//Check if song is already favourited or not?
