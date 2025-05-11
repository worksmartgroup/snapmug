class ArtistModel {
  String country;
  String distributerName;
  String email;
  String facebook;
  String instagram;
  bool isRejected;
  bool isVerified;
  String mobileNumber;
  String name;
  String password;
  String profilePicture;
  String recordLabel;
  String tiktok;
  String userId;
  String userName;
  String youTube;
  List<String> socialSS;

  ArtistModel({
    required this.country,
    required this.distributerName,
    required this.email,
    required this.facebook,
    required this.instagram,
    required this.isRejected,
    required this.isVerified,
    required this.mobileNumber,
    required this.name,
    required this.password,
    required this.profilePicture,
    required this.recordLabel,
    required this.tiktok,
    required this.userId,
    required this.userName,
    required this.youTube,
    required this.socialSS,
  });

  factory ArtistModel.fromMap(Map<dynamic, dynamic> map) {
    print("666666666666666666666666666666666666666");
    print(map);
    return ArtistModel(
      country: map['country'] ?? '',
      distributerName: map['distributerName'] ?? '',
      email: map['email'] ?? '',
      facebook: map['facebook'] ?? '',
      instagram: map['instagram'] ?? '',
      isRejected: map['isRejected'] ?? false,
      isVerified: map['isVerified'] ?? false,
      mobileNumber: map['mobileNumber'] ?? '',
      name: map['name'] ?? '',
      password: map['password'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      recordLabel: map['recordLabel'] ?? '',
      tiktok: map['tiktok'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      youTube: map['youTube'] ?? '',
      socialSS:
          (map['socialSS'] as List?)?.map((x) => x as String).toList() ?? [],
    );
  }
}
