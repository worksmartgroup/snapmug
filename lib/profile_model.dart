import 'package:get/route_manager.dart';

class UserProfile {
  final String name;
  final String email;
  String earning;
  final String country;
  final String password;
  final String mobileMoneyNumber;
  final String profilePicture;
  final String tikTok;
  final String mobileMoneyName;
  final String mobileNumber;
  final String facebook;
  final String youTube;
  final String instagram;
  final String userId;
  final String userName;
  final Map<String, Challenge>
      challenges; // Each challenge is identified by a unique key

  UserProfile({
    required this.name,
    required this.email,
    required this.country,
    required this.earning,
    required this.mobileMoneyNumber,
    required this.profilePicture,
    required this.password,
    required this.tikTok,
    required this.mobileMoneyName,
    required this.mobileNumber,
    required this.facebook,
    required this.youTube,
    required this.instagram,
    required this.userName,
    required this.userId,
    required this.challenges,
  });

  // Factory method to create a UserProfile instance from a map
  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    final challengesMap = map['Challanges'] as Map<dynamic, dynamic>? ?? {};
    final challenges = challengesMap.map((key, value) {
      return MapEntry(
          key as String, Challenge.fromMap(value as Map<dynamic, dynamic>));
    });

    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      earning: map['earning'] ?? '0',
      password: (map['password'] ?? '').toString(),
      userName: map['userName'] ?? 'User Name Here',
      country: map['country'] ?? '',
      mobileMoneyNumber: map['mobileMoneyNumber'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      tikTok: map['tikTok'] ?? '',
      mobileMoneyName: map['mobileMoneyName'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      facebook: map['facebook'] ?? '',
      youTube: map['youTube'] ?? '',
      instagram: map['instagram'] ?? '',
      userId: map['userId'] ?? '',
      challenges: challenges,
    );
  }

  // Method to convert a UserProfile instance to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'country': country,
      'earning': earning,
      'mobileMoneyNumber': mobileMoneyNumber,
      'profilePicture': profilePicture,
      'tikTok': tikTok,
      'mobileMoneyName': mobileMoneyName,
      'mobileNumber': mobileNumber,
      'facebook': facebook,
      'youTube': youTube,
      'instagram': instagram,
      'userId': userId,
      'userName': userName,
      'Challanges':
          challenges.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  updateEarning(String earning) {
    this.earning = earning;
    Get.appUpdate();
  }
}

// updateProfile(){}

class Challenge {
  final String songId;
  final int execTime;
  final String songName;
  final String userProfileUsername;
  final String songUrl;
  final String userId;
  final String platform;
  final String status;

  Challenge({
    required this.songId,
    required this.execTime,
    required this.songName,
    required this.userProfileUsername,
    required this.songUrl,
    required this.userId,
    required this.platform,
    required this.status,
  });

  // Factory method to create a Challenge instance from a map
  factory Challenge.fromMap(Map<dynamic, dynamic> map) {
    return Challenge(
      songId: map['song_id'] ?? '',
      execTime: map['exec_time'] ?? 0,
      songName: map['song_name'] ?? '',
      userProfileUsername: map['user_profile_username'] ?? '',
      songUrl: map['song_url'] ?? '',
      userId: map['userId'] ?? '',
      platform: map['platform'] ?? '',
      status: map['status'] ?? '',
    );
  }

  // Method to convert a Challenge instance to a map
  Map<String, dynamic> toMap() {
    return {
      'song_id': songId,
      'exec_time': execTime,
      'song_name': songName,
      'user_profile_username': userProfileUsername,
      'song_url': songUrl,
      'userId': userId,
      'platform': platform,
      'status': status,
    };
  }
}
