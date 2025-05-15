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
import 'package:snapmug/core/class/colors.dart';
import 'package:snapmug/core/func/send_challenge.dart';
import 'package:snapmug/data/challenges/challenges_fire.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/pages/TrackDetail.dart';
import 'package:snapmug/pages/artist_page.dart';
import 'package:snapmug/play_conytoller_widget.dart';

import '../add_widget.dart';
import 'Home.dart';

class HotBottomNav extends StatefulWidget {
  const HotBottomNav({super.key});

  @override
  State<HotBottomNav> createState() => _HotBottomNavState();
}

class _HotBottomNavState extends State<HotBottomNav> {
  bool isLoggedin = false;
  @override
  void initState() {
    print('in hot');
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      isLoggedin = false;
    } else {
      isLoggedin = true;
    }
    globals.filterHotSongs();
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

  List<SongModel> songsList = [];
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    final String uid = user!.uid;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BannerAdWidget(addId: 'ca-app-pub-4005202226815050/2958457365'),
        Expanded(
          child: StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance.ref('AllMusic').onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  songsList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.white)));
              } else if (!snapshot.hasData ||
                  snapshot.data!.snapshot.value == null) {
                return const Center(
                    child: Text('No data available',
                        style: TextStyle(color: Colors.white)));
              }
              // Process data from snapshot
              final data =
                  snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              songsList = data.values
                  .where((test) => (test['fireIconVisiblity'] ?? false) == true)
                  .map((item) =>
                      SongModel.fromMap(item as Map<dynamic, dynamic>))
                  .toList();
              if (songsList.isEmpty) {
                return const Center(
                    child: Text('No data available',
                        style: TextStyle(color: Colors.white)));
              }

              return Container(
                child: ListView.separated(
                  itemCount: songsList.isEmpty ? 0 : songsList.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 0, // or a very small value like 1
                    color: Color(0xFF141118),
                  ),
                  itemBuilder: (context, index) {
                    if (songsList.isEmpty) {
                      return const Center(
                          child: Text(
                        'No songs found',
                        style: TextStyle(color: Colors.white),
                      ));
                    } else {
                      // final songKey = hotSongs.keys.elementAt(index);
                      final SongModel songData = songsList[index];
                      return SongTileWidget(
                        songData: songData,
                        audioPlayer: _audioPlayer,
                        playSong: () {
                          debugPrint('playing the song ');
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
                            globals.PlayingalbumArtUrl = songData.albumArtUrl;
                            globals.PlayingsongName = songData.songName;
                            globals.playingSongTitle = songData.songName;
                            globals.playingSongIconURL = songData.albumArtUrl;
                            globals.isPlaying = true;
                            globals.selectedSong = songData;
                            globals
                                .playAudio<Map<String, Map<String, dynamic>>>(
                                    songData.audioUrl,
                                    songData.songId,
                                    globals.hotSongs, (val) {
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
              );
            },
          ),
        ),
        PlayerControlsWidget<Map<String, Map<String, dynamic>>>(
          songsList: globals.hotSongs,
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

class SongTileWidget extends StatefulWidget {
  SongModel? songData;
  VoidCallback playSong;
  AudioPlayer audioPlayer;
  final bool isOpenPage;
  SongTileWidget(
      {super.key,
      required this.songData,
      required this.playSong,
      required this.audioPlayer,
      this.isOpenPage = false});

  @override
  State<SongTileWidget> createState() => _SongTileWidgetState();
}

class _SongTileWidgetState extends State<SongTileWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.songData == null
        ? const SizedBox.shrink()
        : ListTile(
            leading: SizedBox(
              width: 55,
              height: 55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    // Image
                    CachedNetworkImage(
                      imageUrl: widget.songData?.albumArtUrl ??
                          'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500',
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Image.network(
                          'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
                    ),
                    //   if (widget.songData?.dollarIconVisibility ?? false)
                    //     Positioned(
                    //       left: -5,
                    //       top: -4,
                    //       child: Container(
                    //         decoration: const BoxDecoration(
                    //           color: Colors.black,
                    //           shape: BoxShape.circle,
                    //         ),
                    //         padding: const EdgeInsets.all(
                    //             6.0), // Adjust the padding as needed
                    //         child: Icon(
                    //           Icons.attach_money_rounded,
                    //           color: yellowColor,
                    //           size: 12,
                    //         ),
                    //       ),
                    //     ),
                  ],
                ),
              ),
            ),
            onTap: () {
              widget.playSong();
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  globals.isPlaying = true;
                });
              });
            },

            title: Text(widget.songData?.songName ?? '',
                style: const TextStyle(
                    color: Colors.white, fontSize: 10)), // Display song name
            subtitle: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (!widget.isOpenPage) {
                      Get.to(ArtistPage(),
                          arguments: widget.songData?.userId ?? '');
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(widget.songData?.artistName ?? '',
                        style: TextStyle(color: yellowColor, fontSize: 10)),
                  ),
                ),
              ],
            ), // Display artist name
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.songData?.fireIconVisibility ??
                    false) // Check if fire icon should be visible
                  Image.asset(
                    'assets/fire_icon.png',
                    height: 18,
                  ), // Display fire icon
                const SizedBox(
                  width: 10,
                ),
                if (widget.songData?.fireIconVisibility ?? false)
                  GestureDetector(
                    onTap: () {
                      // print('${songData['songName']} is clicked');
                      widget.audioPlayer.pause();
                      widget.audioPlayer.stop();
                      GoogleAdds.createInterstitialAd(
                          'ca-app-pub-4005202226815050/8794072129');
                      print("888888888888888888888888888888888888888");
                      print(widget.songData?.igPrice);
                      print(widget.songData?.fbPrice);
                      print(widget.songData?.ttPrice);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackDetail(
                            iGPlatform: widget.songData!.igPrice,
                            fBPlatform: widget.songData!.fbPrice,
                            tikPlatform: widget.songData!.ttPrice,
                            youPlatform: widget.songData!.youtubePrice,

                            artistName: widget.songData?.artistName ?? '',

                            albumArtUrl: widget.songData?.albumArtUrl ?? '',
                            audioUrl: widget.songData?.audioUrl ?? '',
                            dollorIconVisiblity:
                                widget.songData?.dollarIconVisibility ??
                                    false, // Convert string to bool
                            facebookLink: widget.songData?.facebookLink ?? '',
                            facebookUshes: widget.songData?.facebookUshes ?? '',
                            fireIconVisiblity:
                                widget.songData?.fireIconVisibility ??
                                    false, // Convert string to bool
                            instagramLink: widget.songData?.instagramLink ?? '',
                            instagramUshes:
                                widget.songData?.instagramUshes ?? '',
                            producerName: widget.songData?.producerName ?? '',
                            recordLabel: widget.songData?.recordLabel ?? '',
                            songId: widget.songData?.songId ?? '',
                            songName: widget.songData?.songName ?? '',
                            tikTokLink: widget.songData?.tikTokLink ?? '',
                            tikTokUshes: widget.songData?.tikTokUshes ?? '',
                            writer: widget.songData?.writer ?? '',
                            yearOfProduction:
                                widget.songData?.yearOfProduction ?? '',
                            youtubeLink: widget.songData?.youtubeLink ?? '',
                            youtubeUshes: widget.songData?.youtubeUshes ?? '',
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.attach_money_rounded,
                        color: AppColors.yellowColor),
                  ),
              ],
            ),
          );
  }
}

