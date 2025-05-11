import 'dart:math';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../globals.dart';
import '../EditProfilePage.dart';
import '../add_widget.dart';
import 'Home.dart';
import 'Hot.dart';

class Withdrawal extends StatefulWidget {
  const Withdrawal({super.key});

  @override
  State<Withdrawal> createState() => _WithdrawalState();
}

class _WithdrawalState extends State<Withdrawal> {
  bool isLoggedin = false;
  List<Map<dynamic, dynamic>> transactionsList = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController mobileMoneyNameController = TextEditingController();
  TextEditingController paypalEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      isLoggedin = false;
    } else {
      isLoggedin = true;
      nameController.text = userProfileData?.name ?? '';
      countryController.text = userProfileData?.country ?? '';
      mobileNumberController.text = userProfileData?.mobileMoneyNumber ?? '';
      mobileMoneyNameController.text = userProfileData?.mobileMoneyName ?? '';
      fetchTransactions();
    }
  }

  Future<void> fetchTransactions() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref('AllUsers')
          .child(userUid)
          .child('Challanges');
      // Query query = ref.orderByChild("uid").equalTo(userUid);

      final snapshot = await ref.get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> transactions =
            snapshot.value as Map<dynamic, dynamic>;
        transactions.forEach((key, value) {
          transactionsList.add(value);
        });
        print('transaction list $transactionsList');
        setState(() {});
      } else {
        print('No transactions found for user: $userUid');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisSize: MainAxisSize.min, // Adjust Column size
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  UserProfileTile(
                      title: 'Name',
                      iconPath: 'assets/musician-svgrepo-com.png',
                      controller: nameController,
                      hintText: 'Name'),
                  // SizedBox(
                  //   height: 10,
                  // ),
                  UserProfileTile(
                      title: 'Country',
                      iconPath: 'assets/worldwide-global-svgrepo-com.png',
                      controller: countryController,
                      hintText: 'Country'),
                  build2IconProfileField(
                    isEdit: true,
                    context,
                    'assets/mtn-mobile-logo-icon.png',
                    'assets/PinClipart.com_clip-art-2010_1162739.png',
                    'Mobile Money Number',
                    'Enter your mobile money number',
                    mobileNumberController,
                  ),
                  // UserProfileTile(
                  //     iconPath:
                  //         'assets/PinClipart.com_clip-art-2010_1162739.png',
                  //     title: 'Enter your mobile money number',
                  //     controller: mobileMoneyNameController,
                  //     hintText: 'Mobile Money Number'),
                  const SizedBox(
                    height: 10,
                  ),
                  UserProfileTile(
                      iconPath: 'assets/mixer-music-6-svgrepo-com.png',
                      title: 'Mobile Money Names',
                      controller: mobileMoneyNameController,
                      hintText: 'Mobile Money'),
                  UserProfileTile(
                      iconPath: 'assets/paypal-784404_1280.png',
                      title: 'PayPal Email',
                      controller: paypalEmailController,
                      hintText: 'email'),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: yellowColor,
                        borderRadius: BorderRadius.circular(40)),
                    width: Get.width,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image(
                            image:
                                AssetImage('assets/noun-withdraw-6556064.png'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: userProfileData?.earning ?? '0',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: ' USD',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ListView.builder(
                itemCount: transactionsList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var transaction = transactionsList[index];
                  return ChallengeTileWidget(data: transaction);
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BannerAdWidget(addId: 'ca-app-pub-4005202226815050/7672562143'),
          GestureDetector(
            onTap: () {
              if (double.parse(userProfileData?.earning ?? '0') > 0) {
                final _database = FirebaseDatabase.instance;
                var id = generateRandomId(10);
                final FirebaseAuth auth = FirebaseAuth.instance;
                final User? user = auth.currentUser;
                final uid = user?.uid;
                final paymentRef =
                    _database.ref('WithdrawalAndPayments').child(id);
                paymentRef.set({
                  'userId': uid,
                  'id': id,
                  'userProfilePicture': userProfileData?.profilePicture ?? '',
                  'app': 'Artist',
                  'notification':
                      '${userProfileData?.name ?? ''}  Requested A Withdraw Of ${userProfileData?.earning ?? '0'} UGX',
                  'songName': '',
                  'albumArtUrl': '',
                  'type': 'withdrawal',
                });
                Fluttertoast.showToast(
                    msg: "Withdrawal request added successfully!",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: yellowColor,
                    textColor: Colors.black,
                    fontSize: 16.0);
              } else {
                Fluttertoast.showToast(
                    msg: "You did not have sufficient amount to Withdraw",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 1,
                    backgroundColor: yellowColor,
                    textColor: Colors.black,
                    fontSize: 16.0);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  color: yellowColor, borderRadius: BorderRadius.circular(100)),
              // width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              // height: 50,
              child: Center(
                child: Image.asset('assets/WITHDRAW.png', height: 17),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendPushNotification(
      String deviceToken, String title, String body) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('sendNotification');

    try {
      final results = await callable.call(<String, dynamic>{
        'token': deviceToken,
        'title': title,
        'body': body,
      });

      if (results.data['success']) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${results.data['error']}');
      }
    } catch (e) {
      print('Error calling function: $e');
    }
  }
}

class UserProfileTile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;
  final String iconPath;

  UserProfileTile({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.title,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                border: Border.all(color: yellowColor),
                borderRadius: BorderRadius.circular(10)),
            child: Image(
              image: AssetImage(iconPath),
              width: 25,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const SizedBox(
            width: 5,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: screenWidth / 2.5,
              height: 30,
              child: TextField(
                controller: controller,
                // enabled: isEdit,
                style: TextStyle(color: Colors.white, fontSize: 10),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(bottom: 15),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  hintStyle:
                      TextStyle(color: Colors.grey.shade800, fontSize: 10),
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
                  hintText: hintText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String generateRandomId(int length) {
  const String characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final Random random = Random();

  return List.generate(length, (index) {
    final int randomIndex = random.nextInt(characters.length);
    return characters[randomIndex];
  }).join();
}
