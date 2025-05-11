import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:snapmug/model/artist_model.dart';
import 'package:snapmug/model/model_song.dart';

abstract class GetArtistController extends GetxController {
  getArtist(String artistId);
  getArtistSongs(String artistId);
  bool isLoading = false;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  ArtistModel? model;
  //SongModel? songModel;
  List<SongModel> songModel = [];
}

class GetArtistControllerImpl extends GetArtistController {
  @override
  getArtist(artistId) async {
    try {
      isLoading = true;
      update();
      final snapshot = await _db.child('AllArtists').child(artistId).once();

      final data = snapshot.snapshot;
      if (data.exists) {
        final artistData = data.value as Map<Object?, Object?>;
        print("Artist Data: $artistData ====");

        model = ArtistModel.fromMap(artistData);
        print("Artist Model: ${model?.name}");
        await getArtistSongs(artistId);
        isLoading = false;
        update();
      } else {
        print('No data available for the given artist ID.');
        isLoading = false;
        update();
      }
    } catch (e) {
      print("============ Error : $e");
      isLoading = false;
      update();
    }
  }

  @override
  getArtistSongs(artistId) async {
    try {
      isLoading = true;
      update();
      DatabaseEvent event = await _db
          .child("AllMusic")
          .orderByChild("userId")
          .equalTo(artistId)
          .once();
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.exists) {
        final data = snapshot.value as Map<Object?, Object?>;
        print("Artist Songs Data: $data ====");
        songModel = (data.values as Iterable)
            .map((e) => SongModel.fromMap(e as Map<Object?, Object?>))
            .toList();
        print(
            "Artist Songs Model: ${songModel.map((song) => song.songName).toList()}");
        // isLoading = false;
        // update();
      }
    } catch (e) {
      print("============ Error : $e");
      isLoading = false;
      update();
    }
  }
}
