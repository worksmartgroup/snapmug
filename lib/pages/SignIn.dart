import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snapmug/pages/SignUp.dart';
import 'package:snapmug/service/log/apple.dart';
import 'package:snapmug/service/log/fb.dart';
import 'package:snapmug/service/log/x_log.dart';

import 'BottomNav/Home.dart';
import 'HomePage.dart'; // Import your HomePage class

class SignInActivity extends StatefulWidget {
  @override
  _SignInActivityState createState() => _SignInActivityState();
}

class _SignInActivityState extends State<SignInActivity> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '534586490308-fpccq491a869l65lk4aq2kpf6gfrm763.apps.googleusercontent.com', // Specify your web client ID for web platform
  );
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String titleUUID = '';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height / 8),
                Image.asset(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  'assets/app_icon.png',
                  fit: BoxFit.cover,
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: yellowColor),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      appTextField(
                          context, 'Email', 'Enter email', _emailController,
                          isLogin: true),
                      appTextField(context, 'Password', 'Enter password',
                          _passwordController,
                          isLogin: true),
                      const SizedBox(height: 20),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                              backgroundColor: yellowColor,
                            ))
                          : SizedBox(
                              height: 35,
                              child: ElevatedButton(
                                onPressed: _signInWithEmailAndPassword,
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(color: yellowColor),
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  // elevation: 20,
                                  minimumSize: const Size(100, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white), // Default text style
                          children: <TextSpan>[
                            const TextSpan(
                                text: 'Don\'t have an account? ',
                                style: TextStyle(color: Colors.white)),
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                  color: yellowColor,
                                  fontWeight: FontWeight.bold),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => SignUPActivity()));
                                },
                            ),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  decoration: BoxDecoration(
                    color: yellowColor,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await signInWithTwitter(context);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 20,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0),
                            child: Image.asset(
                              'assets/x_logo.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _signInWithGoogle,
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 20,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 0),
                            child: Image.asset(
                              'assets/ic_google.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await signInWithFacebook();
                        },
                        child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              // color: Colors.black,
                              border: Border.all(color: Colors.black, width: 4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/fb_logo.png',
                              height: 25,
                            )),
                      ),
                      GestureDetector(
                        onTap: () {
                          signInWithAppleAndNavigate(context);
                        },
                        child: Icon(
                          Icons.apple,
                          color: Colors.black,
                          size: 55,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SizedBox(
                //   height: 35,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(builder: (context) => HomePage()),
                //       );

                //       // Handle button press
                //     },
                //     style: ElevatedButton.styleFrom(
                //       side:  BorderSide(color: yellowColor),
                //       foregroundColor: Colors.white,
                //       backgroundColor: Colors.transparent,
                //       // elevation: 20,
                //       minimumSize: const Size(100, 50),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(35),
                //       ),
                //     ),
                //     child: const Text(
                //       'Skip',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontSize: 16,
                //       ),
                //       textAlign: TextAlign.center,
                //     ),
                //   ),
                // ),

                const SizedBox(height: 60),

                Row(
                  children: [
                    Checkbox(
                      value: termsAccepted,
                      onChanged: (val) {
                        setState(() {
                          termsAccepted = val ?? false;
                        });
                      },
                      side: BorderSide(color: yellowColor),
                      checkColor: yellowColor,
                      focusColor: Colors.white,
                    ),
                    const Expanded(
                      child: Text(
                        'I Fully Confirm That I Have Read,Understood & Accepted The Enderuser License Agreement & Privacy Policies',
                        maxLines: 2,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isLoading = false;
  void _signInWithEmailAndPassword() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Email and password is required',
          toastLength: Toast.LENGTH_SHORT,
          // gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);

      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        setState(() {
          isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: e.message ?? '',
          toastLength: Toast.LENGTH_SHORT,
          // gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      debugPrint('this is firebase exception ${e.message}');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential result =
            await _auth.signInWithCredential(credential);
        final User? user = result.user;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }
}
