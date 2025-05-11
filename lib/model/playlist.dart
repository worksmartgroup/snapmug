class PlaylistModel {
  final String playlistName;
  final String imageCover;
  PlaylistModel({
    required this.playlistName,
    required this.imageCover,
  });

  factory PlaylistModel.fromMap(Map<dynamic, dynamic> map) {
    return PlaylistModel(
      playlistName: map['name'] ?? '',
      imageCover: map['imageCover'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': playlistName,
      'imageCover': imageCover,
    };
  }
}