class ChallengeTileWidget extends StatefulWidget {
  Map<dynamic, dynamic> data;

  ChallengeTileWidget({
    super.key,
    required this.data,
  });

  @override
  State<ChallengeTileWidget> createState() => _ChallengeTileWidgetState();
}

class _ChallengeTileWidgetState extends State<ChallengeTileWidget> {
  TextEditingController linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            height: 55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  // Image
                  CachedNetworkImage(
                    imageUrl: widget.data['song_image'] ??
                        'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500',
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Image.network(
                        'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
                  ),
                  if (widget.data?['dollarIconVisibility'] ?? false)
                    Positioned(
                      left: -5,
                      top: -4,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(
                            6.0), // Adjust the padding as needed
                        child: Icon(
                          Icons.attach_money_rounded,
                          color: yellowColor,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.data?['song_name'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
                const SizedBox(height: 5),
                Text(widget.data?['artist_name'] ?? '',
                    style: TextStyle(color: yellowColor, fontSize: 10)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  // launchUrl(
                  //     Uri.parse(globals.selectedSong?.instagramLink ?? ''));
                  showAW(context, linkController, () {
                    if (linkController.text.isNotEmpty) {
                      ChallengesFire().requestChallenge(
                        amount: widget.data["amount"],
                        id: widget.data["id"],
                        linkSongCreated: linkController.text,
                      );
                      Get.back();
                      linkController.clear();
                      setState(() {});
                      Get.appUpdate();
                    }
                    Get.back();
                  }, (_) {
                    linkController.clear();
                    setState(() {});
                  });
                },
                child: Container(
                  height: 30,
                  width: 30,
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
              ),
              SizedBox(width: 5),
              GestureDetector(
                  onTap: () {
                    // launchUrl(
                    //     Uri.parse(globals.selectedSong?.youtubeLink ?? ''));
                    showAW(context, linkController, () {
                      if (linkController.text.isNotEmpty) {
                        ChallengesFire().requestChallenge(
                          amount: widget.data["amount"],
                          id: widget.data["id"],
                          linkSongCreated: linkController.text,
                        );
                        Get.back();
                        linkController.clear();
                        setState(() {});
                      }
                      Get.back();
                    }, (_) {
                      linkController.clear();
                      setState(() {});
                    });
                  },
                  child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: yellowColor)),
                      child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Image.asset(
                            'assets/social-3434840_1280.png',
                            width: 35,
                          )))),
              SizedBox(width: 5),
              GestureDetector(
                  onTap: () {
                    showAW(context, linkController, () {
                      if (linkController.text.isNotEmpty) {
                        ChallengesFire().requestChallenge(
                          amount: widget.data["amount"],
                          id: widget.data["id"],
                          linkSongCreated: linkController.text,
                        );
                        Get.back();
                        linkController.clear();
                        setState(() {});
                      }
                      Get.back();
                    }, (_) {
                      linkController.clear();
                      setState(() {});
                    });

                    // launchUrl(
                    //     Uri.parse(globals.selectedSong?.tikTokLink ?? ''));
                  },
                  child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: yellowColor)),
                      child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Image.asset(
                            'assets/tiktok.png',
                            width: 35,
                          )))),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  showAW(context, linkController, () {
                    if (linkController.text.isNotEmpty) {
                      ChallengesFire().requestChallenge(
                        amount: widget.data["amount"],
                        id: widget.data["id"],
                        linkSongCreated: linkController.text,
                      );
                      Get.back();
                      linkController.clear();
                      setState(() {});
                    }
                    Get.back();
                  }, (_) {
                    linkController.clear();
                    setState(() {});
                  });

                  // launchUrl(
                  //     Uri.parse(globals.selectedSong?.facebookLink ?? ''));
                },
                child: Container(
                    height: 30,
                    width: 30,
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
            ],
          )
        ],
      ),
    );
    // ListTile(
    //   leading: SizedBox(
    //     width: 55,
    //     height: 55,
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(15),
    //       child: Stack(
    //         children: [
    //           // Image
    //           CachedNetworkImage(
    //             imageUrl: widget.data['song_image'] ??
    //                 'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500',
    //             fit: BoxFit.cover,
    //             height: 100,
    //             width: 100,
    //             placeholder: (context, url) =>
    //                 const Center(child: CircularProgressIndicator()),
    //             errorWidget: (context, url, error) => Image.network(
    //                 'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
    //           ),
    //           if (widget.data?['dollarIconVisibility'] ?? false)
    //             Positioned(
    //               left: -5,
    //               top: -4,
    //               child: Container(
    //                 decoration: const BoxDecoration(
    //                   color: Colors.black,
    //                   shape: BoxShape.circle,
    //                 ),
    //                 padding: const EdgeInsets.all(
    //                     6.0), // Adjust the padding as needed
    //                 child: const Icon(
    //                   Icons.attach_money_rounded,
    //                   color: yellowColor,
    //                   size: 12,
    //                 ),
    //               ),
    //             ),
    //         ],
    //       ),
    //     ),
    //   ),
    //   onTap: () {},
    //
    //   title: Text(widget.data?['song_name'] ?? '',
    //       style: const TextStyle(
    //           color: Colors.white, fontSize: 10)), // Display song name
    //   subtitle: Text(widget.data?['artist_name'] ?? '',
    //       style: const TextStyle(
    //           color: yellowColor, fontSize: 10)), // Display artist name
    //   trailing: Row(
    //     mainAxisAlignment: MainAxisAlignment.end,
    //     children: [
    //       GestureDetector(
    //         onTap: () {
    //           // launchUrl(
    //           //     userProfileData?.instagram ?? '', 'instagram');
    //         },
    //         child: Container(
    //           height: 30,
    //           width: 30,
    //           decoration: BoxDecoration(
    //               borderRadius: BorderRadius.circular(5),
    //               border: Border.all(color: yellowColor)),
    //           child: Padding(
    //             padding: const EdgeInsets.all(7),
    //             child: Image.asset(
    //               'assets/instagram.png',
    //               width: 35,
    //             ),
    //           ),
    //         ),
    //       ),
    //       SizedBox(width: 5),
    //       GestureDetector(
    //           onTap: () {
    //             // launchUrl(
    //             //     userProfileData?.youTube ?? '', 'youtube');
    //           },
    //           child: Container(
    //               height: 30,
    //               width: 30,
    //               decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(5),
    //                   border: Border.all(color: yellowColor)),
    //               child: Padding(
    //                   padding: const EdgeInsets.all(7),
    //                   child: Image.asset(
    //                     'assets/social-3434840_1280.png',
    //                     width: 35,
    //                   )))),
    //       SizedBox(width: 5),
    //       GestureDetector(
    //           onTap: () {
    //             // launchUrl(userProfileData?.tikTok ?? '', 'tiktok');
    //           },
    //           child: Container(
    //               height: 30,
    //               width: 30,
    //               decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(5),
    //                   border: Border.all(color: yellowColor)),
    //               child: Padding(
    //                   padding: const EdgeInsets.all(7),
    //                   child: Image.asset(
    //                     'assets/tiktok.png',
    //                     width: 35,
    //                   )))),
    //       const SizedBox(width: 5),
    //       GestureDetector(
    //         onTap: () {
    //           // launchUrl(userProfileData?.facebook ?? '', 'facebook');
    //         },
    //         child: Container(
    //             height: 30,
    //             width: 30,
    //             decoration: BoxDecoration(
    //                 borderRadius: BorderRadius.circular(5),
    //                 border: Border.all(color: yellowColor)),
    //             child: Padding(
    //                 padding: const EdgeInsets.all(7),
    //                 child: Image.asset(
    //                   'assets/facebook.png',
    //                   width: 35,
    //                 ))),
    //       ),
    //     ],
    //   ),
    // );
  }
}
