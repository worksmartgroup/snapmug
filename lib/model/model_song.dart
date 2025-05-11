class SongModel {
  final String songName;
  final String instagramLink;
  final String facebookLink;
  final bool fireIconVisibility;
  final String producerName;
  final String tikTokLink;
  final String yearOfProduction;
  final String youtubeLink;
  final bool dollarIconVisibility;
  final String recordLabel;
  final String audioUrl;
  final String albumArtUrl;
  final String artistName;
  final String instagramUshes;
  final String writer;
  final String facebookUshes;
  final String youtubeUshes;
  final String songId;
  final String userId;
  final String tikTokUshes;
  final String localPath;
  final String artistImage;
  final String fbPrice;
  final String igPrice;
  final String ttPrice;
  final String youtubePrice;

  SongModel(
      {required this.songName,
      required this.userId,
      required this.artistImage,
      required this.instagramLink,
      required this.facebookLink,
      required this.fireIconVisibility,
      required this.producerName,
      required this.tikTokLink,
      required this.yearOfProduction,
      required this.youtubeLink,
      required this.dollarIconVisibility,
      required this.recordLabel,
      required this.audioUrl,
      required this.facebookUshes,
      required this.albumArtUrl,
      required this.artistName,
      required this.writer,
      required this.instagramUshes,
      required this.youtubeUshes,
      required this.tikTokUshes,
      required this.songId,
      required this.localPath,
      required this.fbPrice,
      required this.igPrice,
      required this.ttPrice,
      required this.youtubePrice});

  factory SongModel.fromMap(Map<dynamic, dynamic> map) {
    print("666666666666666666666666666666666666666");
    print(map);
    return SongModel(
        userId: map['userId'] ?? '',
        songName: map['songName'] ?? '',
        artistImage: map['artistImage'] ?? '',
        instagramLink: map['instagramLink'] ?? '',
        facebookLink: map['facebookLink'] ?? '',
        fireIconVisibility: map['fireIconVisiblity'] ?? false,
        producerName: map['producerName'] ?? '',
        tikTokLink: map['tikTokLink'] ?? '',
        yearOfProduction: map['yearOfProduction'] ?? '',
        youtubeLink: map['youtubeLink'] ?? '',
        dollarIconVisibility: map['dollorIconVisiblity'] ?? false,
        recordLabel: map['recordLabel'] ?? '',
        facebookUshes: map['facebookUshes'] ?? '',
        audioUrl: map['audioUrl'] ?? '',
        albumArtUrl: map['albumArtUrl'] ?? '',
        artistName: map['artistName'] ?? '',
        writer: map['writer'] ?? '',
        songId: map['songId'] ?? '',
        tikTokUshes: map['tikTokUshes'] ?? '',
        instagramUshes: map['instagramUshes'] ?? '',
        youtubeUshes: map['youtubeUshes'] ?? '',
        localPath: map["local_path"] ?? '',
        fbPrice: map['fbPrice'] ?? '0.0',
        igPrice: map['igPrice'] ?? '0.0',
        ttPrice: map['ttPrice'] ?? '0.0',
        youtubePrice: map['youtubePrice'] ?? '0.0');
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'songName': songName,
      'artistImage': artistImage,
      'instagramLink': instagramLink,
      'facebookLink': facebookLink,
      'fireIconVisiblity': fireIconVisibility,
      'producerName': producerName,
      'tikTokLink': tikTokLink,
      'yearOfProduction': yearOfProduction,
      'youtubeLink': youtubeLink,
      'dollorIconVisiblity': dollarIconVisibility,
      'recordLabel': recordLabel,
      'facebookUshes': facebookUshes,
      'audioUrl': audioUrl,
      'albumArtUrl': albumArtUrl,
      'artistName': artistName,
      'writer': writer,
      'songId': songId,
      'tikTokUshes': tikTokUshes,
      'instagramUshes': instagramUshes,
      'youtubeUshes': youtubeUshes,
    };
  }
}
