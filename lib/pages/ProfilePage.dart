import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snapmug/pages/EditProfilePage.dart';
import 'package:snapmug/pages/FavouriteSongs.dart';
import 'package:snapmug/pages/SignIn.dart';

import '../profile_model.dart';
import 'BottomNav/Home.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _userName = 'User Name Here';
  String _email = 'Email Here';
  String _phone = 'Phone No Here';
  String _country = 'Country Here';
  String _profilePictureUrl = "";

  @override
  void initState() {
    getUserProfile();
    super.initState();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  UserProfile? profileData;

  bool isLoading = false;
  Future<void> getUserProfile() async {
    try {
      setState(() {
        isLoading = true;
      });
      User? user = FirebaseAuth.instance.currentUser;

      final DatabaseReference databaseRef = FirebaseDatabase.instance
          .ref()
          .child('AllUsers')
          .child(user?.uid ?? '');
      // Retrieve the data

      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        // Map data to UserProfile model
        final userProfile = UserProfile.fromMap(data);
        setState(() {
          profileData = userProfile;
        });
      } else {
        debugPrint('No data available for this UID.');
      }
      setState(() {
        isLoading = false;
      });
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(
          msg: e.message ?? '',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: yellowColor,
          textColor: Colors.black,
          fontSize: 16.0);
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $error');
    }
  }

  // Future<void> fetchUserData() async {
  //   // final googleSignIn = GoogleSignIn();
  //
  //   // final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
  //
  //   // final profilePictureUrl = googleAccount?.photoUrl;
  //   // print(profilePictureUrl.toString());
  //   // _profilePictureUrl = profilePictureUrl.toString();
  //   _profilePictureUrl =
  //       "https://ymw.edu.in/wp-content/uploads/2022/02/dummy-profile-01.png";
  //   final database = FirebaseDatabase.instance;
  //   final reference = database.reference().child('AllUsers');
  //
  //   final snapshot = await reference.get();
  //
  //   if (snapshot.exists) {
  //     for (var childSnapshot in snapshot.children) {
  //       final userId = childSnapshot.key;
  //       final userData =
  //           childSnapshot.value as Map<dynamic, dynamic>; // Cast to Map
  //       setState(() {
  //         _userName =
  //             userData['name'] ?? ''; // Set default if name doesn't exist
  //         _email =
  //             userData['email'] ?? ''; // Set default if email doesn't exist
  //       });
  //       print('User ID: $userId');
  //       print('User Data: $userData');
  //     }
  //   } else {
  //     print('No data found in AllUsers node');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFF141118),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:  Text(
          'My Account',
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
              // Add your settings button functionality here
            },
            color: yellowColor,
          ),
        ],
      ),
      body: isLoading
          ?  Center(
              child: CircularProgressIndicator(
                backgroundColor: yellowColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // SizedBox(height: 20),
                  SizedBox(height: 20),
                  Card(
                    // color: Color(0xFF252116),
                    color: Colors.black,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xFF4e4b53), width: 1.0),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    NetworkImage(_profilePictureUrl),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                profileData?.userName ?? _userName,
                                style:  TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: yellowColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          buildInfoRow(
                              context, 'Name', profileData?.name ?? ''),
                          Divider(
                            thickness: 0.5,
                            color: Colors.grey[800],
                          ),
                          buildInfoRow(
                              context, 'Email', profileData?.email ?? ''),
                          Divider(
                            thickness: 0.5,
                            color: Colors.grey[800],
                          ),
                          buildInfoRow(context, 'Phone',
                              profileData?.mobileMoneyNumber ?? ''),
                          Divider(
                            thickness: 0.5,
                            color: Colors.grey[800],
                          ),
                          buildInfoRow(
                              context, 'Country', profileData?.country ?? ''),
                          Divider(
                            thickness: 0.5,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _signOut();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignInActivity(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Log Out Account',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: yellowColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 10),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Note: By \'Deleting your Account\', you will lose all your info, progress, earnings and personalized settings. We will not be able to recover any such information in any case once your account is deleted permanently. This option enables you an option to delete your account and all associated info stored or collected by us, we will not be responsible for any loss of data.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  deleteUserAccount();
                                },
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Permanently Delete Account',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: yellowColor,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }




  Future<void> deleteUserAccount() async {
    setState(() {
      isLoading=true;
    });
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      try {
        await user.delete();
        debugPrint("User account deleted successfully.");
        setState(() {
          isLoading=false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInActivity(),
          ),
        );
      } catch (e) {
        setState(() {
          isLoading=false;
        });
        debugPrint("Error deleting user account: $e");
      }
    } else {
      debugPrint("No user is currently signed in.");
    }
  }

  Widget buildInfoRow(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
