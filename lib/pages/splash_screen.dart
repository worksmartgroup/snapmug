import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:snapmug/pages/HomePage.dart';
import 'package:snapmug/pages/SignIn.dart';

import 'add_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // late AppLifecycleReactor _appLifecycleReactor;

  Timer? timer;

  @override
  void initState() {
    if (mounted) {
      timer = Timer.periodic(const Duration(seconds: 3), (val) {
        GoogleAdds.createAppOpenedAd();
        if (FirebaseAuth.instance.currentUser != null) {
          FirebaseMessaging.instance.getToken().then((token) {
            print("Firebase Token: $token");
          });
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignInActivity()));
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/logo_splach.png')),
    );
  }
}
