import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/pages/TrackDetail.dart';

import 'BottomNav/Home.dart';

class Favouritesongs extends StatefulWidget {
  const Favouritesongs({super.key});

  @override
  State<Favouritesongs> createState() => _FavouritesongsState();
}

class _FavouritesongsState extends State<Favouritesongs> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  List<String> favouriteSongIds = [];
  @override
  void initState() {
    super.initState();
    fetchFavouriteSongs();
  }

  Future<void> fetchFavouriteSongs() async {
    await globals.fetchFavouriteFromFirebase();
    setState(() {
      favouriteSongIds = globals.favTitles.keys.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF141118),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Favourite Songs',
            style: TextStyle(color: yellowColor),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: yellowColor,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 8,
              child: Container(
                color: Color(0xFF141118),
                child: ListView.separated(
                  itemCount: globals.favTitles.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Color(0xFF141118)),
                  itemBuilder: (context, index) {
                    final songKey = globals.favTitles.keys.elementAt(index);
                    final songData = globals.favTitles[songKey]!;
                    return ListTile(
                      leading: SizedBox(
                        width: 55,
                        height: 55,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              // Image
                              CachedNetworkImage(
                                imageUrl:
                                    'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500',
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              // Dollar Icon
                              if (songData['dollorIconVisiblity'] == "Visible")
                                Positioned(
                                  left: -5,
                                  top: -4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(
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
                        globals.trackLoading = true;
                        globals.playAudio(songData['audioUrl'],
                            songData['songId'], globals.favTitles, (val) {
                          if (val) {
                            setState(() {});
                          }
                        });
                        globals.playingSongIconURL = songData['albumArtUrl'];
                        print(globals.playingSongIconURL);
                        setState(() {
                          globals.playingSongTitle = songData['songName'];
                        });
                      },

                      title: Text(songData['songName'],
                          style: TextStyle(
                              color: yellowColor)), // Display song name
                      subtitle: Text(songData['artistName'],
                          style: TextStyle(
                              color: Colors.grey[400])), // Display artist name
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (songData['fireIconVisiblity'] ==
                              "Visible") // Check if fire icon should be visible
                            Icon(Icons.local_fire_department_rounded,
                                color: yellowColor), // Display fire icon
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              print('${songData['songName']} is clicked');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackDetail(
                                    fBPlatform: songData['fbPrice'],
                                    iGPlatform: songData['igPrice'],
                                    tikPlatform: songData['ttPrice'],
                                    youPlatform: songData['youtubePrice'],
                                    artistName: songData['artistName'],
                                    albumArtUrl: songData['albumArtUrl'],
                                    audioUrl: songData['audioUrl'],
                                    dollorIconVisiblity: songData[
                                        'dollorIconVisiblity'], // Convert string to bool
                                    facebookLink: songData['facebookLink'],
                                    facebookUshes: songData['facebookUshes'],
                                    fireIconVisiblity: songData[
                                        'fireIconVisiblity'], // Convert string to bool
                                    instagramLink: songData['instagramLink'],
                                    instagramUshes: songData['instagramUshes'],
                                    producerName: songData['producerName'],
                                    recordLabel: songData['recordLabel'],
                                    songId: songData['songId'],
                                    songName: songData['songName'],
                                    tikTokLink: songData['tikTokLink'],
                                    tikTokUshes: songData['tikTokUshes'],
                                    writer: songData['writer'],
                                    yearOfProduction:
                                        songData['yearOfProduction'],
                                    youtubeLink: songData['youtubeLink'],
                                    youtubeUshes: songData['youtubeUshes'],
                                  ),
                                ),
                              );
                            },
                            child: Icon(Icons.more_vert, color: yellowColor),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ));
  }
}
