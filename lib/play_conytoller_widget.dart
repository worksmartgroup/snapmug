import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:snapmug/core/class/colors.dart';
import 'package:snapmug/core/enum/loop_songs.dart';
import 'package:snapmug/data/playlist/playlist.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/globals.dart';
import 'package:snapmug/pages/BottomNav/Home.dart';
import 'package:snapmug/pages/FullScreenAudio.dart';
import 'package:snapmug/widget/get_playlist.dart';

class PlayerControlsWidget<T> extends StatefulWidget {
  Future<void> Function()? ontapRemoveSongFromPlaylist;
  Stream<PositionData> positionDataStream;
  AudioPlayer audioPlayer;
  bool isFullAudioScreen;
  final T songsList;
  bool isPlaying;
  bool isPlaylistWidget;
  Function(AudioPlayer)? audioPlayerChange;
  PlayerControlsWidget({
    super.key,
    required this.songsList,
    this.ontapRemoveSongFromPlaylist,
    required this.positionDataStream,
    this.isFullAudioScreen = false,
    required this.audioPlayer,
    required this.isPlaying,
    this.audioPlayerChange,
    this.isPlaylistWidget = false,
  });

  @override
  State<PlayerControlsWidget> createState() => _PlayerControlsWidgetState();
}

class _PlayerControlsWidgetState<T> extends State<PlayerControlsWidget> {
  TextEditingController controller = TextEditingController();
  bool isSelected = false;
  bool isNewPlayList = false;
  int indexPlayList = -1;
  final List<Map<String, dynamic>> playlists = [];
  SongLoop songLoop = SongLoop.repeatAll;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    super.initState();
    // if (T == List<SongModel>) {
    //   songsList = <SongModel>[] as T;
    // } else {
    //   songsList = <String, Map<String, dynamic>>{} as T;
    // }
    _setupPlayerListeners();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   globals.player.dispose();
  // }

