import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/model/model_song.dart';
import 'package:snapmug/pages/BottomNav/Home.dart';
import 'package:snapmug/widget/home/trend_second/custom_poster.dart';

class TrendSecond extends StatefulWidget {
  final Map<String, Map<String, dynamic>> allSongsList;

  const TrendSecond({super.key, required this.allSongsList});

  @override
  State<TrendSecond> createState() => _TrendSecondState();
}

class _TrendSecondState extends State<TrendSecond> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
            widget.allSongsList.length <= 4 ? widget.allSongsList.length : 4,
            (index) {
          if (widget.allSongsList.isEmpty) {
            return const Center(
              child: Text(
                'No songs found',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final songKey = widget.allSongsList.keys.elementAt(index + 4);
            final songData = SongModel.fromMap(
              widget.allSongsList[songKey]!,
            );

            return Expanded(
              child: InkWell(
                onTap: () async {
                  try {
                    debugPrint('Attempting to play song: ${songData.songName}');

                    // 2. التحقق من وجود رابط الصوت
                    if (songData.audioUrl.isEmpty) {
                      debugPrint('No audio URL for song: ${songData.songId}');
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
                        globals.PlayingalbumArtUrl = songData.albumArtUrl;
                        globals.PlayingsongName = songData.songName;
                        globals.playingSongTitle = songData.songName;
                        globals.selectedSong = songData;
                        globals.playingSongIconURL = songData.albumArtUrl;
                        globals.trackLoading = true;
                      });
                    }

                    // 4. تشغيل الصوت مع معالجة الأخطاء
                    final success = await globals
                        .playAudio<Map<String, Map<String, dynamic>>>(
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

                  Future.delayed(const Duration(seconds: 3), () {
                    setState(() {
                      globals.isPlaying = true;
                    });
                  });
                },
                child: CustomPosterTrendSecond(
                  artistId: songData.userId,
                  imageCover: songData.albumArtUrl,
                  imageArtist: songData.artistImage,
                ),
              ),
            );
          }
        })
      ],
    );
  }
}
