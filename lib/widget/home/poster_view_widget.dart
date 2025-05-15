import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/globals.dart';
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/pages/BottomNav/Home.dart' as AppColors;
import 'package:snapmug/pages/artist_page.dart';
import 'package:snapmug/widget/home/dot_custom.dart';

class PosterViewWidget extends StatefulWidget {
  final Map<String, Map<String, dynamic>> allSongsList;

  const PosterViewWidget({
    super.key,
    required this.allSongsList,
  });

  @override
  State<PosterViewWidget> createState() => _PosterViewWidgetState();
}

int i = 0;
SongModel songData = SongModel(
  fbPrice: "0.0",
  igPrice: '0.0',
  ttPrice: '0.0',
  youtubePrice: '0.0',
  songId: '',
  songName: '',
  albumArtUrl: '',
  audioUrl: '',
  artistImage: '',
  userId: '',
  instagramLink: '',
  facebookLink: '',
  fireIconVisibility: false,
  producerName: '',
  tikTokLink: '',
  yearOfProduction: '',
  youtubeLink: '',
  dollarIconVisibility: false,
  recordLabel: '',
  facebookUshes: "0",
  artistName: '',
  writer: '',
  instagramUshes: "0",
  youtubeUshes: "0",
  tikTokUshes: "",
  localPath: '',
);

class _PosterViewWidgetState extends State<PosterViewWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.17,
      child: Column(
        children: [
          songTitles.isNotEmpty
              ? Container(
                  height: Get.height * 0.13,
                  width: Get.width * 0.9,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 2, color: Colors.white),
                  ),
                  child: Stack(
                    children: [
                      PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 4,
                          onPageChanged: (value) {
                            i = value;
                            print(i);
                            setState(() {});
                          },
                          itemBuilder: (context, index) {
                            if (widget.allSongsList.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No songs found',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else {
                              final songKey =
                                  widget.allSongsList.keys.elementAt(index);
                              songData = SongModel.fromMap(
                                widget.allSongsList[songKey]!,
                              );
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  onTap: () async {
                                    //   widget.playSong();

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
                                          backgroundColor:
                                              AppColors.yellowColor,
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
                                          //   globals.PlayingaudioUrl = songDataa.audioUrl;
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
                                          debugPrint(
                                              'Song started successfully');
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

                                        Fluttertoast.showToast(
                                          msg: "Playback error occurred",
                                          toastLength: Toast.LENGTH_SHORT,
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    }
                                    ;

                                    Future.delayed(const Duration(seconds: 3),
                                        () {
                                      setState(() {
                                        globals.isPlaying = true;
                                      });
                                    });
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: songData.albumArtUrl,
                                    fit: BoxFit.cover,
                                    height: Get.height * 0.2,
                                    width: Get.width,
                                    placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Image.network(
                                            'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
                                  ),
                                ),
                              );
                            }
                          }),
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                            onTap: () {
                              Get.to(ArtistPage(), arguments: songData.userId);
                            },
                            child: Container(
                                height: Get.height * 0.05,
                                width: Get.width * 0.1,
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: AppColors.yellowColor,
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: BorderRadius.circular(40)),
                                child: Icon(Icons.arrow_outward_rounded))),
                      )
                    ],
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 20,
            width: 100,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 7),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => CustomDot(
                isSelected: i == index ? true : false,
              ),
            ),
          )
        ],
      ),
    );
  }
}
