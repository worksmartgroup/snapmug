import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:ffi';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:gif_view/gif_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snapmug/globals.dart' as globals;
import 'package:snapmug/pages/BottomNav/Home.dart';
import 'package:snapmug/pages/BottomNav/Hot.dart';
import 'package:snapmug/pages/BottomNav/Search.dart';
import 'package:snapmug/pages/BottomNav/Songs.dart';
import 'package:snapmug/pages/BottomNav/Withdrawal.dart';
import 'package:snapmug/pages/Notifications.dart';
import 'package:snapmug/pages/SignIn.dart';

import 'EditProfilePage.dart';
import 'add_widget.dart';
// import 'package:snapmug/pages/Home.dart'; // Assuming you have these pages
// import 'package:snapmug/pages/Search.dart';
// import 'package:snapmug/pages/Songs.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isLoggedin = false;
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String profileImageURL = '';

  Future<void> fetchUserDetails() async {
    final User? user = _auth.currentUser;
    print('fetching user details...');
    if (user != null) {
      print('user is not null');
      final String uid = user.uid;
      final database = FirebaseDatabase.instance;
      final reference = database.ref('AllUsers').child(uid);
      final snapshot = await reference.get();

      if (snapshot.exists) {
        final userData = snapshot.value as Map<dynamic, dynamic>;
        print('User Data: $userData');

        if (mounted) {
          setState(() {
            profileImageURL = userData['profilePicture'] ?? '';
          });
        }

        print(profileImageURL);

        print('User Data: $userData');
      } else {
        print('No data available for this user.');
      }
    } else {
      print('User is not signed in.');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && !GoogleAdds.openAppAddLoaded) {
      GoogleAdds.createAppOpenedAd();
    }
    if (state == AppLifecycleState.paused) {
      GoogleAdds.openAppAddLoaded = false;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    if (FirebaseAuth.instance.currentUser == null) {
      print('initstate user is not null');
      profileImageURL = '';
      isLoggedin = false;
    } else {
      print('initstate user is null');
      fetchUserDetails();
      isLoggedin = true;
    }

    if (!globals.isPlaying) {
      Future(() async {
        globals.player.positionStream.listen((position) {
          setState(() {
            globals.position = position;
          });
        });
      });
    }
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {});
    });
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (_selectedIndex == 4) {
      GoogleAdds.createInterstitialAd(GoogleAdds.wallet);
    }
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeBottomNav();
      case 1:
        return const SearchBottomNav();
      case 2:
        return const SongsBottomNav();
      case 3:
        return const HotBottomNav();
      case 4:
        return const Withdrawal();
      default:
        return const HomeBottomNav();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0), // Add 10 pixels of space
          child: Container(
            child: Image.asset('assets/app_logo_snap_mug_no_bg_cropped.png'),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (isLoggedin) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ),
                );
              } else {
                globals.stopAndClearPlayer();
                Fluttertoast.showToast(
                    msg: "You need to login to use this functionality",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInActivity(),
                  ),
                );
              }
              // Add your action here
            },
            child: GifView.asset(
              'assets/notification_icon.gif',
              // height: 200,
              width: 30,
              alignment: Alignment.centerRight,
              fit: BoxFit.cover,
              frameRate: 30, // default is 15 FPS
            ),
          ),
          // IconButton(
          //   icon: const Image(
          //       image: AssetImage('assets/notii.png'),
          //       width: 20,
          //       color: yellowColor),
          //   onPressed: () {
          //     if (isLoggedin) {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => NotificationsPage(),
          //         ),
          //       );
          //     } else {
          //       globals.stopAndClearPlayer();
          //
          //       Fluttertoast.showToast(
          //           msg: "You need to login to use this functionality",
          //           toastLength: Toast.LENGTH_SHORT,
          //           // gravity: ToastGravity.CENTER,
          //           timeInSecForIosWeb: 1,
          //           backgroundColor: Colors.red,
          //           textColor: Colors.white,
          //           fontSize: 16.0);
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => SignInActivity(),
          //         ),
          //       );
          //     }
          //     // Add your action here
          //   },
          // ),
          IconButton(
            icon: Container(
              width: 50, // Adjust the width as needed
              height: 50, // Adjust the height as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: yellowColor, width: 2), // Yellow border
              ),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      profileImageURL,
                      fit: BoxFit.cover,
                      errorBuilder: (context, s, t) {
                        return Image.asset('assets/user.png');
                      },
                    ),
                    // child: ClipOval(
                    // child: Image(
                    // image: NetworkImage(profileImageURL),
                    // AssetImage('assets/musician-svgrepo-com.png'),
                    // width: double.infinity, // Adjust the width as needed
                    // height: double.infinity, // Adjust the height as needed
                    // fit: BoxFit.fill,
                    // ),
                    // ),
                  ),
                  const Positioned(
                    right: 7,
                    top: 6,
                    child: Image(
                      image: AssetImage('assets/settings-25-512.png'),
                      width: 15, // Adjust the width as needed
                      height: 15, // Adjust the height as needed
                    ),
                  ),
                ],
              ),
            ),
            color: yellowColor,
            onPressed: () {
              if (isLoggedin) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(),
                  ),
                );
              } else {
                globals.stopAndClearPlayer();
                Fluttertoast.showToast(
                  msg: "You need to login to use this functionality",
                  toastLength: Toast.LENGTH_SHORT,
                  // gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInActivity(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: SizedBox(
        height: Get.height * 0.09,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 0.0,
                unselectedFontSize: 0.0,
                backgroundColor: yellowColor,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Container(
                      padding:
                          const EdgeInsets.all(4), // تقليل المساحة الداخلية

                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedIndex == 0
                            ? Colors.black26
                            : Colors.transparent,
                      ),
                      child: Image.asset(
                        'assets/noun-menu-4748399.png',
                        //  width: Get.width * 0.08,
                        height: Get.height * 0.03,
                        fit: BoxFit.cover,
                        color: Colors.black,
                      ),
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedIndex == 1
                              ? Colors.black26
                              : Colors.transparent,
                        ),
                        child: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: Get.height * 0.03,
                        )),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: CircleAvatar(
                        backgroundColor: _selectedIndex == 2
                            ? Colors.black26
                            : Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(
                            'assets/noun-multimedia-6419441.png',
                            //   width: Get.width * 0.07,
                            height: Get.height * 0.03,
                            color: Colors.black,
                          ),
                        )),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: CircleAvatar(
                        backgroundColor: _selectedIndex == 3
                            ? Colors.black26
                            : Colors.transparent,
                        child: Image.asset(
                          'assets/noun-fire-6639941.png',
                          //  width: Get.width * 0.07,
                          height: Get.height * 0.03,
                          color: Colors.black,
                        )),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: CircleAvatar(
                        backgroundColor: _selectedIndex == 1
                            ? Colors.black26
                            : Colors.transparent,
                        child: Icon(
                          Icons.home,
                          color: Colors.black,
                          size: Get.height * 0.02,
                        )),
                    label: '',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.amber[800],
                onTap: _onItemTapped,
              ),
            ),
            Positioned(
              right: 0,
              // Get.width * 0.08,
              // bottom: 0,
              top: -10,
              child: GestureDetector(
                onTap: () {
                  _onItemTapped(4);
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(8)),
                  width: Get.width * 0.15,
                  height: Get.height * 0.06,
                  child: Center(
                    child: CircleAvatar(
                        radius: 25,
                        backgroundColor: _selectedIndex == 4
                            ? Colors.black26
                            : Colors.transparent,
                        child: Image.asset(
                          'assets/noun-money-bag-icon-2004052.png',
                          // width: Get.width * 0.07,
                          // height: Get.height * 0.1,
                          color: Colors.black,
                        )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
