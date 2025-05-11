import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FavData {
  Map<String, Map<String, dynamic>> favMap = {};

  Future<void> fetchFavouriteFromFirebase() async {
    favMap.clear();

    final String? userId = FirebaseAuth.instance.currentUser!.uid;

    final database =
        FirebaseDatabase.instance.ref().child('AllFavourites').child(userId!);
    print("fetching done");

    // Wait for the database fetching to complete
    final event = await database.once();
    final DataSnapshot snapshot = event.snapshot;
    if (snapshot.value != null) {
      final songMap = snapshot.value as Map<dynamic, dynamic>;
      songMap.forEach((key, value) {
        Map<String, dynamic> songData = {
          'artistName': value['artistName'],
          'albumArtUrl': value['albumArtUrl'],
          'audioUrl': value['audioUrl'],
          'dollorIconVisiblity': value['dollorIconVisiblity'],
          'facebookLink': value['facebookLink'],
          'facebookUshes': value['facebookUshes'],
          'fireIconVisiblity': value['fireIconVisiblity'],
          'instagramLink': value['instagramLink'],
          'instagramUshes': value['instagramUshes'],
          'producerName': value['producerName'],
          'recordLabel': value['recordLabel'],
          'songId': value['songId'],
          'songName': value['songName'],
          'tikTokLink': value['tikTokLink'],
          'tikTokUshes': value['tikTokUshes'],
          'writer': value['writer'],
          'yearOfProduction': value['yearOfProduction'],
          'youtubeLink': value['youtubeLink'],
          'youtubeUshes': value['youtubeUshes'],
          'local_path': value['local_path'] ?? '',
        };
        favMap[key] = songData;
      });

      print("feeding done");
    } else {
      print("No data found in the 'AllMusic' node");
    }
  }
}