  @override
  void didUpdateWidget(PlayerControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.audioPlayer != widget.audioPlayer) {
      debugPrint('AudioPlayer instance changed - resetting listeners');

      // 1. إلغاء المستمعات القديمة بشكل صحيح
      _disposePlayerListeners();

      try {
        _setupPlayerListeners();
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        debugPrint('Error updating player listeners: $e');
        if (mounted) {
          setState(() => globals.isPlaying = false);
        }
      }
    }
  }

  Future<void> _disposePlayerListeners() async {
    try {
      await _playerStateSubscription?.cancel();
      _playerStateSubscription = null;
    } catch (e) {
      debugPrint('Error disposing player listeners: $e');
    }
  }

  Future<void> _setupPlayerListeners() async {
    await _playerStateSubscription?.cancel();

    _playerStateSubscription = widget.audioPlayer.playerStateStream.listen(
      (playerState) async {
        if (playerState.processingState == ProcessingState.completed) {
          debugPrint('Current loop mode: ${widget.audioPlayer.loopMode}');

          try {
            await Future.delayed(const Duration(milliseconds: 100));

            if (!mounted) return;
            _handlePlaybackCompletion();
          } catch (e) {
            debugPrint('Error handling completed state: $e');
            if (mounted) {
              setState(() => globals.isPlaying = false);
            }
          }
        }

        // أضف هذا الجزء لتحديث الواجهة عند أي تغيير في حالة المشغل
        if (mounted) {
          setState(() {
            globals.isPlaying = playerState.playing;
          });
        }
      },
      onError: (error) {
        debugPrint('Player error: $error');
        if (mounted) setState(() => globals.isPlaying = false);
      },
    );
  }

  Future<void> _handlePlaybackCompletion() async {
    try {
      switch (songLoop) {
        case SongLoop.repeatOne:
          await _handleLoopOne();
          break;
        case SongLoop.repeatAll:
          await _handleLoopAll();
          break;
        case SongLoop.none:
          await _handleNoLoop();
          break;
        default:
          await _handleLoopAll();
      }
    } catch (e) {
      debugPrint('Playback completion error: $e');
    }
  }

  Future<void> _handleLoopAll() async {
    try {
      // تشغيل الأغنية التالية مع الانتظار حتى اكتمال العملية
      final success = await globals.playNextSong<T>(widget.songsList, (val) {
        if (mounted && val) {
          setState(() {});
        }
      });

      // تحديث واجهة المستخدم فقط إذا كان الـ widget لا يزال مركباً
      if (mounted) {
        setState(() {
          globals.isPlaying = true;
          globals.playingSongTitle =
              globals.selectedSong?.songName ?? 'بدون عنوان';
          print('========== تم تحديث حالة التشغيل والعنوان');
        });

        // إعلام الواجهة بالتغيير إن وجد
        widget.audioPlayerChange?.call(globals.player);
        print('========== تم إعلام الواجهة بتغيير المشغل');
      }
    } catch (e) {
      // معالجة الأخطاء بشكل مناسب
      debugPrint('حدث خطأ في الوضع التكراري: $e');
      print('========== خطأ: $e');

      if (mounted) {
        setState(() {
          globals.isPlaying = false;
        });
      }
    } finally {
      print('========== انتهت عملية التشغيل التكراري');
    }
  }

  // AudioPlayer get _audioPlayer => globals.player;

  Future<void> _handleLoopOne() async {
    try {
      // 1. إيقاف التشغيل الحالي
      // await globals.player.stop();

      globals.duration = Duration.zero;
      globals.position = Duration.zero;
      globals.isPlaying = false;

      // 2. العودة إلى نقطة البداية (الصفر)
      await globals.player.seek(Duration.zero);

      // 3. بدء التشغيل من البداية
      //   await globals.player.play();
      globals.isPlaying = true;

      // 4. تحديث الواجهة (إذا كنت تستخدم GetX)
      Get.appUpdate();
    } catch (error) {
      print('حدث خطأ أثناء إعادة التشغيل: $error');
      // يمكنك إضافة معالجة إضافية للخطأ هنا
    }
  }

  Future<void> _handleNoLoop() async {
    await player.stop();
    if (mounted) {
      setState(() => globals.isPlaying = false);
    }
  }

  Future<void> fetchPlaylists() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    playlists.addAll(await PlaylistService().getUserPlaylists(userId));
    setState(() {}); // تحديث الواجهة بعد جلب البيانات
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      child: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Get.height * 0.005),
            InkWell(
              onTap: widget.isFullAudioScreen
                  ? null
                  : () {
                      if (widget.audioPlayerChange != null) {
                        widget.audioPlayerChange!(globals.player);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicPlayerScreen(
                            songData: globals.selectedSong!,
                            allSongs: widget.songsList,
                          ),
                        ),
                      );
                    },
              child: Text(
                globals.playingSongTitle,
                style: TextStyle(color: yellowColor, fontSize: 16),
              ),
            ),
            StreamBuilder<PositionData>(
              stream: widget.positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  thumbColor: AppColors.yellowColor,
                  activeColor: AppColors.yellowColor,
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition:
                      positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: (duration) {
                    widget.audioPlayer.seek(duration);
                  },
                );
              },
            ),
            Row(
              spacing: Get.width * 0.05,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    favVersa();
                    setState(() {});
                    // globals.ShuffleStateVersa();
                  },
                  child: globals.isFavorite
                      ? Image(
                          image: const AssetImage('assets/in-love-512.png'),
                          color: yellowColor,
                          width: Get.width * 0.05,
                        )
                      : Image(
                          image: AssetImage('assets/in-love-512.png'),
                          color: Colors.white,
                          width: Get.width * 0.05,
                        ),
                ),
                Container(
                  height: Get.height * 0.03,
                  width: Get.width * 0.06,
                  decoration: BoxDecoration(
                    color:
                        songLoop == SongLoop.none ? Colors.black : yellowColor,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(width: 1, color: Colors.white),
                  ),
                  padding: const EdgeInsets.all(1),
                  child: GestureDetector(
                    onTap: () async {
                      // تحديد وضع التكرار التالي
                      songLoop = _getNextLoopMode(songLoop);

                      // تحديث الحالة وعرض الرسالة
                      _handleLoopModeChange(songLoop);

                      setState(() {});
                    },
                    child: Image.asset(
                      songLoop == SongLoop.repeatOne
                          ? 'assets/repeat_one.png'
                          : 'assets/REPEAT.png',
                      width: Get.width * 0.03,
                      color: songLoop == SongLoop.none
                          ? yellowColor
                          : Colors.white,
                    ) /*globals.isLooped
                        ? const Icon(Icons.loop_rounded,
                            color: Colors.black, size: 25)
                        : const Icon(Icons.loop_rounded,
                            color: yellowColor, size: 25)*/
                    , // Icon(Icons.loop_sharp,
                    //     color: yellowColor, size: 25),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    globals.playPreviousSong<T>(false, widget.songsList, (val) {
                      if (val) {
                        setState(() {});
                      }
                    });
                    globals.isPlaying = true;
                    if (widget.audioPlayerChange != null) {
                      widget.audioPlayerChange!(globals.player);
                    }
                    setState(() {});
                  },
                  child: Container(
                    height: Get.height * 0.04,
                    width: Get.width * 0.07,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 1, color: Colors.white),
                    ),
                    child: Icon(Icons.arrow_left,
                        //  size: Get.height * 0.04,
                        color: Colors.white),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (widget.isPlaying) {
                      globals.player.pause();
                      globals.isPlaying = false;
                    } else {
                      globals.player.play();
                      globals.isPlaying = true;
                    }
                    if (widget.audioPlayerChange != null) {
                      widget.audioPlayerChange!(globals.player);
                    }
                    setState(() {});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: yellowColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          width: 1,
                          color: Colors.white,
                        )),
                    width: Get.width * 0.13,
                    height: Get.height * 0.06,
                    child: Icon(
                      globals.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    print("---------------- ; $T");

                    globals.playNextSong<T>(widget.songsList, (val) {
                      if (val) {
                        setState(() {});
                      }
                    });
                    globals.isPlaying = true;
                    if (widget.audioPlayerChange != null) {
                      widget.audioPlayerChange!(globals.player);
                    }
                    setState(() {});
                  },
                  child: Container(
                    height: Get.height * 0.04,
                    width: Get.width * 0.07,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 1, color: Colors.white),
                    ),
                    child: Icon(Icons.arrow_right,
                        //   size: Get.height * 0.04,
                        color: Colors.white),
                  ),
                ),
                Container(
                  height: Get.height * 0.03,
                  width: Get.width * 0.07,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.white,
                    ),
                    color:
                        globals.isShuffled ? yellowColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.all(7),
                  child: GestureDetector(
                    onTap: () {
                      globals.ShuffleStateVersa();
                      setState(() {});
                    },
                    child: Image.asset(
                      'assets/SHUFLE.png',
                      width: 40,
                      color: globals.isShuffled ? Colors.white : yellowColor,
                    ),

                    // child: globals.isShuffled
                    //     ? const Icon(Icons.shuffle_rounded,
                    //         color: Colors.black, size: 25)
                    //     : const Icon(Icons.shuffle_rounded,
                    //         color: yellowColor, size: 25),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (widget.isPlaylistWidget &&
                        widget.ontapRemoveSongFromPlaylist != null) {
                      await widget
                          .ontapRemoveSongFromPlaylist!(); // استدعاء الدالة بشكل صحيح
                    } else {
                      playlists.clear();
                      isSelected = false;
                      isNewPlayList = false;
                      indexPlayList = -1;

                      setState(() {});
                      await fetchPlaylists();
                      AwesomeDialog(
                        dialogBorderRadius: BorderRadius.circular(20),
                        dialogBackgroundColor: AppColors.primaryColor,
                        context: context,
                        animType: AnimType.scale,
                        dialogType: DialogType.noHeader,
                        btnOkColor: AppColors.yellowColor,
                        buttonsTextStyle: const TextStyle(color: Colors.black),
                        body: StatefulBuilder(
                          builder: (context, dialogSetState) {
                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    isSelected = false;
                                    isNewPlayList = true;
                                    print(isNewPlayList);
                                    dialogSetState(() {});
                                  },
                                  child: isNewPlayList
                                      ? TextFormField(
                                          controller: controller,
                                          textInputAction: TextInputAction.go,
                                          style: TextStyle(
                                            color: Colors
                                                .white, // يمكنك تغيير هذا إلى أي لون تريده
                                            fontSize: 16, // حجم الخط (اختياري)
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Playlist Name',
                                            fillColor: Colors.white,
                                            focusColor: AppColors.yellowColor,
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 2,
                                                  color: AppColors.yellowColor,
                                                )),
                                            // إضافة لون للنص عند وضع العلامة (Placeholder)
                                            hintStyle: TextStyle(
                                              color: Colors
                                                  .grey, // لون النص التوضيحي
                                            ),
                                          ),
                                        )
                                      : Row(
                                          children: [
                                            const Icon(Icons.add,
                                                color: Colors.white),
                                            const Text(
                                              'New Playlist',
                                              style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Choose playlist",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 10),
                                if (playlists.isEmpty)
                                  const Center(
                                    child: Text(
                                      'No Playlists Found',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                else
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: yellowColor, width: 2)),
                                    height: 300,
                                    child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Divider(
                                          indent: 10,
                                          endIndent: 10,
                                          height: 5,
                                        ),
                                      ),
                                      itemCount: playlists.length,
                                      itemBuilder: (context, index) {
                                        return GetPlaylistWidget(
                                          image: playlists[index]["imageCover"],
                                          playlistName: playlists[index]
                                              ['name'],
                                          isSelected: index == indexPlayList,
                                          ontap: () {
                                            dialogSetState(() {
                                              isSelected = true;
                                              indexPlayList = index;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        title: 'This is Ignored',
                        desc: 'This is also Ignored',
                        onDismissCallback: (DismissType type) {
                          isSelected = false;
                          //  isNewPlayList = false;
                          // controller.clear();
                          // indexPlayList = -1;
                          setState(() {});
                        },
                        btnOkOnPress: () async {
                          try {
                            // 1. التحقق من تسجيل الدخول
                            final currentUser =
                                FirebaseAuth.instance.currentUser;
                            if (currentUser == null) {
                              Fluttertoast.showToast(msg: "ً you must sign in");
                              return;
                            }

                            // 2. التحقق من وجود أغنية محددة
                            final selectedSong = globals.selectedSong;
                            if (selectedSong == null ||
                                selectedSong.songId.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "did not select song");
                              return;
                            }

                            // 3. معالجة حالتي الإنشاء والإضافة
                            if (isNewPlayList) {
                              // إنشاء قائمة جديدة
                              final playlistName = controller.text.trim();
                              if (playlistName.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "playlist name is required");
                                return;
                              }

                              final result = await PlaylistService()
                                  .createPlaylist(
                                      currentUser.uid,
                                      playlistName,
                                      [selectedSong.songId],
                                      selectedSong.albumArtUrl);

                              if (result != null) {
                                Fluttertoast.showToast(msg: "Success");
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Error to create playlist");
                              }
                            } else {
                              final playlistId = playlists[indexPlayList]['id'];

                              // إضافة إلى قائمة موجودة
                              // if (isSelected) {
                              //   if (indexPlayList == -1 || playlists.isEmpty) {
                              //     Fluttertoast.showToast(
                              //         msg: "you must select playlist");
                              //     return;
                              //   }

                              //   if (playlistId == null || playlistId.isEmpty) {
                              //     Fluttertoast.showToast(
                              //         msg: "playlist is empty");
                              //     return;
                              //   }
                              // }

                              final success = await PlaylistService()
                                  .addSongToPlaylist(
                                      userId: currentUser.uid,
                                      playlistId: playlistId,
                                      songId: selectedSong.songId,
                                      imageCover: selectedSong.albumArtUrl);

                              if (success) {
                                Fluttertoast.showToast(msg: "Success");
                              } else {
                                Fluttertoast.showToast(msg: "Error");
                              }
                            }

                            // إعادة تعيين الحالة
                            controller.clear();
                            isSelected = false;
                            isNewPlayList = false;
                            indexPlayList = -1;
                            if (mounted) setState(() {});
                          } catch (e) {
                            debugPrint("Error: ${e.toString()}");
                            Fluttertoast.showToast(
                                msg: "حدث خطأ: ${e.toString()}");
                          }
                        },
                      ).show();
                    }
                  },
                  child: widget.isPlaylistWidget
                      ? Icon(Icons.bookmark_remove_sharp, color: Colors.white)
                      : Image(
                          image: AssetImage('assets/plus-5-512.png'),
                          color: yellowColor,
                          width: 20,
                        ),
                  /*: const Image(
                          image: AssetImage('assets/plus-5-512.png'),
                          color: Colors.white,
                          width: 25)*/
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  SongLoop _getNextLoopMode(SongLoop current) {
    switch (current) {
      case SongLoop.repeatAll:
        return SongLoop.repeatOne;
      case SongLoop.repeatOne:
        return SongLoop.none;
      case SongLoop.none:
        return SongLoop.repeatAll;
      default:
        return SongLoop.repeatAll;
    }
  }

  void _handleLoopModeChange(SongLoop newMode) {
    //  globals.isLooped = newMode != LoopMode.off;

    final toastMessage = {
      SongLoop.none: "Repeat off",
      SongLoop.repeatOne: "Repeat current song",
      SongLoop.repeatAll: "Repeat all songs",
    }[newMode]!;

    Fluttertoast.showToast(
      msg: toastMessage,
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: yellowColor,
      textColor: Colors.black,
      fontSize: 16.0,
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);

  PositionData copyWith(
      {Duration? position, Duration? bufferedPosition, Duration? duration}) {
    return PositionData(
      position ?? this.position,
      bufferedPosition ?? this.bufferedPosition,
      duration ?? this.duration,
    );
  }
}

class SeekBar extends StatelessWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final bool showTimes;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final ValueChanged<Duration>? onChangeStart;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const SeekBar({
    Key? key,
    required this.duration,
    this.showTimes = true,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
    this.onChangeStart,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final positionValue = position.inMilliseconds.toDouble();
    final maxValue = duration.inMilliseconds.toDouble();
    final safeMaxValue = maxValue > 0 ? maxValue : 1.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: !showTimes ? 0 : 15,
            right: !showTimes ? 0 : 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showTimes
                  ? Text(
                      _formatDuration(position),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.yellowColor,
                      ),
                    )
                  : const SizedBox.shrink(),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    overlayShape: RoundSliderOverlayShape(
                        overlayRadius: Get.height * 0.02),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                    activeTrackColor: activeColor ?? theme.primaryColor,
                    inactiveTrackColor: inactiveColor ?? Colors.grey[300],
                    thumbColor: thumbColor ?? theme.primaryColor,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: safeMaxValue,
                    value: positionValue.clamp(0.0, safeMaxValue),
                    onChanged: (value) {
                      onChanged?.call(Duration(milliseconds: value.round()));
                    },
                    onChangeStart: (value) {
                      onChangeStart
                          ?.call(Duration(milliseconds: value.round()));
                    },
                    onChangeEnd: (value) {
                      onChangeEnd?.call(Duration(milliseconds: value.round()));
                    },
                  ),
                ),
              ),
              showTimes
                  ? Text(
                      _formatDuration(duration),
                      style:
                          TextStyle(fontSize: 12, color: AppColors.yellowColor),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
