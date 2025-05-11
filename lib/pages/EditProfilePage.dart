import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snapmug/globals.dart';
import 'package:uuid/uuid.dart';

import '../profile_model.dart';
import 'BottomNav/Home.dart';
import 'SignIn.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  FilePickerResult? result;

  String profileImageURL = '';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _tikTokController = TextEditingController();
  final TextEditingController _youTubeController = TextEditingController();
  final TextEditingController _mobileMoneyNameController =
      TextEditingController();
  final TextEditingController _paypalEmailController = TextEditingController();
  final TextEditingController _mobileMoneyNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserProfile();
    // fetchUserDetails();
  }

  UserProfile? profileData;

  bool dateLoading = false;
  bool isLoading = false;
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> getUserProfile() async {
    try {
      setState(() {
        dateLoading = true;
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
        final userProfile = UserProfile.fromMap(data);
        setState(() {
          _nameController.text = userProfile.name;
          _countryController.text = userProfile.country;
          _mobileNumberController.text = userProfile.mobileNumber;
          _instagramController.text = userProfile.instagram;
          _facebookController.text = userProfile.facebook;
          _tikTokController.text = userProfile.tikTok;
          _youTubeController.text = userProfile.youTube;
          _mobileMoneyNameController.text = userProfile.mobileMoneyName;
          _userNameController.text = userProfile.userName;
          _mobileMoneyNumberController.text = userProfile.mobileMoneyNumber;
          _emailController.text = userProfile.email;
          profileImageURL = userProfile.profilePicture;

          debugPrint('email ${_nameController.text}');
        });
      } else {
        debugPrint('No data available for this UID.');
      }
      setState(() {
        dateLoading = false;
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
      setState(() {
        dateLoading = false;
      });
    } catch (error) {
      setState(() {
        dateLoading = false;
      });
      print('Error fetching data: $error');
    }
  }

  Future<void> deleteUserAccount() async {
    debugPrint('deleting account');
    setState(() {
      isLoading = true;
    });
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: userProfileData?.password ??
              '', // Get the user's password securely, not hard-coded
        );
        await user.reauthenticateWithCredential(credential);
        await user.delete();
        debugPrint("User account deleted successfully.");
        setState(() {
          isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInActivity(),
          ),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        debugPrint("Error deleting user account: $e");
      }
    } else {
      debugPrint("No user is currently signed in.");
    }
  }

  bool isEdit = false;
  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _mobileNumberController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _tikTokController.dispose();
    _youTubeController.dispose();
    _mobileMoneyNameController.dispose();
    _mobileMoneyNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      backgroundColor: const Color(0xFF141118),
      appBar: AppBar(
        title:  Text(
          'Edit Profile Info',
          style: TextStyle(
            color: yellowColor,
          ),
        ),
        leading: IconButton(
          icon:  Icon(
            Icons.arrow_back,
            color: yellowColor,
          ),
          onPressed: () {
            Navigator.pop(context);

            // handle back button press
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: dateLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Spacer(flex: 4),
                        Column(
                          children: [
                            updateUsernameAndImage(),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              _emailController.text.trim(),
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.white),
                            ),
                          ],
                        ),
                        const Spacer(flex: 3),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isEdit = !isEdit;
                            });
                          },
                          child: Column(
                            children: [
                              // Icon(Icons.edit, color: yellowColor),
                              Image.asset('assets/edit_prof_icon.png',
                                  height: 16),
                              SizedBox(height: 5),
                              const Text(
                                'Edit',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    _buildProfileField('assets/musician-svgrepo-com.png',
                        'Name', 'Enter your name', _nameController,
                        isEdit: isEdit),
                    const SizedBox(height: 10),
                    _buildProfileField(
                        'assets/worldwide-global-svgrepo-com.png',
                        'Country',
                        'Enter your country',
                        _countryController,
                        isEdit: isEdit,
                        suffixWidget: Padding(
                          padding: const EdgeInsets.all(3),
                          child: GestureDetector(
                              onTap: () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode:
                                      false, // optional. Shows phone code before the country name.
                                  onSelect: (Country country) {
                                    setState(() {
                                      _countryController.text = country.name;
                                    });
                                  },
                                );
                              },
                              child: Image.asset('assets/country_drop.png',
                                  color: isEdit ? yellowColor : Colors.grey)),
                        )),
                    const SizedBox(height: 10),
                    _buildProfileField(
                        'assets/mixer-music-6-svgrepo-com.png',
                        'Mobile Money Name',
                        'Enter your mobile money name',
                        _mobileMoneyNameController,
                        isEdit: isEdit),
                    const SizedBox(height: 10),
                    build2IconProfileField(
                        context,
                        'assets/mtn-mobile-logo-icon.png',
                        'assets/PinClipart.com_clip-art-2010_1162739.png',
                        'Mobile Money Number',
                        'Enter your mobile money number',
                        _mobileMoneyNumberController,
                        isEdit: isEdit),
                    const SizedBox(height: 10),
                    _buildProfileField(
                        'assets/paypal-784404_1280.png',
                        'PayPal Email',
                        'Enter PayPal Email',
                        _paypalEmailController,
                        isEdit: isEdit),
                    const SizedBox(height: 10),
                    _buildProfileField(
                        'assets/instagram-3814080_1280.png',
                        'Instagram Link',
                        'Enter your Instagram link',
                        _instagramController,
                        isEdit: isEdit),
                    const SizedBox(height: 10),
                    _buildProfileField(
                        'assets/facebook-1924510_1280.png',
                        'Facebook Link',
                        'Enter your Facebook link',
                        _facebookController,
                        isEdit: isEdit),
                    const SizedBox(height: 10),
                    _buildProfileField(
                        'assets/tiktok-6338429_1280.png',
                        'TikTok Link',
                        'Enter your TikTok link',
                        _tikTokController,
                        isEdit: isEdit),
                    const SizedBox(height: 10),
                    _buildProfileField(
                        'assets/social-3434840_1280.png',
                        'YouTube Link',
                        'Enter your YouTube link',
                        _youTubeController,
                        isEdit: isEdit),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : Row(
                children: [
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      deleteUserAccount();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: yellowColor),
                          borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Delete Profile',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          const SizedBox(width: 5),
                          Image.asset(
                            'assets/trash.png',
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      if (isEdit) {
                        _uploadFileAndSaveData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: yellowColor),
                          borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          const SizedBox(width: 5),
                          Image.asset(
                            'assets/approval.png',
                            color: isEdit ? yellowColor : Colors.grey,
                            height: 16,
                          )
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: GestureDetector(
                    onTap: () {
                      _signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInActivity(),
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 7, horizontal: 5),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: yellowColor,
                          ),
                          borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Log Out',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                          SizedBox(width: 7),
                          Image.asset(
                            'assets/logout.png',
                            height: 16,
                          ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileField(String imagePath, String label, String hint,
      TextEditingController controller,
      {bool isEdit = false, Widget? suffixWidget}) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: yellowColor),
                borderRadius: BorderRadius.circular(10)),
            child: Image(
              image: AssetImage(imagePath),
              width: 25,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: screenWidth / 2.5,
              height: 30,
              child: TextField(
                controller: controller,
                enabled: isEdit,
                style: const TextStyle(color: Colors.white, fontSize: 10),
                decoration: InputDecoration(
                  suffixIcon: suffixWidget,
                  contentPadding:
                      EdgeInsets.only(bottom: suffixWidget != null ? 9 : 15),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 10),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  disabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintText: hint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget updateUsernameAndImage() {
    final screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox(
          //   width: screenWidth / 2.5,
          //   height: 30,
          //   child: TextField(
          //     style: const TextStyle(color: Colors.white),
          //     controller: _userNameController,
          //     decoration: InputDecoration(
          //         contentPadding: const EdgeInsets.only(left: 15, top: 10),
          //         border: OutlineInputBorder(
          //           borderSide: const BorderSide(
          //               color: yellowColor), // Set the border color to yellow
          //           borderRadius:
          //               BorderRadius.circular(10.0), // Set the border radius
          //         ),
          //         enabledBorder: OutlineInputBorder(
          //           borderSide: BorderSide(
          //               color: Colors
          //                   .yellow), // Set the border color to yellow for enabled state
          //           borderRadius:
          //               BorderRadius.circular(10.0), // Set the border radius
          //         ),
          //         focusedBorder: OutlineInputBorder(
          //           borderSide: BorderSide(
          //               color: Colors
          //                   .yellow), // Set the border color to yellow for focused state
          //           borderRadius:
          //               BorderRadius.circular(10.0), // Set the border radius
          //         ),
          //         hintText: 'username',
          //         hintStyle: TextStyle(color: Colors.grey)),
          //   ),
          // ),
          GestureDetector(
            onTap: () async {
              result = await FilePicker.platform.pickFiles();
              setState(() {});
            },
            child: Container(
              width: 150,
              height: 150,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(100)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image(
                  width: 150,
                  height: 150,
                  image: profileImageURL.isEmpty && result == null
                      ? const AssetImage('assets/user.png')
                      : result != null
                          ? FileImage(File(result?.paths.firstOrNull ?? ''))
                          : NetworkImage(profileImageURL)
                              as ImageProvider<Object>,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadFileAndSaveData() async {
    setState(() {
      isLoading = true;
    });
    String profileImageURL = '';
    final User? user = _auth.currentUser;
    final String? uid = user?.uid;
    final ref = _database.ref('AllUsers').child(uid!);
    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result?.files.first.bytes;
        final storageRef = FirebaseStorage.instance.ref();
        final musicRef = storageRef.child('users/$uid');
        final uploadTask = musicRef.putData(fileBytes!);
        uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
          switch (taskSnapshot.state) {
            case TaskState.running:
              final progress = 100.0 *
                  (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
              print("Upload is $progress% complete.");
              break;
            case TaskState.paused:
              print("Upload is paused.");
              break;
            case TaskState.canceled:
              print("Upload was canceled");
              break;
            case TaskState.error:
              // Handle unsuccessful uploads
              break;
            case TaskState.success:
              final downloadUrl = await taskSnapshot.ref.getDownloadURL();
              print("Download URL: $downloadUrl");
              profileImageURL = downloadUrl;
              final name = _nameController.text;
              final country = _countryController.text;
              final mobileNumber = _mobileNumberController.text;
              final instagram = _instagramController.text;
              final facebook = _facebookController.text;
              final tikTok = _tikTokController.text;
              final youTube = _youTubeController.text;
              final mobileMoneyName = _mobileMoneyNameController.text;
              final mobileMoneyNumber = _mobileMoneyNumberController.text;
              final userName = _userNameController.text;
              print("profileImageURL: $profileImageURL");
              ref.update({
                'name': name,
                'country': country,
                'mobileNumber': mobileNumber,
                'instagram': instagram,
                'paypalEmail': _paypalEmailController.text.trim(),
                'facebook': facebook,
                'userName': facebook,
                'tikTok': tikTok,
                'youTube': youTube,
                'userName': userName,
                'mobileMoneyName': mobileMoneyName,
                'mobileMoneyNumber': mobileMoneyNumber,
                'profilePicture': profileImageURL,
              });
              // Handle successful uploads
              print("Profile uploaded successfully!");
              break;
          }
        });
      } else {
        File file = File(result!.files.single.path!);
        final storageRef = FirebaseStorage.instance.ref();
        final musicRef = storageRef.child('users/$uid');
        final uploadTask = musicRef.putFile(file);
        uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
          switch (taskSnapshot.state) {
            case TaskState.running:
              final progress = 100.0 *
                  (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
              print("Upload is $progress% complete.");
              break;
            case TaskState.paused:
              setState(() {
                isLoading = false;
              });
              print("Upload is paused.");
              break;
            case TaskState.canceled:
              setState(() {
                isLoading = false;
              });
              print("Upload was canceled");
              break;
            case TaskState.error:
              setState(() {
                isLoading = false;
              });
              // Handle unsuccessful uploads
              break;
            case TaskState.success:
              final downloadUrl = await taskSnapshot.ref.getDownloadURL();
              print("Download URL: $downloadUrl");
              profileImageURL = downloadUrl;
              final name = _nameController.text;
              final country = _countryController.text;
              final mobileNumber = _mobileNumberController.text;
              final instagram = _instagramController.text;
              final facebook = _facebookController.text;
              final tikTok = _tikTokController.text;
              final youTube = _youTubeController.text;
              final mobileMoneyName = _mobileMoneyNameController.text;
              final userName = _userNameController.text;
              final mobileMoneyNumber = _mobileMoneyNumberController.text;
              print("profileImageURL: $profileImageURL");
              ref.update({
                'name': name,
                'country': country,
                'mobileNumber': mobileNumber,
                'instagram': instagram,
                'facebook': facebook,
                'tikTok': tikTok,
                'youTube': youTube,
                'userName': userName,
                'mobileMoneyName': mobileMoneyName,
                'mobileMoneyNumber': mobileMoneyNumber,
                'profilePicture': profileImageURL,
              });
              Navigator.of(context).pop();
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                  msg: 'Profile updated successfully!',
                  toastLength: Toast.LENGTH_SHORT,
                  // gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              // print("Music uploaded successfully!");
              break;
          }
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print("No file selected");
    }
  }
}

Widget build2IconProfileField(
    BuildContext context,
    String imagePath,
    String icon2Path,
    String label,
    String hint,
    TextEditingController controller,
    {bool isEdit = false}) {
  final screenSize = MediaQuery.of(context).size;
  final screenWidth = screenSize.width;
  final screenHeight = screenSize.height;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          // Container(
          //   height: 40,
          //   width: 40,
          //   padding: EdgeInsets.all(5),
          //   decoration: BoxDecoration(
          //       border: Border.all(color: yellowColor),
          //       borderRadius: BorderRadius.circular(10)),
          //   child: Image(
          //     image: AssetImage(iconPath),
          //     width: 25,
          //   ),
          // ),
          Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: yellowColor),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Image.asset(
                    imagePath,
                    width: 12,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Image.asset(
                    icon2Path,
                    width: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          SizedBox(width: 5),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          width: screenWidth / 2.5,
          height: 30,
          child: TextField(
            controller: controller,
            enabled: isEdit,
            style: TextStyle(color: Colors.white, fontSize: 10),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(bottom: 15),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              hintStyle: TextStyle(color: Colors.grey.shade800, fontSize: 10),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.grey,
                ),
              ),
              hintText: hint,
            ),
          ),
        ),
      ),
    ],
  );
}
