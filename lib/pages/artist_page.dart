import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:snapmug/core/class/colors.dart';
import 'package:snapmug/data/artist/get_artist.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/pages/BottomNav/Hot.dart';
import 'package:snapmug/pages/add_widget.dart';
import 'package:snapmug/play_conytoller_widget.dart';
import 'package:snapmug/widget/artist/images_widget.dart';

class ArtistPage extends StatefulWidget {
  const ArtistPage({super.key});

  @override
  State<ArtistPage> createState() => _ArtistPageState();
}

class _ArtistPageState extends State<ArtistPage> {
  String artistId = "";
  GetArtistControllerImpl getArtistController =
      Get.put(GetArtistControllerImpl());

  @override
  void initState() {
    super.initState();
    artistId = Get.arguments;
    print("++++++++++++++++++++++++++++++++++++==========");
    print("Artist ID: $artistId");
    getArtistController.getArtist(artistId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: GetBuilder<GetArtistControllerImpl>(
          builder: (controller) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (controller.model == null) {
              return const Center(
                child: Text(
                  "No artist data found",
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              final artist = controller.model!;
              return SafeArea(
                child: Column(
                  children: [
                    ImagesWidget(artist: artist),
                    Padding(
                      padding: EdgeInsets.only(
                        left: Get.width * 0.05,
                      ),
                      child: Text(artist.name,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.yellowColor,
                        ),
                        Text(artist.country,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ],
                    ),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    SizedBox(
                      height: Get.height * 0.2,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(
                              controller.songModel.length,
                              (index) => SongTileWidget(
                                isOpenPage: true,
                                songData: controller.songModel[index],
                                playSong: () async {
                                  try {
                                    debugPrint(
                                        'Attempting to play song: ${controller.songModel[index].songName}');

                                    // 2. التحقق من وجود رابط الصوت
                                    if (controller
                                        .songModel[index].audioUrl.isEmpty) {
                                      debugPrint(
                                          'No audio URL for song: ${controller.songModel[index].songId}');
                                      Fluttertoast.showToast(
                                        msg: "Song URL is missing",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        backgroundColor: AppColors.yellowColor,
                                        textColor: Colors.black,
                                      );
                                      return;
                                    }

                                    // 3. تحديث الحالة قبل التشغيل
                                    if (mounted) {
                                      setState(() {
                                        globals.PlayingalbumArtUrl = controller
                                            .songModel[index].albumArtUrl;
                                        globals.PlayingsongName = controller
                                            .songModel[index].songName;
                                        globals.playingSongTitle = controller
                                            .songModel[index].songName;
                                        globals.selectedSong =
                                            controller.songModel[index];
                                        globals.playingSongIconURL = controller
                                            .songModel[index].albumArtUrl;
                                        globals.trackLoading = true;
                                      });
                                    }

                                    // 4. تشغيل الصوت مع معالجة الأخطاء
                                    final success = await globals.playAudio<
                                        Map<String, Map<String, dynamic>>>(
                                      controller.songModel[index].audioUrl,
                                      controller.songModel[index].songId,
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
                                audioPlayer: _audioPlayer,

                                //   audioPlayer: audioPlayer
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BannerAdWidget(
                            addId: 'ca-app-pub-4005202226815050/2958457365',
                          ),
                          PlayerControlsWidget(
                            songsList: controller.songModel,
                            positionDataStream: _positionDataStream,
                            audioPlayer: _audioPlayer,
                            isPlaying: _audioPlayer.playing,
                            audioPlayerChange: (val) {
                              print('value changed $val');
                              // Update logic here if needed, as _audioPlayer is a getter and cannot be assigned
                              debugPrint(
                                  'AudioPlayer instance cannot be directly updated.');
                              print('PLAYER STATE CHENAGES $val');
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ));
  }
}
