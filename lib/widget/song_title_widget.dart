import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/pages/BottomNav/Home.dart';
import 'package:snapmug/pages/TrackDetail.dart';
import 'package:snapmug/pages/add_widget.dart';

class SongTileWidget extends StatefulWidget {
  SongModel? songData;
  VoidCallback playSong;
  AudioPlayer audioPlayer;
  SongTileWidget(
      {super.key,
      required this.songData,
      required this.playSong,
      required this.audioPlayer});

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
                    if (widget.songData?.dollarIconVisibility ?? false)
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
            subtitle: Text(widget.songData?.artistName ?? '',
                style: TextStyle(
                    color: yellowColor, fontSize: 10)), // Display artist name
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
                GestureDetector(
                  onTap: () {
                    // print('${songData['songName']} is clicked');
                    widget.audioPlayer.pause();
                    widget.audioPlayer.stop();
                    GoogleAdds.createInterstitialAd(
                        'ca-app-pub-4005202226815050/8794072129');
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
                          instagramUshes: widget.songData?.instagramUshes ?? '',
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
                  child: const Icon(Icons.more_vert, color: Colors.white),
                ),
              ],
            ),
          );
  }
}
